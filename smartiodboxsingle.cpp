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

#define BEGIN_FNC \
    if(p->started) return; \
    p->started = true; \
    emit started(this);

#define END_FNC { \
    p->started = false; \
    emit finished(this); \
    return; }

#define EXTRACT_PART(DEST,QSTR) \
    QString DEST = QSTR.mid(0,QSTR.indexOf("\n")); \
    QSTR.remove(0,DEST.length()+1);

#define NAME_OF(METHOD) #METHOD

#define PAPER_DATA_HEADER  QString("KaqazPaper")
#define PAPER_DATA_VERSION QString("1.0")
#define GROUP_DATA_HEADER  QString("KaqazGroups")
#define GROUP_DATA_VERSION QString("1.0")

#define CALL_CORE_VOID( METHOD ) SialanTools::call(p->core, NAME_OF(METHOD), Qt::QueuedConnection );
#define CALL_CORE( METHOD, ... ) SialanTools::call(p->core, NAME_OF(METHOD), Qt::QueuedConnection, __VA_ARGS__ );

#include "smartiodboxsingle.h"
#include "kaqaz.h"
#include "database.h"
#include "sialantools/sialantools.h"
#include "kaqazmacros.h"
#include "qdropbox.h"
#include "qdropboxfile.h"
#include "qdropboxfileinfo.h"
#include "SimpleQtCryptor/simpleqtcryptor.h"

#include <QFileInfo>
#include <QFile>
#include <QCoreApplication>
#include <QThread>
#include <QEventLoop>
#include <QMutex>
#include <QDebug>
#include <QBuffer>
#include <QDataStream>

class SmartIODBoxSinglePrivate
{
public:
    QString password;

    bool started;

    QDropbox *dbox;
    QThread *thread;
    QEventLoop *loop;

    SmartIODBoxSingleCore *core;

    QByteArray cache;
    QMutex cache_mutex;
};

SmartIODBoxSingle::SmartIODBoxSingle(QObject *parent) :
    QObject(parent)
{
    p = new SmartIODBoxSinglePrivate;
    p->started = false;

    p->dbox = new QDropbox(DROPBOX_APP_KEY, DROPBOX_APP_SECRET, QDropbox::Plaintext, "api.dropbox.com", this);
    p->dbox->setAuthMethod(QDropbox::Plaintext);

    p->loop = new QEventLoop(this);

    p->core = new SmartIODBoxSingleCore();
    p->core->moveToThread( Kaqaz::database()->thread() );

    p->thread = new QThread();
    moveToThread(p->thread);

    p->thread->start();

    connect( p->thread, SIGNAL(destroyed())           , SLOT(deleteLater())        , Qt::QueuedConnection );
    connect( p->core  , SIGNAL(paperIsReady(QByteArray)) , SLOT(cacheIsReady(QByteArray)), Qt::QueuedConnection );
    connect( p->core  , SIGNAL(groupsIsReady(QByteArray)), SLOT(cacheIsReady(QByteArray)), Qt::QueuedConnection );
    connect( p->core  , SIGNAL(finished())            , SLOT(coreFinished())       , Qt::QueuedConnection );
}

void SmartIODBoxSingle::setToken(const QString &t)
{
    p->dbox->setToken(t);
}

QString SmartIODBoxSingle::token() const
{
    return p->dbox->token();
}

void SmartIODBoxSingle::setTokenSecret(const QString &s)
{
    p->dbox->setTokenSecret(s);
}

QString SmartIODBoxSingle::tokenSecret() const
{
    return p->dbox->tokenSecret();
}

void SmartIODBoxSingle::setPassword(const QString &pass)
{
    if( p->password == pass )
        return;

    p->password = pass;
    emit passwordChanged();
}

QString SmartIODBoxSingle::password() const
{
    return p->password;
}

void SmartIODBoxSingle::pushFile(const QString &file, const QString & dest)
{
    BEGIN_FNC
    QFile src(file);
    if( !src.open(QFile::ReadOnly) )
        END_FNC

    QDropboxFile dst( dest, p->dbox );
    if( !dst.open(QDropboxFile::WriteOnly) )
        END_FNC

    dst.write(encryptData(src.readAll()));
    dst.close();
    src.close();
    END_FNC
}

void SmartIODBoxSingle::fetchFile(const QString &path, const QString & dest)
{
    BEGIN_FNC
    QDropboxFile file(path,p->dbox);
    if( !file.open(QDropboxFile::ReadOnly) )
        END_FNC

    QFile ofile(dest);
    ofile.remove();
    if( !ofile.open(QFile::WriteOnly) )
    {
        file.close();
        END_FNC
    }

    ofile.write(decryptData(file.readAll()));
    ofile.flush();
    ofile.close();
    file.close();
    END_FNC
}

