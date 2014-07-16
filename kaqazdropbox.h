#ifndef KAQAZDROPBOX_H
#define KAQAZDROPBOX_H
#define TOKEN_KEY      "Token/key"
#define TOKEN_SECRET   "Token/Secret"

#include <QObject>
#include <QStringList>
#include <QHash>

#include "databasedatatypes.h"

class KaqazDropBoxPrivate;
class KaqazDropBox : public QObject
{
    Q_OBJECT
public:
    KaqazDropBox(QObject *parent = 0);
    ~KaqazDropBox();

    bool connected() const;
    bool tokenAvailable() const;

    void setLocalSyncHash( const SyncItemHash & hash );
    SyncItemHash localSyncHash() const;

public slots:
    void initialize();
    void refresh();
    void refreshForce();

    void connectDropbox( const QString & password );
    void disconnectDropbox();

    void authorizeDone();

    void setPassword(const QString & password , const QString &old_password);

signals:
    void connectedChanged();
    void tokenAvailableChanged();

    void authorizeRequest();
    void getTokenFailed();
    void authorizeFailed();
    void accessError( const QString & error );

    void paperDeleted( const QString & id );
    void passwordChanged( const QString & password );

    void refreshRequest();

    void syncStarted();
    void syncProgress( qreal val );
    void syncFinished();

private slots:
    void authorizeApplication();
    void fetch_password( const QString & password );

    QByteArray encryptData(const QByteArray &data );
    QByteArray decryptData( const QByteArray & sdata );

    bool fileIsDeleted( const QString & path );
    void setFileDeleted( const QString & path );

    bool dboxFileIsDeleted( const QString & path );
    void setDboxFileDeleted( const QString & path );

    qint64 fetchRevision( const QString & path );
    void setRevision( const QString & path, qint64 revision );

    void pushRevisions();
    void fetchRevisions();

    bool beginPush( const QString & id );
    bool endPush( const QString & id );

    void localListUpdated();
    void update_finished();

protected:
    void timerEvent(QTimerEvent *e);

private:
    void checkToken();

private:
    KaqazDropBoxPrivate *p;
};

#endif // KAQAZDROPBOX_H
