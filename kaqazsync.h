#ifndef KAQAZSYNC_H
#define KAQAZSYNC_H

#include <QObject>

class KaqazSyncPrivate;
class KaqazSync : public QObject
{
    Q_PROPERTY(bool tokenAvailable READ tokenAvailable NOTIFY tokenAvailableChanged)
    Q_PROPERTY(QString password READ password NOTIFY passwordChanged)
    Q_OBJECT
public:
    KaqazSync(class Database *db, QObject *parent = 0);
    ~KaqazSync();

    bool tokenAvailable() const;

    QString password() const;

public slots:
    void start();
    void stop();
    void reload();
    void authorizeDone();
    void setPassword( const QString & pass );

signals:
    void authorizeRequest();

    void syncStarted();
    void syncProgress( qreal val );
    void syncFinished();

    void tokenAvailableChanged();
    void passwordChanged();

private slots:
    void password_changed( const QString & password );
    void paperDeleted( const QString & id );

    void connectedChanged();

    void refresh();
    void refreshForce();

private:
    KaqazSyncPrivate *p;
};

#endif // KAQAZSYNC_H
