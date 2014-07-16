#ifndef MIMEAPPS_H
#define MIMEAPPS_H

#include <QObject>
#include <QStringList>

class MimeAppsPrivate;
class MimeApps: public QObject
{
    Q_OBJECT
public:
    MimeApps( QObject *parent = 0 );
    ~MimeApps();

    Q_INVOKABLE QStringList appsOfMime( const QString & mime );
    Q_INVOKABLE QStringList appsOfFile( const QString & file );

    Q_INVOKABLE QString appName( const QString & app ) const;
    Q_INVOKABLE QString appIcon( const QString & app ) const;
    Q_INVOKABLE QString appGenericName( const QString & app ) const;
    Q_INVOKABLE QString appComment( const QString & app ) const;
    Q_INVOKABLE QString appPath( const QString & app ) const;
    Q_INVOKABLE QString appCommand( const QString & app ) const;
    Q_INVOKABLE QStringList appMimes( const QString & app ) const;

public slots:
    void openFiles( const QString & app, const QStringList & files );

private:
    MimeAppsPrivate *p;
};

#endif // MIMEAPPS_H
