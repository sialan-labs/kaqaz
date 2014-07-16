#include "repository.h"
#include "kaqaz.h"

#include <QDir>
#include <QCryptographicHash>
#include <QFileInfo>
#include <QFile>
#include <QDateTime>
#include <QDate>
#include <QImage>
#include <QImageReader>
#include <QImageWriter>
#include <QDebug>

class RepositoryPrivate
{
public:
    Kaqaz *kaqaz;
};

Repository::Repository(Kaqaz *kaqaz) :
    QObject(kaqaz)
{
    p = new RepositoryPrivate;
    p->kaqaz = kaqaz;
}

QString Repository::insert(const QString &fp)
{
    QString path = fp.left(7) == "file://"? fp.mid(7) : fp;
    QString id = generateID(path);
    QString dest = p->kaqaz->repositoryPath() + "/" + id;

    if( QFile::exists(dest) )
        return id;

    QFile::copy( path, dest );
    return id;
}

QString Repository::getPath(const QString &id)
{
    return p->kaqaz->repositoryPath() + "/" + id;
}

QString Repository::repositoryPath()
{
    return p->kaqaz->repositoryPath();
}

QString Repository::copyImageToRepository(const QString &path, int size)
{
    const QString & id = generateID( path );
    const QString & dest_path = getPath( id );
    if( QFile::exists(dest_path) )
        return id;

    QImageReader reader(path);

    QSize dest_size = reader.size();
    if( dest_size.width() > dest_size.height() )
    {
        if( dest_size.width() < size )
            size = dest_size.width();

        dest_size.setHeight( size*dest_size.height()/dest_size.width() );
        dest_size.setWidth( size );
    }
    else
    {
        if( dest_size.height() < size )
            size = dest_size.height();

        dest_size.setWidth( size*dest_size.width()/dest_size.height() );
        dest_size.setHeight( size );
    }

    QImage img = reader.read();
    img = img.scaled( dest_size, Qt::IgnoreAspectRatio, Qt::SmoothTransformation );

    QImageWriter writer( dest_path );
    writer.write( img );

    return id;
}

QString Repository::copyAudioToRepository(const QString &path)
{
    return insert(path);
}

void Repository::deleteFile(const QString &f)
{
    const QString & path = getPath(f);

    QFile file(path);
    file.remove();

    if( !file.open(QFile::WriteOnly) )
        return;

    file.write("DELETED");
    file.flush();
    file.close();
}

QString Repository::generateID(const QString &path)
{
    QFileInfo file(path);
    QString hidden_text = path + " " + QString::number(file.size()) +  " " +
                          file.created().toString("yyyy/MM/dd hh:mm:ss:zzz") + " " +
                          file.lastModified().toString("yyyy/MM/dd hh:mm:ss:zzz");

    QString id = QCryptographicHash::hash(hidden_text.toUtf8(),QCryptographicHash::Md5).toHex() + "." + file.suffix();
    return id;
}

Repository::~Repository()
{
    delete p;
}