void SmartIODBoxSingle::pushPaper(const QString &uuid, qint64 revision, const QString & dest)
{
    BEGIN_FNC
    QString gid = uuid;
    gid.remove("{").remove("}");

    CALL_CORE(requestPaperToSync, uuid );
    p->loop->exec();

    QDropboxFile file( dest, p->dbox );
    if( !file.open(QDropboxFile::WriteOnly) )
        END_FNC;

    const QByteArray cached_data = p->cache;

    file.write(encryptData(cached_data));
    file.close();

    CALL_CORE(requestPaperToSync, uuid );
    p->loop->exec();

    if( p->cache != cached_data )
        END_FNC

    CALL_CORE( paperPushed, uuid, revision );
    p->loop->exec();

    emit revisionChanged( gid, revision );
    END_FNC
}

void SmartIODBoxSingle::fetchPaper(const QString &uuid, qint64 revision, const QString & path)
{
    BEGIN_FNC
    QString gid = uuid;
    gid.remove("{").remove("}");

    QDropboxFile file(path,p->dbox);
    if( !file.open(QDropboxFile::ReadOnly) )
        END_FNC

    const QByteArray & data = decryptData(file.readAll());
    file.close();

    CALL_CORE( paperFetched, uuid, data, revision );
    p->loop->exec();

    emit revisionChanged( gid, revision );
    END_FNC
}

void SmartIODBoxSingle::pushGroups(const QString & path, qint64 revision)
{
    BEGIN_FNC
    QDropboxFile file( path, p->dbox );
    if( !file.open(QDropboxFile::WriteOnly) )
        END_FNC;

    CALL_CORE_VOID( requestGroupsToSync );
    p->loop->exec();

    file.write(encryptData(p->cache));
    file.close();

    CALL_CORE( groupsPushed, revision );
    p->loop->exec();

    emit revisionChanged(GROUPS_SYNC_KEY,revision);
    END_FNC
}

void SmartIODBoxSingle::fetchGroups(const QString & path, qint64 revision)
{
    BEGIN_FNC
    QDropboxFile file(path,p->dbox);
    if( !file.open(QDropboxFile::ReadOnly) )
        END_FNC

    const QByteArray & data = decryptData(file.readAll());
    file.close();

    CALL_CORE( groupsFetched, data, revision );
    p->loop->exec();

    emit revisionChanged( GROUPS_SYNC_KEY, revision );
    END_FNC
}

void SmartIODBoxSingle::setDeleted(const QString &path)
{
    BEGIN_FNC
    QDropboxFile file(path,p->dbox);
    if( !file.open(QDropboxFile::WriteOnly) )
        END_FNC

    file.write("DELETED");
    file.close();
    emit revisionChanged(path,-2);
    END_FNC
}

void SmartIODBoxSingle::close()
{
    p->thread->quit();
    p->thread->wait();
    p->thread->deleteLater();
}

QString SmartIODBoxSingle::cache() const
{
    p->cache_mutex.lock();
    QString result = p->cache;
    p->cache_mutex.unlock();
    return result;
}

void SmartIODBoxSingle::cacheIsReady(const QByteArray &data)
{
    p->cache_mutex.lock();
    p->cache = data;
    p->cache_mutex.unlock();
}

void SmartIODBoxSingle::coreFinished()
{
    p->loop->exit();
}

QByteArray SmartIODBoxSingle::encryptData(const QByteArray &data)
{
    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(p->password));
    SimpleQtCryptor::Encryptor enc( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB, SimpleQtCryptor::NoChecksum );

    QByteArray enc_new_data;
    enc.encrypt( data, enc_new_data, true );

    return enc_new_data;
}

QByteArray SmartIODBoxSingle::decryptData(const QByteArray &sdata)
{
    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(p->password));
    SimpleQtCryptor::Decryptor dec( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB );
    QByteArray enc_code_dec;
    if( dec.decrypt(sdata,enc_code_dec,true) == SimpleQtCryptor::ErrorInvalidKey )
        return enc_code_dec;

    return enc_code_dec;
}

SmartIODBoxSingle::~SmartIODBoxSingle()
{
    p->core->deleteLater();
    delete p;
}

void SmartIODBoxSingleCore::requestPaperToSync(const QString &uuid)
{
    Database *db = Kaqaz::database();
    int paperId = db->paperUuidId(uuid);
    if( paperId == -1 )
    {
        emit finished();
        return;
    }

    QByteArray d;
    QBuffer buffer(&d);
    buffer.open(QBuffer::WriteOnly);
    QDataStream stream(&buffer);

    stream << PAPER_DATA_HEADER;
    stream << PAPER_DATA_VERSION;
    stream << db->paperTitle(paperId);
    stream << QString("0,0");
    stream << db->paperCreatedDate(paperId).toString();
    stream << db->paperModifiedDate(paperId).toString();
    stream << db->groupUuid( db->paperGroup(paperId) );
    stream << db->paperFiles(paperId);
    stream << db->paperText(paperId);

    buffer.close();
    d.prepend("#");

    emit paperIsReady(d);
    emit finished();
}

