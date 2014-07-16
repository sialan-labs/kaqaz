#ifndef BACKUPER_H
#define BACKUPER_H

#include <QObject>

class Kaqaz;
class BackuperPrivate;
class Backuper : public QObject
{
    Q_OBJECT
public:
    Backuper( Kaqaz *kaqaz );
    ~Backuper();

public slots:
    void makeBackup(const QString &password = QString());
    bool restore(const QString & path , const QString &password = QString());

signals:
    void success();
    void failed();
    void progress( int percent );

private:
    BackuperPrivate *p;
};

class BackuperCorePrivate;
class BackuperCore : public QObject
{
    Q_OBJECT
public:
    BackuperCore( Kaqaz *kaqaz );
    ~BackuperCore();

public slots:
    void makeBackup(const QString & repository_path, const QString & db_path, const QString &cnf_path, const QString &password);
    void restore(const QString & repository_path, const QString & home_path, const QString & path , const QString &password);

signals:
    void success();
    void failed();
    void progress( int percent );

private:
    BackuperCorePrivate *p;
};

#endif // BACKUPER_H
