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

#define ROOT_FOLDER      "/sandbox/"
#define PAPERS_FOLDER    ROOT_FOLDER"papers/"
#define ATTACHS_FOLDER   ROOT_FOLDER"attachs/"
#define PASSWORD_FILE    ROOT_FOLDER"passwords"
#define GROUPS_FILE      ROOT_FOLDER"groups"
#define REVISIONS_FILE   ROOT_FOLDER"revisions"
#define MAXIMUM_UPLOAD   10
#define FILE_MAX_SIZE_MB 20
#define UPDATE_KEY       "DBOX_UPDATE"
#define DBOX_CLOSE(DBFL) DBFL.close();

#define ALLOC_DBOX(NAME) \
    QDropbox NAME( DROPBOX_APP_KEY, DROPBOX_APP_SECRET, QDropbox::Plaintext, "api.dropbox.com", this ); \
    NAME.setAuthMethod(QDropbox::Plaintext); \
    NAME.setToken(p->settings->value(TOKEN_KEY).toString()); \
    NAME.setTokenSecret(p->settings->value(TOKEN_SECRET).toString());

#include "kaqazdropbox.h"
#include "qdropbox.h"
#include "qdropboxfile.h"
#include "database.h"
#include "smartiodbox.h"
#include "kaqazmacros.h"
#include "SimpleQtCryptor/simpleqtcryptor.h"

#include <QDesktopServices>
#include <QEventLoop>
#include <QTimer>
#include <QDir>
#include <QUuid>
#include <QMutex>
#include <QQueue>
#include <QSettings>
#include <QTimerEvent>
#include <QDataStream>
#include <QDebug>

class KaqazDropBoxPrivate
{
public:
    QDropbox *dbox;
    QEventLoop *loop;
    SmartIODBox *smartio;

    bool connected;
    QString master_password;

    QMutex mutex;

    SyncItemHash syncHash;

    int refresh_timer;
    QHash<QString,qint64> revisions;

    bool reupdate_flag;
    bool rsvn_fetched;
    bool token;
    bool fileSyncing;

    QSet<QString> fnc_recall;
    QSet<QString> on_fnc_call;
    QQueue<QString> fnc_pend_update;

    QSettings *settings;
};

KaqazDropBox::KaqazDropBox(QObject *parent) :
    QObject(parent)
{
    p = new KaqazDropBoxPrivate;
    p->connected = false;
    p->dbox = 0;
    p->refresh_timer = 0;
    p->rsvn_fetched = false;
    p->token = false;
    p->fileSyncing = true;

    p->settings = new QSettings(CONFIG_PATH,QSettings::IniFormat);
    checkToken();
}

bool KaqazDropBox::connected() const
{
    return p->connected;
}

bool KaqazDropBox::tokenAvailable() const
{
    return p->token;
}

void KaqazDropBox::setFileSyncing(bool stt)
{
    p->fileSyncing = stt;
}

bool KaqazDropBox::fileSyncing() const
{
    return p->fileSyncing;
}

void KaqazDropBox::setLocalSyncHash(const SyncItemHash &hash)
{
    p->mutex.lock();
    p->syncHash = hash;
    p->mutex.unlock();

    QMetaObject::invokeMethod(this, "refresh", Qt::QueuedConnection);
}

SyncItemHash KaqazDropBox::localSyncHash() const
{
    p->mutex.lock();
    SyncItemHash res = p->syncHash;
    p->mutex.unlock();

    return res;
}