void SmartIODBoxSingleCore::requestGroupsToSync()
{
    Database *db = Kaqaz::database();

    QByteArray data;
    QBuffer mainBuffer(&data);
    mainBuffer.open(QBuffer::WriteOnly);
    QDataStream mainStream(&mainBuffer);
    mainStream << GROUP_DATA_HEADER;
    mainStream << GROUP_DATA_VERSION;

    const QList<int> & groups = db->groups();
    foreach( int gr, groups )
    {
        QByteArray d;
        QBuffer buffer(&d);
        buffer.open(QBuffer::WriteOnly);

        QDataStream stream(&buffer);
        stream << db->groupUuid(gr);
        stream << db->groupColor(gr).name();
        stream << db->groupName(gr);

        buffer.close();
        mainStream << d;
    }

    mainBuffer.close();
    data.prepend("#");

    emit groupsIsReady(data);
    emit finished();
}

void SmartIODBoxSingleCore::paperPushed(const QString &id, quint64 revision)
{
    Database *db = Kaqaz::database();
    db->setSignalBlocker(true);
    db->setRevision(id,revision);
    db->setSignalBlocker(false);
    emit finished();
}

void SmartIODBoxSingleCore::paperFetched(const QString &uuid, const QByteArray &d_const, quint64 revision)
{
    if( d_const.isEmpty() )
    {
        emit finished();
        return;
    }

    Database *db = Kaqaz::database();
    db->setSignalBlocker(true);

    if( d_const[0] == '#' ) //! New Method
    {
        QByteArray d = d_const.mid(1);
        QBuffer buffer(&d);
        buffer.open(QBuffer::ReadOnly);
        QDataStream stream(&buffer);

        QString header;
        QString version;
        QString title;
        QString location;
        QString date;
        QString mdate;
        QString group;
        QStringList files;
        QString body;

        stream >> header;
        stream >> version;
        stream >> title;
        stream >> location;
        stream >> date;
        stream >> mdate;
        stream >> group;
        stream >> files;
        stream >> body;

        db->setPaper( uuid, title, body, group, date );
        db->setRevision( uuid, revision );

        int paperId = db->paperUuidId(uuid);
        for( int i=files.count()-1; i>=0 ; i-- )
            db->addFileToPaper( paperId, files[i] );
    }
    else //! Old method
    {
        QString d = d_const;

        EXTRACT_PART(title,d);
        EXTRACT_PART(date ,d);
        EXTRACT_PART(group,d);
        EXTRACT_PART(files,d);

        db->setPaper( uuid, title, d, group, date );
        db->setRevision( uuid, revision );

        int paperId = db->paperUuidId(uuid);

        const QStringList & flist = files.split(";",QString::SkipEmptyParts);
        for( int i=flist.count()-1; i>=0 ; i-- )
            db->addFileToPaper( paperId, flist[i] );
    }

    db->setSignalBlocker(false);
    emit finished();
}

void SmartIODBoxSingleCore::groupsPushed(quint64 revision)
{
    Database *db = Kaqaz::database();
    db->setSignalBlocker(true);
    db->setRevision( GROUPS_SYNC_KEY, revision );
    db->setSignalBlocker(false);
    emit finished();
}

void SmartIODBoxSingleCore::groupsFetched(const QByteArray &data, quint64 revision)
{
    if( data.isEmpty() )
    {
        emit finished();
        return;
    }

    Database *db = Kaqaz::database();
    db->setSignalBlocker(true);

    if( data[0] == '#' ) //! New Method
    {
        QByteArray mainData = data.mid(1);
        QBuffer mainBuffer(&mainData);
        mainBuffer.open(QBuffer::ReadOnly);
        QDataStream mainStream(&mainBuffer);

        QString header;
        QString version;

        mainStream >> header;
        mainStream >> version;

        while( !mainStream.atEnd() )
        {
            QByteArray record;
            mainStream >> record;

            QBuffer buffer(&record);
            buffer.open(QBuffer::ReadOnly);
            QDataStream stream(&buffer);

            QString uuid;
            QString color;
            QString name;

            stream >> uuid;
            stream >> color;
            stream >> name;

            db->setGroup( uuid, name, color );
            buffer.close();
        }

        mainBuffer.close();
    }
    else //! Old Method
    {
        const QStringList & list = QString(data).split("\n");
        for( int i=2; i<list.count(); i+=3 )
        {
            const QString & uuid  = list[i-2];
            const QString & color = list[i-1];
            const QString & name  = list[i-0];

            db->setGroup( uuid, name, color );
        }
    }

    db->setRevision( GROUPS_SYNC_KEY, revision );
    db->setSignalBlocker(false);
    emit finished();
}

void SmartIODBoxSingleCore::paperDeleted(const QString &id)
{
    Database *db = Kaqaz::database();
    int paperId = db->paperUuidId(id);
    if( paperId == -1 )
    {
        emit finished();
        return;
    }

    db->setSignalBlocker(true);
    db->deletePaper( paperId );
    db->setSignalBlocker(false);

    emit finished();
}
