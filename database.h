#ifndef DATABASE_H
#define DATABASE_H

#define GROUPS_SYNC_KEY "Groups"
#define NO_GROUP_UUID   "{47e4f990-c3db-4077-bb22-81172160986b}"

#include "databasedatatypes.h"

#include <QObject>
#include <QDate>
#include <QList>

class DatabasePrivate;
class Database : public QObject
{
    Q_OBJECT
public:
    Database(const QString & path, QObject *parent = 0);
    ~Database();

    Q_INVOKABLE void connect();
    Q_INVOKABLE void disconnect();

    Q_INVOKABLE void setPath( const QString & path );
    Q_INVOKABLE QString path() const;

    Q_INVOKABLE void setCurrentActivity( int activity );
    Q_INVOKABLE int currentActivity() const;

    Q_INVOKABLE QList<int> dates();
    Q_INVOKABLE QList<int> lastThreeDays();

    Q_INVOKABLE int papersCountOf( const QDate & date );
    Q_INVOKABLE QList<int> papersOf( const QDate & date );
    Q_INVOKABLE QList<int> papersOf( int group_id );
    Q_INVOKABLE QList<int> search(const QString & keyword );

    Q_INVOKABLE int createPaper(const QString &uuid = QString());
    Q_INVOKABLE void deletePaper( int id );

    Q_INVOKABLE void setPaper(int id, const QString & title, const QString & text, int group );
    Q_INVOKABLE void setPaper(int id, const QString & title, const QString & text );
    Q_INVOKABLE void setPaper(int id, const QString & title, int group );

    Q_INVOKABLE void setPaper( const QString & uuid, const QString & title, const QString & text, const QString & group, const QString & date );

    Q_INVOKABLE QString paperTitle( int id );
    Q_INVOKABLE void setPaperTitle( int id, const QString & title );

    Q_INVOKABLE QString paperText( int id );
    Q_INVOKABLE void setPaperText( int id, const QString & text );

    Q_INVOKABLE int paperGroup( int id );
    Q_INVOKABLE void setPaperGroup( int id, int group );

    Q_INVOKABLE QDateTime paperCreatedDate( int id );
    Q_INVOKABLE QDateTime paperModifiedDate( int id );
    Q_INVOKABLE QString paperUuid( int id );
    Q_INVOKABLE int paperActivity( int id );
    Q_INVOKABLE int paperUuidId( const QString & uuid );

    Q_INVOKABLE QStringList paperFiles( int id );
    Q_INVOKABLE bool hasFiles( int id );
    Q_INVOKABLE void addFileToPaper( int id, const QString & file );
    Q_INVOKABLE void removeFileFromPaper( int id, const QString & file );
    Q_INVOKABLE bool fileContaintOnDatabase( const QString & file );

    Q_INVOKABLE QList<int> groups();
    Q_INVOKABLE bool groupIsDeleted( int id );
    Q_INVOKABLE int createGroup(const QString &uuid = QString());
    Q_INVOKABLE void deleteGroup( int id );
    Q_INVOKABLE void setGroup( const QString & uuid, const QString & name, const QString & color );

    Q_INVOKABLE QString groupName( int id );
    Q_INVOKABLE void setGroupName( int id, const QString & name );

    Q_INVOKABLE QColor groupColor( int id );
    Q_INVOKABLE void setGroupColor(int id , const QColor &color);

    Q_INVOKABLE QString groupUuid( int id );
    Q_INVOKABLE int groupUuidId( const QString & uuid );

    Q_INVOKABLE QList<int> activities();

    Q_INVOKABLE QString password();
    Q_INVOKABLE void setPassword( const QString & pass );

    Q_INVOKABLE QString syncPassword();
    Q_INVOKABLE void setSyncPassword( const QString & pass );

    Q_INVOKABLE QString value( const QString & property );
    Q_INVOKABLE void setValue( const QString & property, const QString & value );

    Q_INVOKABLE int statePapersCount();
    Q_INVOKABLE int stateDatesCount();
    Q_INVOKABLE int stateGroupsCount();

    Q_INVOKABLE void setRevision( const QString & id, int revision );
    Q_INVOKABLE SyncItemHash revisions() const;

public slots:
    void setSignalBlocker( int stt );

    void begin();
    void commit();

signals:
    void currentActivityChanged();
    void groupsListChanged();
    void datesListChanged();
    void activityListChanged();
    void revisionsChanged();
    void filesListChanged();

    void paperChanged( int id );
    void fileDeleted( const QString & file );

private:
    void reinit_buffer();

    PaperClass getPaper( int id );
    void savePaper(PaperClass paper);
    void saveGroup(GroupClass group);
    void saveActivity(ActivityClass activity);

protected:
    void timerEvent(QTimerEvent *e);

private:
    DatabasePrivate *p;
};

#endif // DATABASE_H