void KaqazDropBox::localListUpdated()
{
    if( p->master_password.isEmpty() )
        return;
    if( !beginPush(UPDATE_KEY) )
        return;
    if( p->on_fnc_call.count() != 1 )
    {
        refresh();
        endPush(UPDATE_KEY);
        return;
    }

    const QDropboxFileInfo &papersInf = p->dbox->requestMetadataAndWait(PAPERS_FOLDER);
    const QDropboxFileInfo &filesInf = p->dbox->requestMetadataAndWait(ATTACHS_FOLDER);

    if( !papersInf.isDir() || !filesInf.isDir() )
    {
        refresh();
        endPush(UPDATE_KEY);
        return;
    }

    emit syncStarted();

    const QList<QDropboxFileInfo> & papers = papersInf.contents();
    const QList<QDropboxFileInfo> & files  = filesInf.contents();

    const SyncItemHash & syncHash = localSyncHash();
    if( syncHash.contains(GROUPS_SYNC_KEY) )
    {
        const SyncItem & item = syncHash.value(GROUPS_SYNC_KEY);
        qint64 revision = fetchRevision(GROUPS_SYNC_KEY);
        if( revision > item.revision )
            p->smartio->fetchGroups(GROUPS_FILE,revision);
    }

    QHash<QString,QDropboxFileInfo> papersIndexes;
    foreach( const QDropboxFileInfo & inf, papers )
    {
        const QString & id = "{" + QFileInfo(inf.path()).fileName() + "}";
        papersIndexes[id] = inf;

        qint64 revision = fetchRevision(inf.path());

        SyncItem item = syncHash.value(id);
        if( revision == -2 )
        {
            if( item.revision != -2 )
                emit paperDeleted(item.id);
            continue;
        }
        if( item.id == id && item.revision == revision )
            continue;
        if( !item.id.isEmpty() && item.revision == -1 )
            continue;

        p->smartio->fetchPaper(id, revision, ROOT_FOLDER+inf.path());
    }

    QHash<QString,QDropboxFileInfo> filesIndexes;
    const QStringList & local_files = QDir(HOME_PATH + "/repository").entryList(QDir::Files);
    foreach( const QDropboxFileInfo & inf, files )
    {
        const QString & fileName = QFileInfo(inf.path()).fileName();
        filesIndexes[fileName] = inf;

        if( dboxFileIsDeleted(ROOT_FOLDER+inf.path()) )
        {
            if( !fileIsDeleted(HOME_PATH + "/repository/" + fileName) )
                setFileDeleted(HOME_PATH + "/repository/" + fileName);
            continue;
        }
        if( local_files.contains(fileName) )
            continue;
        if( inf.bytes()/(1024*1024) >= FILE_MAX_SIZE_MB )
            continue;
        if( !p->fileSyncing )
            continue;

        p->smartio->fetchFile( ROOT_FOLDER+inf.path(), HOME_PATH + "/repository/" + fileName );
    }

    foreach( const QString & lfile, local_files )
    {
        const QString & path = QString(HOME_PATH + "/repository/" + lfile);
        if( fileIsDeleted(path) )
        {
            if( !dboxFileIsDeleted(ATTACHS_FOLDER + lfile) )
                p->smartio->setDeleted(ATTACHS_FOLDER + lfile);
            continue;
        }
        if( filesIndexes.contains(lfile) )
            continue;
        if( QFileInfo(path).size()/(1024*1024) >= FILE_MAX_SIZE_MB )
            continue;

        p->smartio->pushFile( path, ATTACHS_FOLDER + lfile );
    }

    QHashIterator<QString,SyncItem> i(syncHash);
    while( i.hasNext() )
    {
        i.next();

        const SyncItem & item = i.value();
        if( item.id.isEmpty() )
            continue;

        if( item.id[0] == '{' ) // It's Paper
        {
            QDropboxFileInfo inf = papersIndexes.value(item.id);
            qint64 revision = fetchRevision(inf.path());
            if( revision == -2 )
                continue;
            if( revision >= item.revision && item.revision >= 0 && papersIndexes.contains(item.id) )
                continue;
            if( item.revision == -2 )
            {
                p->smartio->setDeleted(ROOT_FOLDER+inf.path());
                continue;
            }

            p->smartio->pushPaper(item.id,revision+1,PAPERS_FOLDER+QString(item.id).remove("{").remove("}"));
        }
        else
        if( item.id == GROUPS_SYNC_KEY ) // It's Groups list
        {
            qint64 revision = fetchRevision(GROUPS_SYNC_KEY);
            if( revision >= item.revision )
                continue;
            if( item.revision == -1 && revision != -1 )
            {
                localListUpdated(); // Refresh another time when groups fetched
                continue;
            }

            p->smartio->pushGroups(GROUPS_FILE,revision+1);
        }
    }

    if( !p->smartio->isActive() )
        update_finished();
}

void KaqazDropBox::update_finished()
{
    emit syncFinished();
    if( !endPush(UPDATE_KEY) )
        emit refreshRequest();
}

void KaqazDropBox::connectDropbox(const QString &password)
{
    if( p->connected )
    {
        fetch_password(password);
        refresh();
        return;
    }

    if(!p->dbox->requestTokenAndWait())
    {
        emit getTokenFailed();
        return;
    }

    if(!p->dbox->requestAccessTokenAndWait())
    {
        int i = 0;
        for(;i<3; ++i)
        {
            if(p->dbox->error() != QDropbox::TokenExpired)
                break;

            authorizeApplication();
        }

        if(i>3)
        {
            emit authorizeFailed();
            return;
        }

        if(p->dbox->error() != QDropbox::NoError)
        {
            emit accessError( p->dbox->errorString() );
            return;
        }
    }

    p->settings->setValue(TOKEN_KEY,p->dbox->token());
    p->settings->setValue(TOKEN_SECRET,p->dbox->tokenSecret());
    p->settings->sync();
    p->smartio->setToken(p->dbox->token());
    p->smartio->setTokenSecret(p->dbox->tokenSecret());
    checkToken();

    p->connected = true;
    refresh();
    emit connectedChanged();
}

