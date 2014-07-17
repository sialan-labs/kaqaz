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

#define MAX_ACTIVE_THREAD 20
#define CLOSE_EXTRA_SINGLES(MINIMUM) \
    while( false && p->threadsQueue.count() > MINIMUM ) { \
        SmartIODBoxSingle *s = p->threadsQueue.takeFirst(); \
        s->close(); \
        p->threads.remove(s); \
    }

#define APPEND_TO_QUEUE(CMD) \
    p->queue.append(CMD); \
    p->queued_cnt++; \
    nextCommand(); \
    if( p->queued_cnt == 1 ) \
        emit progressStarted(); \
    emit progressChanged(progress());

#include "smartiodbox.h"
#include "smartiodboxsingle.h"

#include <QQueue>
#include <QSet>
#include <QDebug>

class SmartIODBoxCommand
{
public:
    enum Command {
        pushFile,
        fetchFile,
        pushPaper,
        fetchPaper,
        pushGroups,
        fetchGroups,
        setDeleted
    };

    QString uuid;
    QString path;
    QString dest;
    qint64 revision;
    Command command;
};

class SmartIODBoxPrivate
{
public:
    QString token;
    QString tsecret;
    QString password;

    qreal progress;

    QQueue<SmartIODBoxSingle*> threadsQueue;
    QSet<SmartIODBoxSingle*> threads;

    QQueue<SmartIODBoxCommand> queue;

    int queued_cnt;
    int done_cnt;
};

SmartIODBox::SmartIODBox(QObject *parent) :
    QObject(parent)
{
    p = new SmartIODBoxPrivate;
    p->queued_cnt = 0;
    p->done_cnt = 0;
}

void SmartIODBox::setToken(const QString &t)
{
    if( p->token == t )
        return;

    p->token = t;
    foreach( SmartIODBoxSingle *s, p->threads )
        QMetaObject::invokeMethod(s, __FUNCTION__, Qt::QueuedConnection, Q_ARG(QString,p->token) );

    emit tokenChanged();
}

QString SmartIODBox::token() const
{
    return p->token;
}

void SmartIODBox::setTokenSecret(const QString &s)
{
    if( p->tsecret == s )
        return;

    p->tsecret = s;
    foreach( SmartIODBoxSingle *s, p->threads )
        QMetaObject::invokeMethod(s, __FUNCTION__, Qt::QueuedConnection, Q_ARG(QString,p->tsecret) );

    emit tokenSecret();
}

QString SmartIODBox::tokenSecret() const
{
    return p->tsecret;
}

void SmartIODBox::setPassword(const QString &pass)
{
    if( p->password == pass )
        return;

    p->password = pass;
    foreach( SmartIODBoxSingle *s, p->threads )
        QMetaObject::invokeMethod(s, "setPassword", Qt::QueuedConnection, Q_ARG(QString,p->password) );

    emit passwordChanged();
}

QString SmartIODBox::password() const
{
    return p->password;
}

void SmartIODBox::pushFile(const QString &file, const QString &dest)
{
    SmartIODBoxCommand cmd;
    cmd.path = file;
    cmd.dest = dest;
    cmd.command = SmartIODBoxCommand::pushFile;

    APPEND_TO_QUEUE( cmd );
}

void SmartIODBox::fetchFile(const QString &path, const QString &dest)
{
    SmartIODBoxCommand cmd;
    cmd.path = path;
    cmd.dest = dest;
    cmd.command = SmartIODBoxCommand::fetchFile;

    APPEND_TO_QUEUE( cmd );
}

void SmartIODBox::pushPaper(const QString &uuid, qint64 revision, const QString &dest)
{
    SmartIODBoxCommand cmd;
    cmd.dest = dest;
    cmd.uuid = uuid;
    cmd.revision = revision;
    cmd.command = SmartIODBoxCommand::pushPaper;

    APPEND_TO_QUEUE( cmd );
}

void SmartIODBox::fetchPaper(const QString &uuid, qint64 revision, const QString &path)
{
    SmartIODBoxCommand cmd;
    cmd.path = path;
    cmd.uuid = uuid;
    cmd.revision = revision;
    cmd.command = SmartIODBoxCommand::fetchPaper;

    APPEND_TO_QUEUE( cmd );
}

void SmartIODBox::pushGroups(const QString &path, qint64 revision)
{
    SmartIODBoxCommand cmd;
    cmd.path = path;
    cmd.revision = revision;
    cmd.command = SmartIODBoxCommand::pushGroups;

    APPEND_TO_QUEUE( cmd );
}

