/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "backuper.h"
#include "kaqazmacros.h"
#include "kaqaz.h"
#include "resourcemanager.h"
#include "database.h"

#include <QThread>
#include <QDebug>

class BackuperPrivate
{
public:
    QThread *thread;
    Kaqaz *kaqaz;
    BackuperCore *core;
};

Backuper::Backuper() :
    QObject()
{
    p = new BackuperPrivate;
    p->kaqaz = Kaqaz::instance();
    p->thread = new QThread();

    p->core = new BackuperCore();
    p->core->moveToThread(p->thread);

    connect( p->core, SIGNAL(success())     , SIGNAL(success())     , Qt::QueuedConnection );
    connect( p->core, SIGNAL(failed())      , SIGNAL(failed())      , Qt::QueuedConnection );
    connect( p->core, SIGNAL(progress(int)) , SIGNAL(progress(int)) , Qt::QueuedConnection );

    p->thread->start();
}

void Backuper::makeBackup( const QString & password )
{
    BEGIN_FNC_DEBUG
    const QString & db_path = Kaqaz::database()->path();
    const QString & repository_path = p->kaqaz->repositoryPath();
    const QString & conf_path = HOME_PATH + "/config.ini";

    QMetaObject::invokeMethod( p->core, "makeBackup", Q_ARG(QString,repository_path), Q_ARG(QString,db_path), Q_ARG(QString,conf_path), Q_ARG(QString,password) );
    END_FNC_DEBUG
}

bool Backuper::restore(const QString &path, const QString &password)
{
    ResourceManager rsrc( path, false );
    if( !rsrc.checkHead(password) )
        return false;
    else
        rsrc.close();

    BEGIN_FNC_DEBUG
    const QString & home_path = p->kaqaz->profilePath();
    const QString & repository_path = p->kaqaz->repositoryPath();

    p->kaqaz->disconnectAllResources();

    QMetaObject::invokeMethod( p->core, "restore", Q_ARG(QString,repository_path), Q_ARG(QString,home_path), Q_ARG(QString,path), Q_ARG(QString,password) );

    END_FNC_DEBUG
    return true;
}

Backuper::~Backuper()
{
    if( p->thread )
    {
        p->thread->quit();
        p->thread->wait();
        p->thread->deleteLater();
    }

    p->core->deleteLater();
    delete p;
}



class BackuperCorePrivate
{
public:
    Kaqaz *kaqaz;
};

BackuperCore::BackuperCore()
{
    p = new BackuperCorePrivate;
    p->kaqaz = Kaqaz::instance();
}

void BackuperCore::makeBackup(const QString &repository_path, const QString &db_path, const QString &cnf_path, const QString &password)
{
    BEGIN_FNC_DEBUG
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
    END_FNC_DEBUG
}

void BackuperCore::restore(const QString &repository_path, const QString &home_path, const QString &path, const QString &password)
{
    BEGIN_FNC_DEBUG
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
    END_FNC_DEBUG
}

BackuperCore::~BackuperCore()
{
    delete p;
}