void KaqazDropBox::disconnectDropbox()
{
    p->settings->remove(TOKEN_KEY);
    p->settings->remove(TOKEN_SECRET);
    p->settings->sync();
    p->dbox->setToken(QString());
    p->dbox->setTokenSecret(QString());
    p->smartio->setToken(p->dbox->token());
    p->smartio->setTokenSecret(p->dbox->tokenSecret());
    p->connected = false;
    emit connectedChanged();
}

void KaqazDropBox::initialize()
{
    if(p->dbox )
        return;

    p->loop = new QEventLoop(this);

    p->dbox = new QDropbox( DROPBOX_APP_KEY, DROPBOX_APP_SECRET, QDropbox::Plaintext, "api.dropbox.com", this );
    p->dbox->setAuthMethod(QDropbox::Plaintext);

    p->smartio = new SmartIODBox(this);

    p->connected = false;

    if(!p->settings->value(TOKEN_KEY).toString().isEmpty())
    {
        p->dbox->setToken(p->settings->value(TOKEN_KEY).toString());
        p->dbox->setTokenSecret(p->settings->value(TOKEN_SECRET).toString());
        p->smartio->setToken(p->dbox->token());
        p->smartio->setTokenSecret(p->dbox->tokenSecret());
        p->connected = true;
        checkToken();
    }

    connect( p->smartio, SIGNAL(revisionChanged(QString,qint64)), SLOT(setRevision(QString,qint64)) );
    connect( p->smartio, SIGNAL(progressChanged(qreal))         , SIGNAL(syncProgress(qreal))      , Qt::QueuedConnection );
    connect( p->smartio, SIGNAL(progressFinished())             , SLOT(update_finished())          , Qt::QueuedConnection );

    emit connectedChanged();
}

void KaqazDropBox::refresh()
{
    if( p->refresh_timer )
        killTimer(p->refresh_timer);

    p->refresh_timer = startTimer(5000);
}

void KaqazDropBox::refreshForce()
{
    localListUpdated();
}

void KaqazDropBox::fetch_password( const QString & password )
{
    if( !beginPush(PASSWORD_FILE) )
        return;

    QDropboxFile file( PASSWORD_FILE, p->dbox );
    if( !file.open(QDropboxFile::ReadOnly) )
    {
        endPush(PASSWORD_FILE);
        return;
    }

    const QByteArray & sdata = file.readAll();
    file.close();

    if( sdata.isEmpty() )
    {
        p->master_password = QUuid::createUuid().toString();
        p->smartio->setPassword(p->master_password);
        const QByteArray & data = p->master_password.toUtf8();

        QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(password));
        SimpleQtCryptor::Encryptor enc( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB, SimpleQtCryptor::NoChecksum );

        QByteArray enc_new_data;
        enc.encrypt( data, enc_new_data, true );

        file.setOverwrite(false);
        if( !file.open(QDropboxFile::WriteOnly) )
        {
            endPush(PASSWORD_FILE);
            return;
        }

        file.write(enc_new_data);
        DBOX_CLOSE(file)
    }
    else
    {
        QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(password));
        SimpleQtCryptor::Decryptor dec( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB );
        QByteArray enc_code_dec;
        if( dec.decrypt(sdata,enc_code_dec,true) == SimpleQtCryptor::ErrorInvalidKey )
        {
            endPush(PASSWORD_FILE);
            return;
        }

        p->master_password = enc_code_dec;
        p->smartio->setPassword(p->master_password);
    }

    endPush(PASSWORD_FILE);
}

QByteArray KaqazDropBox::encryptData(const QByteArray &data)
{
    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(p->master_password));
    SimpleQtCryptor::Encryptor enc( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB, SimpleQtCryptor::NoChecksum );

    QByteArray enc_new_data;
    enc.encrypt( data, enc_new_data, true );

    return enc_new_data;
}

QByteArray KaqazDropBox::decryptData(const QByteArray &sdata)
{
    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(p->master_password));
    SimpleQtCryptor::Decryptor dec( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB );
    QByteArray enc_code_dec;
    if( dec.decrypt(sdata,enc_code_dec,true) == SimpleQtCryptor::ErrorInvalidKey )
        return enc_code_dec;

    return enc_code_dec;
}

bool KaqazDropBox::fileIsDeleted(const QString &path)
{
    QFile file(path);
    if( !file.open(QFile::ReadOnly) )
        return false;

    const QString data = file.read(10).trimmed();
    file.close();

    if( data == "DELETED" )
        return true;
    else
        return false;
}

void KaqazDropBox::setFileDeleted(const QString &path)
{
    QFile file(path);
    file.remove();

    if( !file.open(QFile::WriteOnly) )
        return;

    file.write("DELETED");
    file.flush();
    file.close();
}

