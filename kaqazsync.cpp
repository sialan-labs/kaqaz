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

#include "kaqazsync.h"
#include "sialandeveloper_macros.h"
#include "kaqazmacros.h"
#include "kaqazdropbox.h"
#include "qdropboxfile.h"
#include "database.h"
#include "kaqaz.h"

#include <QThread>
#include <QPointer>

class KaqazSyncPrivate
{
public:
    KaqazDropBox *kdbox;
    QPointer<QThread> thread;
    Database *db;

    QString password;
};

KaqazSync::KaqazSync(Database *db, QObject *parent) :
    QObject(parent)
{
    p = new KaqazSyncPrivate;
    p->db = db;
    p->kdbox = 0;
    p->password = p->db->syncPassword();

    connect( p->db, SIGNAL(paperChanged(int))  , SLOT(refresh()) );
    connect( p->db, SIGNAL(revisionsChanged()) , SLOT(refresh()) );
    connect( p->db, SIGNAL(filesListChanged()) , SLOT(refresh()) );

    reload();
}

bool KaqazSync::tokenAvailable() const
{
    return p->kdbox->tokenAvailable();
}

void KaqazSync::setPassword(const QString &pass)
{
    QString hash = Kaqaz::passToMd5(pass);
    p->db->setSyncPassword( hash );
    p->password = hash;
}

QString KaqazSync::password() const
{
    return p->db->syncPassword();
}

void KaqazSync::setFileSyncing(bool stt)
{
    p->kdbox->setFileSyncing(stt);
    Kaqaz::settings()->setValue( "General/fileSyncing", stt );
    emit fileSyncingChanged();
    refresh();
}

bool KaqazSync::fileSyncing() const
{
    return p->kdbox->fileSyncing();
}

void KaqazSync::password_changed(const QString &password)
{
    p->db->setSyncPassword( password );
    emit passwordChanged();
}

void KaqazSync::connectedChanged()
{
    if( p->kdbox->connected() )
    {
        connect( p->db, SIGNAL(paperChanged(int))  , p->kdbox, SLOT(refresh()), Qt::QueuedConnection );
        connect( p->db, SIGNAL(groupsListChanged()), p->kdbox, SLOT(refresh()), Qt::QueuedConnection );

        start();
    }
    else
    {
        disconnect( p->db, SIGNAL(paperChanged(int))  , p->kdbox, SLOT(refresh()) );
        disconnect( p->db, SIGNAL(groupsListChanged()), p->kdbox, SLOT(refresh()) );
    }
}

void KaqazSync::refresh()
{
    p->kdbox->setLocalSyncHash( p->db->revisions() );
    QMetaObject::invokeMethod( p->kdbox, "refresh", Qt::QueuedConnection );
}

void KaqazSync::refreshForce()
{
    p->kdbox->setLocalSyncHash( p->db->revisions() );
    QMetaObject::invokeMethod( p->kdbox, "refreshForce", Qt::QueuedConnection );
}

void KaqazSync::start()
{
    QMetaObject::invokeMethod( p->kdbox, "connectDropbox", Qt::QueuedConnection, Q_ARG(QString,p->password) );
}

void KaqazSync::stop()
{
    QSettings settings(CONFIG_PATH,QSettings::IniFormat);
    settings.remove(TOKEN_KEY);
    settings.remove(TOKEN_SECRET);
    reload();
}

void KaqazSync::reload()
{
    if( p->thread )
    {
        p->thread->quit();
        p->thread->wait();
        p->thread->deleteLater();
    }

    p->thread = new QThread(this);

#ifdef FREE_BUILD
    bool file_sync_default = false;
#else
    bool file_sync_default = true;
#endif

    p->kdbox = new KaqazDropBox();
    p->kdbox->setFileSyncing( Kaqaz::settings()->value( "General/fileSyncing", file_sync_default ).toBool() );
    p->kdbox->setLocalSyncHash(p->db->revisions());
    p->kdbox->moveToThread(p->thread);

    connect( p->kdbox, SIGNAL(authorizeRequest())      , SIGNAL(authorizeRequest())     , Qt::QueuedConnection );
    connect( p->kdbox, SIGNAL(passwordChanged(QString)), SLOT(password_changed(QString)), Qt::QueuedConnection );
    connect( p->kdbox, SIGNAL(paperDeleted(QString))   , SLOT(paperDeleted(QString))    , Qt::QueuedConnection );
    connect( p->kdbox, SIGNAL(connectedChanged())      , SLOT(connectedChanged())       , Qt::QueuedConnection );
    connect( p->kdbox, SIGNAL(syncStarted())           , SIGNAL(syncStarted())          , Qt::QueuedConnection );
    connect( p->kdbox, SIGNAL(syncProgress(qreal))     , SIGNAL(syncProgress(qreal))    , Qt::QueuedConnection );
    connect( p->kdbox, SIGNAL(syncFinished())          , SIGNAL(syncFinished())         , Qt::QueuedConnection );
    connect( p->kdbox, SIGNAL(tokenAvailableChanged()) , SIGNAL(tokenAvailableChanged()), Qt::QueuedConnection );
    connect( p->kdbox, SIGNAL(refreshRequest())        , SLOT(refreshForce())           , Qt::QueuedConnection );

    connect( p->thread, SIGNAL(finished()), p->kdbox, SLOT(deleteLater()) );

    p->thread->start();
    QMetaObject::invokeMethod( p->kdbox, "initialize", Qt::QueuedConnection );

    emit tokenAvailableChanged();
}

void KaqazSync::authorizeDone()
{
    QMetaObject::invokeMethod( p->kdbox, "authorizeDone", Qt::QueuedConnection );
}

void KaqazSync::paperDeleted(const QString &id)
{
    int paperId = p->db->paperUuidId(id);
    if( paperId == -1 )
        return;

    p->db->deletePaper( paperId );
}

KaqazSync::~KaqazSync()
{
    delete p;
}
