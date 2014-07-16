#include "backuper.h"
#include "kaqazmacros.h"
#include "kaqaz.h"
#include "resourcemanager.h"
#include "database.h"

#include <QThread>

class BackuperPrivate
{
public:
    QThread *thread;
    Kaqaz *kaqaz;
    BackuperCore *core;
};

Backuper::Backuper(Kaqaz *kaqaz) :
    QObject()
{
    p = new BackuperPrivate;
    p->kaqaz = kaqaz;
    p->thread = new QThread();

    p->core = new BackuperCore(p->kaqaz);
    p->core->moveToThread(p->thread);

    connect( p->core, SIGNAL(success())     , SIGNAL(success())     , Qt::QueuedConnection );
    connect( p->core, SIGNAL(failed())      , SIGNAL(failed())      , Qt::QueuedConnection );
    connect( p->core, SIGNAL(progress(int)) , SIGNAL(progress(int)) , Qt::QueuedConnection );

    p->thread->start();
}

void Backuper::makeBackup( const QString & password )
{
    const QString & db_path = Kaqaz::database()->path();
    const QString & repository_path = p->kaqaz->repositoryPath();
    const QString & conf_path = HOME_PATH + "/config.ini";

    QMetaObject::invokeMethod( p->core, "makeBackup", Q_ARG(QString,repository_path), Q_ARG(QString,db_path), Q_ARG(QString,conf_path), Q_ARG(QString,password) );
}

bool Backuper::restore(const QString &path, const QString &password)
{
    ResourceManager rsrc( path, false );
    if( !rsrc.checkHead(password) )
        return false;
    else
        rsrc.close();

    const QString & home_path = p->kaqaz->profilePath();
    const QString & repository_path = p->kaqaz->repositoryPath();

    p->kaqaz->disconnectAllResources();

    QMetaObject::invokeMethod( p->core, "restore", Q_ARG(QString,repository_path), Q_ARG(QString,home_path), Q_ARG(QString,path), Q_ARG(QString,password) );

    return true;
}

Backuper::~Backuper()
{
    p->thread->deleteLater();
    p->core->deleteLater();
    delete p;
}



class BackuperCorePrivate
{
public:
    Kaqaz *kaqaz;
};

BackuperCore::BackuperCore(Kaqaz *kaqaz)
{
    p = new BackuperCorePrivate;
    p->kaqaz = kaqaz;
}

void BackuperCore::makeBackup(const QString &repository_path, const QString &db_path, const QString &cnf_path, const QString &password)
{
    QString path = BACKUP_PATH;
    QDir().mkpath(path);

    QString dest = path + "/kaqaz_backup_" + QDateTime::currentDateTime().toString("ddd - MMM dd yyyy - hh_mm") + ".kqz";
    QStringList reps_files = QDir(repository_path).entryList(QDir::Files);

    emit progress(0);

    ResourceManager rsrc( dest, true );
    rsrc.writeHead( password );
    rsrc.addFile(db_path , password );
    rsrc.addFile(cnf_path, password );
    emit progress( 100.0/(reps_files.length()+1) );

    int counter = 0;
    foreach( const QString & f, reps_files )
    {
        rsrc.addFile( repository_path + "/" + f, password );

        counter++;
        emit progress( 100*(counter+1.0)/(reps_files.length()+1) );
    }

    rsrc.close();
    emit success();
}

void BackuperCore::restore(const QString &repository_path, const QString &home_path, const QString &path, const QString &password)
{
    ResourceManager rsrc( path, false );
    rsrc.checkHead(password);

    emit progress(0);

    QFile::remove( home_path + "/database.sqlite" );
    QFile::remove( home_path + "/config.ini" );
    QStringList reps_files = QDir(repository_path).entryList(QDir::Files);
    foreach( const QString & f, reps_files )
        QFile::remove( repository_path + "/" + f );

    QString tempFile = QString(TEMP_PATH) + "/kaqaz_restore_temp";
    QString fileName = rsrc.extractFile(tempFile,password);
    emit progress( ((qreal)rsrc.currentPosition()/rsrc.size())*100 );

    while( !fileName.isEmpty() )
    {
        QFileInfo fileInfo( fileName );
        QString dest = repository_path;
        if( fileInfo.suffix() == "sqlite" || fileInfo.suffix() == "ini" )
            dest = home_path;

        QFile::rename(tempFile, dest + "/" + fileName);
        fileName = rsrc.extractFile(tempFile,password);
        emit progress( ((qreal)rsrc.currentPosition()/rsrc.size())*100 );
    }

    QMetaObject::invokeMethod( p->kaqaz, "reconnectAllResources" );
    emit success();
}

BackuperCore::~BackuperCore()
{
    delete p;
}
