#ifndef SIALANQTLOGGER_H
#define SIALANQTLOGGER_H

#include <QObject>

class SialanQtLoggerPrivate;
class SialanQtLogger : public QObject
{
    Q_OBJECT
public:
    SialanQtLogger(const QString & path, QObject *parent = 0);
    ~SialanQtLogger();

    virtual void logMsg(QtMsgType type , const QMessageLogContext &context, const QString &msg);

public slots:
    void debug( const QVariant & var );

private:
    SialanQtLoggerPrivate *p;
};

#endif // SIALANQTLOGGER_H