void SmartIODBox::fetchGroups(const QString &path, qint64 revision)
{
    SmartIODBoxCommand cmd;
    cmd.path = path;
    cmd.revision = revision;
    cmd.command = SmartIODBoxCommand::fetchGroups;

    APPEND_TO_QUEUE( cmd );
}

void SmartIODBox::setDeleted(const QString &path)
{
    SmartIODBoxCommand cmd;
    cmd.path = path;
    cmd.command = SmartIODBoxCommand::setDeleted;

    APPEND_TO_QUEUE( cmd );
}

qreal SmartIODBox::progress() const
{
    return p->queued_cnt==0? 0 : (qreal)p->done_cnt/p->queued_cnt;
}

bool SmartIODBox::isActive() const
{
    return !p->queue.isEmpty();
}

void SmartIODBox::nextCommand()
{
    if( p->queue.isEmpty() )
        return;

    SmartIODBoxSingle *s = getSingle();
    if( !s )
        return;

    const SmartIODBoxCommand & cmd = p->queue.takeFirst();
    switch( static_cast<int>(cmd.command) )
    {
    case SmartIODBoxCommand::pushPaper:
        QMetaObject::invokeMethod(s, "pushPaper", Qt::QueuedConnection, Q_ARG(QString,cmd.uuid), Q_ARG(qint64,cmd.revision), Q_ARG(QString,cmd.dest) );
        break;
    case SmartIODBoxCommand::fetchPaper:
        QMetaObject::invokeMethod(s, "fetchPaper", Qt::QueuedConnection, Q_ARG(QString,cmd.uuid), Q_ARG(qint64,cmd.revision), Q_ARG(QString,cmd.path) );
        break;
    case SmartIODBoxCommand::pushFile:
        QMetaObject::invokeMethod(s, "pushFile", Qt::QueuedConnection, Q_ARG(QString,cmd.path), Q_ARG(QString,cmd.dest) );
        break;
    case SmartIODBoxCommand::fetchFile:
        QMetaObject::invokeMethod(s, "fetchFile", Qt::QueuedConnection, Q_ARG(QString,cmd.path), Q_ARG(QString,cmd.dest) );
        break;
    case SmartIODBoxCommand::pushGroups:
        QMetaObject::invokeMethod(s, "pushGroups", Qt::QueuedConnection, Q_ARG(QString,cmd.path), Q_ARG(qint64,cmd.revision) );
        break;
    case SmartIODBoxCommand::fetchGroups:
        QMetaObject::invokeMethod(s, "fetchGroups", Qt::QueuedConnection, Q_ARG(QString,cmd.path), Q_ARG(qint64,cmd.revision) );
        break;
    case SmartIODBoxCommand::setDeleted:
        QMetaObject::invokeMethod(s, "setDeleted", Qt::QueuedConnection, Q_ARG(QString,cmd.path) );
        break;
    default:
        p->threadsQueue << s;
    }
}

void SmartIODBox::finished(SmartIODBoxSingle *s)
{
    p->threadsQueue << s;
    nextCommand();
    CLOSE_EXTRA_SINGLES(0)

    p->done_cnt++;
    emit progressChanged(progress());

    if( p->done_cnt >= p->queued_cnt )
    {
        p->done_cnt = 0;
        p->queued_cnt = 0;
        emit progressFinished();
    }
}

SmartIODBoxSingle *SmartIODBox::getSingle()
{
    if( p->threadsQueue.count() != 0 )
        return p->threadsQueue.takeFirst();
    if( p->threads.count() > MAX_ACTIVE_THREAD )
        return 0;

    SmartIODBoxSingle *s = new SmartIODBoxSingle();
    QMetaObject::invokeMethod(s, "setToken", Qt::QueuedConnection, Q_ARG(QString,p->token) );
    QMetaObject::invokeMethod(s, "setTokenSecret", Qt::QueuedConnection, Q_ARG(QString,p->tsecret) );
    QMetaObject::invokeMethod(s, "setPassword", Qt::QueuedConnection, Q_ARG(QString,p->password) );

    connect( s, SIGNAL(finished(SmartIODBoxSingle*))   , SLOT(finished(SmartIODBoxSingle*))     , Qt::QueuedConnection );
    connect( s, SIGNAL(revisionChanged(QString,qint64)), SIGNAL(revisionChanged(QString,qint64)), Qt::QueuedConnection );

    p->threads.insert(s);

    return s;
}

SmartIODBox::~SmartIODBox()
{
    delete p;
}
