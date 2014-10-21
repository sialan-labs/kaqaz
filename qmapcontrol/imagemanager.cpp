/*
*
* This file is part of QMapControl,
* an open-source cross-platform map widget
*
* Copyright (C) 2007 - 2008 Kai Winter
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with QMapControl. If not, see <http://www.gnu.org/licenses/>.
*
* Contact e-mail: kaiwinter@gmx.de
* Program URL   : http://qmapcontrol.sourceforge.net/
*
*/

#include "imagemanager.h"
#include <QCryptographicHash>
#include <QPainter>
#include <QDateTime>

static const int kDefaultTimeoutDelaySecs = 30;
static const int kDefaultPixmapCacheSizeKB = 20000;

namespace qmapcontrol
{
    ImageManager* ImageManager::m_Instance = 0;
    ImageManager::ImageManager(QObject* parent)
            : QObject(parent),
              emptyPixmap(QPixmap(1,1)),
              loadingPixmap(QPixmap(256,256)),
              net(new MapNetwork(this)),
              doPersistentCaching(false)
    {
        emptyPixmap.fill(Qt::transparent);
        
        //initialize loading image
        loadingPixmap.fill( Qt::white );
        QPainter paint(&loadingPixmap);
        QBrush brush( Qt::lightGray, Qt::Dense5Pattern );
        paint.fillRect(loadingPixmap.rect(), brush );
        
        brush.setColor( Qt::black );
        paint.drawText( 10, 10, "LOADING..." );

        paint.end();

        if (QPixmapCache::cacheLimit() <= kDefaultPixmapCacheSizeKB)
        {
            QPixmapCache::setCacheLimit(kDefaultPixmapCacheSizeKB);
        }
    }

    ImageManager::~ImageManager()
    {
        if (ImageManager::m_Instance != 0)
        {
            delete ImageManager::m_Instance;
        }
        delete net;
    }

    QPixmap ImageManager::getImage(const QString& host, const QString& url)
    {
        //qDebug() << "ImageManager::getImage";
        QPixmap pm;

        if ( net->imageIsLoading(url) )
        {
            //currently loading an image
            return loadingPixmap;
        }
        else if ( QPixmapCache::find( md5hex(url), &pm) )
        {
           //image found in cache, use this version
            return pm;
        }
        else if ( doPersistentCaching ) //image disk-caching (persistent) enabled 
                  
        {
            if ( tileExist(url) && 
                  !tileCacheExpired(url) )
            {
                loadTile(url,pm);
                QPixmapCache::insert(md5hex(url), pm);
                return pm;
            }
            else
            {
                //no file yet, go and request an image
                net->loadImage(host, url);
            }
        }
        //is image cached (memory)
        else if ( QPixmapCache::find(md5hex(url), &pm) && 
                  !pm.isNull() )
        {
            //we had a valid copy cached in memory (not disk) so return this
            return pm;
        }
        else if ( failedFetches.contains(url) &&
                  failedFetches[url].secsTo(QDateTime::currentDateTime()) < kDefaultTimeoutDelaySecs )
        {
            //prevents spamming public servers when requests fail to return an image or server returns error code (busy/ivalid useragent etc)
            qDebug() << "Ignored: " << url << " - last request failed less than 30 seconds ago";
        }
        else
        {
            //load from net, add empty image
            net->loadImage(host, url);
        }
        return emptyPixmap;
    }

    QPixmap ImageManager::prefetchImage(const QString& host, const QString& url)
    {
        // TODO See if this actually helps on the N900 & Symbian Phones
#if defined Q_WS_QWS || defined Q_WS_MAEMO_5 || defined Q_WS_S60
        // on mobile devices we don´t want the display refreshing when tiles are received which are
        // prefetched... This is a performance issue, because mobile devices are very slow in
        // repainting the screen
        prefetch.append(url);
#endif
        return getImage(host, url);
    }

    void ImageManager::receivedImage(const QPixmap pixmap, const QString& url)
    {
        //qDebug() << "ImageManager::receivedImage";
        QPixmapCache::insert(md5hex(url), pixmap);

        //remove from failed list (if exists) as it has now come good
        if (failedFetches.contains(url))
        {
            failedFetches.remove(url);
        }

        if (doPersistentCaching && !tileExist(url))
        {
            saveTile(url,pixmap);
        }

        if (!prefetch.contains(url))
        {
            emit(imageReceived());
        }
        else
        {

#if defined Q_WS_QWS || defined Q_WS_MAEMO_5 || defined Q_WS_S60
            prefetch.remove(prefetch.indexOf(url));
#endif
        }
    }

    QString ImageManager::md5hex( QString qUrl )
    {
        return QString( QCryptographicHash::hash( qUrl.toUtf8(), QCryptographicHash::Md5).toHex() );
    }

    void ImageManager::loadingQueueEmpty()
    {
        emit(loadingFinished());
        //((Layer*)this->parent())->removeZoomImage();
        //qDebug() << "size of image-map: " << images.size();
        //qDebug() << "size: " << QPixmapCache::cacheLimit();
    }

    void ImageManager::abortLoading()
    {
        net->abortLoading();
    }

    void ImageManager::setProxy(QString host, int port, const QString username, const QString password)
    {
        net->setProxy(host, port, username, password);
    }

    void ImageManager::setCacheDir(int expiry, const QDir& path)
    {
        doPersistentCaching = true;
        cachedTileExpiry = expiry;
        cacheDir = path;
        if (!cacheDir.exists())
        {
            cacheDir.mkpath(cacheDir.absolutePath());
        }
    }

    bool ImageManager::saveTile(QString tileName,QPixmap tileData)
    {
        tileName.replace("/","-");

        QFile file(cacheDir.absolutePath() + "/" + md5hex(tileName) );

        //qDebug() << "writing: " << file.fileName();
        if (!file.open(QIODevice::ReadWrite )){
            qDebug()<<"error reading file";
            return false;
        }
        QByteArray bytes;
        QBuffer buffer(&bytes);
        buffer.open(QIODevice::WriteOnly);
        tileData.save(&buffer, "PNG");

        file.write(bytes);
        file.close();
        return true;
    }
    bool ImageManager::loadTile(QString tileName,QPixmap &tileData)
    {
        tileName.replace("/","-");
        QFile file(cacheDir.absolutePath() + "/" + md5hex(tileName) );
        if (!file.open(QIODevice::ReadOnly )) {
            return false;
        }
        tileData.loadFromData( file.readAll() );

        file.close();
        return true;
    }

    bool ImageManager::tileCacheExpired(QString tileName)
    {
        tileName.replace("/","-");
        QFile file(cacheDir.absolutePath() + "/" + md5hex(tileName) );
        if (file.exists() && cachedTileExpiry > 0)
        {
            QFileInfo fileInfo( file );
            if ( fileInfo.lastModified().msecsTo( QDateTime::currentDateTime() ) > ( cachedTileExpiry * 1000 * 60 ) )
            {
                cacheDir.remove( file.fileName() );
                return true;
            }
        }
        return false;
    }

    bool ImageManager::tileExist(QString tileName)
    {
        tileName.replace("/","-");
        QFile file(cacheDir.absolutePath() + "/" + md5hex(tileName) );
        if (file.exists())
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    int ImageManager::loadQueueSize() const
    {
        return net->loadQueueSize();
    }

    void qmapcontrol::ImageManager::fetchFailed(const QString &url)
    {
        qDebug() << "ImageManager::fetchFailed" << url;

        //store current time for this failed image to prevent loading it again until
        failedFetches.insert(url, QDateTime::currentDateTime());
    }

}
