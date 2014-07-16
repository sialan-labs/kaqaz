#include "sialanqtlogger.h"

#include <QDebug>
#include <QFile>
#include <QDateTime>

QSet<SialanQtLogger*> sialan_qt_logger_objs;

void sialanQtLoggerFnc(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    foreach( SialanQtLogger *obj, sialan_qt_logger_objs )
        obj->logMsg(type,context,msg);
}

class SialanQtLoggerPrivate
{
public:
    QFile *file;
};

SialanQtLogger::SialanQtLogger(const QString &path, QObject *parent) :
    QObject(parent)
{
    p = new SialanQtLoggerPrivate;
    p->file = new QFile(path);
    p->file->open(QFile::WriteOnly);

    sialan_qt_logger_objs.insert(this);
    if( sialan_qt_logger_objs.count() == 1 )
        qInstallMessageHandler(sialanQtLoggerFnc);
}

void SialanQtLogger::logMsg(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    QByteArray localMsg = msg.toLocal8Bit();
    QString text = QString(": (%2:%3, %4) %5 : %1\n").arg(localMsg.constData()).arg(context.file).arg(context.line).arg(context.function).arg(QTime::currentTime().toString());

    switch (type) {
    case QtDebugMsg:
        text = "Debug" + text;
        p->file->write(text.toUtf8());
        p->file->flush();
        break;
    case QtWarningMsg:
        text = "Warning" + text;
        p->file->write(text.toUtf8());
        p->file->flush();
        break;
    case QtCriticalMsg:
        text = "Critical" + text;
        p->file->write(text.toUtf8());
        p->file->flush();
        break;
    case QtFatalMsg:
        text = "Fatal" + text;
        p->file->write(text.toUtf8());
        p->file->flush();
        abort();
    }
}

void SialanQtLogger::debug(const QVariant &var)
{
    qDebug() << var;
}

SialanQtLogger::~SialanQtLogger()
{
    sialan_qt_logger_objs.remove(this);
    if( sialan_qt_logger_objs.isEmpty() )
        qInstallMessageHandler(0);

    delete p;
}
