#ifndef RESOURCEMANAGER_H
#define RESOURCEMANAGER_H

#include <QString>

class ResourceManagerPrivate;
class ResourceManager
{
public:
    ResourceManager(const QString & path, bool writeMode = false );
    ~ResourceManager();

    void addFile(const QString & filePath , const QString &password = QString());
    QString extractFile(const QString & filePath , const QString &password = QString());

    void writeHead( const QString & password = QString() );
    bool checkHead( const QString & password = QString() );

    void close();

    qint64 size();
    qint64 currentPosition();

private:
    ResourceManagerPrivate *p;
};

#endif // RESOURCEMANAGER_H
