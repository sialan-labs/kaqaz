#ifndef DATABASEDATATYPES_H
#define DATABASEDATATYPES_H

#include <QDateTime>
#include <QColor>
#include <QStringList>

class GroupClass
{
public:
    int id;
    QString name;
    QColor color;
    QString uuid;

    bool operator ==(const GroupClass & g) const {
        return (g.id == id && g.name == name && g.color == color && g.uuid == uuid);
    }
};

class ActivityClass
{
public:
    int id;
    QString name;
    QString description;
    QString image;
};

class PaperClass
{
public:
    PaperClass(){
        id = -1;
    }

    int id;
    QString uuid;
    QString title;
    QString text;
    QDateTime create;
    QDateTime modified;
    int group;
    int activity;
    QStringList files;
};

class SyncItem
{
public:
    SyncItem(){
        revision = -1;
        last_revision = -1;
    }

    QString id;
    int revision;
    int last_revision;
};

typedef QHash<QString,SyncItem> SyncItemHash;

Q_DECLARE_METATYPE( SyncItem )
Q_DECLARE_METATYPE( SyncItemHash )

#endif // DATABASEDATATYPES_H