bool KaqazDropBox::dboxFileIsDeleted(const QString &path)
{
    return fetchRevision(path) == -2;
}

void KaqazDropBox::setDboxFileDeleted(const QString &path)
{
    QDropboxFile file(path,p->dbox);
    if( !file.open(QDropboxFile::WriteOnly) )
        return;

    file.write("DELETED");
    DBOX_CLOSE(file)

    setRevision(path,-2);
}

qint64 KaqazDropBox::fetchRevision(const QString &path)
{
    fetchRevisions();
    if( path.isEmpty() )
        return -1;

    const QString & id = "{" + QFileInfo(path).fileName() + "}";
    if( p->revisions.contains(id) )
        return p->revisions[id];
    else
        return -1;
}

void KaqazDropBox::setRevision(const QString &path, qint64 revision)
{
    fetchRevisions();
    const QString & id = "{" + QFileInfo(path).fileName() + "}";
    p->revisions[id] = revision;
    pushRevisions();
}

void KaqazDropBox::pushRevisions()
{
    if( !beginPush(REVISIONS_FILE) )
        return;

    QDropboxFile rvsn_file(REVISIONS_FILE,p->dbox);
    if( !rvsn_file.open(QDropboxFile::WriteOnly) )
        return;

    QString data;
    QHashIterator<QString,qint64> i(p->revisions);
    while(i.hasNext())
    {
        i.next();
        data += i.key() + "=" + QString::number(i.value()) + "\n";
    }

    rvsn_file.write( data.toUtf8() );
    DBOX_CLOSE(rvsn_file)

    if( !endPush(REVISIONS_FILE) )
        pushRevisions();
}

void KaqazDropBox::fetchRevisions()
{
    if( p->rsvn_fetched )
        return;

    QDropboxFile file(REVISIONS_FILE,p->dbox);
    if( !file.open(QDropboxFile::ReadOnly) )
        return;

    const QString & data = file.readAll();
    file.close();

    const QStringList & lines = data.split("\n",QString::SkipEmptyParts);
    foreach( const QString & l, lines )
    {
        int index = l.indexOf("=");
        if( index == -1 )
            continue;

        p->revisions[l.mid(0,index)] = l.mid(index+1).toLongLong();
    }

    p->rsvn_fetched = true;
}

bool KaqazDropBox::beginPush(const QString &id)
{
    if( p->on_fnc_call.contains(id) )
    {
        p->fnc_recall.insert(id);
        return false;
    }
    else
    {
        p->on_fnc_call.insert(id);
        return true;
    }
}

bool KaqazDropBox::endPush(const QString &id)
{
    p->on_fnc_call.remove(id);
    if( p->fnc_recall.contains(id) )
    {
        p->fnc_recall.remove(id);
        return false;
    }
    else
        return true;
}

void KaqazDropBox::authorizeDone()
{
    p->loop->exit();
}

void KaqazDropBox::setPassword(const QString &password, const QString & old_password)
{
    if( !beginPush(PASSWORD_FILE) )
        return;

    QDropboxFile file( PASSWORD_FILE, p->dbox );
    if( !file.open(QDropboxFile::ReadOnly) )
        return;

    const QByteArray & sdata = file.readAll();
    file.close();

    QSharedPointer<SimpleQtCryptor::Key> old_gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(old_password));
    SimpleQtCryptor::Decryptor dec( old_gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB );
    QByteArray enc_code_dec;
    if( dec.decrypt(sdata,enc_code_dec,true) == SimpleQtCryptor::ErrorInvalidKey )
        return;

    QSharedPointer<SimpleQtCryptor::Key> new_gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(password));
    SimpleQtCryptor::Encryptor enc( new_gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB, SimpleQtCryptor::NoChecksum );

    QByteArray enc_new_data;
    enc.encrypt( enc_code_dec, enc_new_data, true );

    if( !file.open(QDropboxFile::WriteOnly) )
        return;

    file.write(enc_new_data);
    DBOX_CLOSE(file)

    emit passwordChanged(password);

    endPush(PASSWORD_FILE);
}

void KaqazDropBox::authorizeApplication()
{
    QDesktopServices::openUrl(p->dbox->authorizeLink());

    emit authorizeRequest();
    p->loop->exec();

    p->dbox->requestAccessTokenAndWait();
}

void KaqazDropBox::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->refresh_timer )
    {
        killTimer(p->refresh_timer);
        p->refresh_timer = 0;

        localListUpdated();
    }
}

void KaqazDropBox::checkToken()
{
    bool token = !p->settings->value(TOKEN_KEY).toString().isEmpty() &&
                 !p->settings->value(TOKEN_SECRET).toString().isEmpty();
    if( token == p->token )
        return;

    p->token = token;
    emit tokenAvailableChanged();
}

KaqazDropBox::~KaqazDropBox()
{
    delete p;
}
