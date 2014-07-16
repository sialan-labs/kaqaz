#ifndef REPOSITORY_H
#define REPOSITORY_H

#include <QObject>

class Kaqaz;
class RepositoryPrivate;
class Repository : public QObject
{
    Q_OBJECT
public:
    Repository( Kaqaz *kaqaz );
    ~Repository();

    Q_INVOKABLE QString insert( const QString & path );
    Q_INVOKABLE QString getPath( const QString & id );
    Q_INVOKABLE QString repositoryPath();

    Q_INVOKABLE QString copyImageToRepository(const QString & path, int size );
    Q_INVOKABLE QString copyAudioToRepository(const QString & path );

public slots:
    void deleteFile( const QString & f );

private:
    QString generateID( const QString & path );

private:
    RepositoryPrivate *p;
};

#endif // REPOSITORY_H
