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

#include "mapcontrol.h"
#include <QTimer>

namespace qmapcontrol
{

    MapControl::MapControl (QWidget * parent, Qt::WindowFlags windowFlags)
    {
        MapControl( QSize(100,100), Panning, false, true, parent, windowFlags);
    }

    MapControl::MapControl(QSize size, MouseMode mousemode, bool showScale, bool showCrosshairs, QWidget * parent, Qt::WindowFlags windowFlags)
        :   QWidget( parent, windowFlags ),
            size(size),
            mymousemode(mousemode),
            scaleVisible(showScale),
            crosshairsVisible(showCrosshairs)
    {
        layermanager = new LayerManager(this, size);
        screen_middle = QPoint(size.width()/2, size.height()/2);

        mousepressed = false;

        connect(ImageManager::instance(), SIGNAL(imageReceived()),
                this, SLOT(updateRequestNew()));

        connect(ImageManager::instance(), SIGNAL(loadingFinished()),
                this, SLOT(loadingFinished()));

        this->setMaximumSize(size.width()+1, size.height()+1);
        mouse_wheel_events = true;
    }

    MapControl::~MapControl()
    {
        delete layermanager;
    }

    void MapControl::enableMouseWheelEvents( bool enabled )
    {
        mouse_wheel_events = enabled;
    }

    bool MapControl::mouseWheelEventsEnabled()
    {
        return mouse_wheel_events;
    }

    QPointF MapControl::currentCoordinate() const
    {
        return layermanager->currentCoordinate();
    }

    Layer* MapControl::layer(const QString& layername) const
    {
        return layermanager->layer(layername);
    }

    QList<QString> MapControl::layers() const
    {
        return layermanager->layers();
    }

    int MapControl::numberOfLayers() const
    {
        return layermanager->layers().size();
    }

    void MapControl::followGeometry(const Geometry* geom) const
    {
        if ( geom == 0 )
        {
            return;
        }

        //ensures only one signal is ever connected
        stopFollowing(geom);

        connect(geom, SIGNAL(positionChanged(Geometry*)),
                this, SLOT(positionChanged(Geometry*)));
    }

    void MapControl::positionChanged(Geometry* geom)
    {
        if ( !layermanager->layer() || !layermanager->layer()->mapadapter() )
        {
            qDebug() << "MapControl::positionChanged() - no layers configured";
            return;
        }

        QPoint start = layermanager->layer()->mapadapter()->coordinateToDisplay(currentCoordinate());
        QPoint dest = layermanager->layer()->mapadapter()->coordinateToDisplay(((Point*)geom)->coordinate());

        QPoint step = (dest-start);

        layermanager->scrollView(step);

        updateRequestNew();
    }

    void MapControl::moveTo(QPointF coordinate)
    {
        target = coordinate;
        steps = 25;
        if (moveMutex.tryLock())
        {
            QTimer::singleShot(40, this, SLOT(tick()));
        }
        else
        {
            // stopMove(coordinate);
            moveMutex.unlock();
        }
    }
    void MapControl::tick()
    {
        if ( !layermanager->layer() || !layermanager->layer()->mapadapter() )
        {
            qDebug() << "MapControl::tick() - no layers configured";
            return;
        }

        QPoint start = layermanager->layer()->mapadapter()->coordinateToDisplay(currentCoordinate());
        QPoint dest = layermanager->layer()->mapadapter()->coordinateToDisplay(target);

        QPoint step = (dest-start)/steps;
        layermanager->scrollView(step);

        update();
        layermanager->updateRequest();
        steps--;
        if (steps>0)
        {
            QTimer::singleShot(40, this, SLOT(tick()));
        }
        else
        {
            moveMutex.unlock();
        }
    }

    void MapControl::paintEvent(QPaintEvent* evnt)
    {
        QWidget::paintEvent(evnt);

        QPainter painter(this);

        // painter.translate(150,190);
        // painter.scale(0.5,0.5);

        // painter.setClipRect(0,0, size.width(), size.height());

        // painter.setViewport(10000000000,0,size.width(),size.height());

        /*
        // rotating
            rotation = 45;
            painter.translate(256,256);
            painter.rotate(rotation);
            painter.translate(-256,-256);
        */

        layermanager->drawImage(&painter);
        layermanager->drawGeoms(&painter);

        // added by wolf
        // draw scale
        if (scaleVisible)
        {
            QList<double> distanceList;
            distanceList<<5000000<<2000000<<1000000<<1000000<<1000000<<100000<<100000<<50000<<50000<<10000<<10000<<10000<<1000<<1000<<500<<200<<100<<50<<25;
            if (currentZoom() >= 0 && distanceList.size() > currentZoom())
            {
                double line;
                line = distanceList.at( currentZoom() ) / pow(2.0, 18-currentZoom() ) / 0.597164;

                // draw the scale
                painter.setPen(Qt::black);
                QPoint p1(10,size.height()-20);
                QPoint p2((int)line,size.height()-20);
                painter.drawLine(p1,p2);

                painter.drawLine(10,size.height()-15, 10,size.height()-25);
                painter.drawLine((int)line,size.height()-15, (int)line,size.height()-25);

                QString distance;
                if (distanceList.at(currentZoom()) >= 1000)
                {
                    distance = QVariant( distanceList.at(currentZoom())/1000 )  .toString()+ " km";
                }
                else
                {
                    distance = QVariant( distanceList.at(currentZoom()) ).toString() + " m";
                }

                painter.drawText(QPoint((int)line+10,size.height()-15), distance);
            }
        }

        if (crosshairsVisible)
        {
            painter.drawLine(screen_middle.x(), screen_middle.y()-10,
                             screen_middle.x(), screen_middle.y()+10); // |
            painter.drawLine(screen_middle.x()-10, screen_middle.y(),
                             screen_middle.x()+10, screen_middle.y()); // -
        }

        // int cross_x = int(layermanager->getMapmiddle_px().x())%256;
        // int cross_y = int(layermanager->getMapmiddle_px().y())%256;
        // painter.drawLine(screen_middle.x()-cross_x+cross_x, screen_middle.y()-cross_y+0,
        //   screen_middle.x()-cross_x+cross_x, screen_middle.y()-cross_y+256); // |
        // painter.drawLine(screen_middle.x()-cross_x+0, screen_middle.y()-cross_y+cross_y,
        //   screen_middle.x()-cross_x+256, screen_middle.y()-cross_y+cross_y); // -

        painter.drawRect(0,0, size.width(), size.height());
        /*
        // rotating
          painter.setMatrix(painter.matrix().inverted());
        //qt = painter.transform();
           qm = painter.combinedMatrix();
        */

        if (mousepressed && mymousemode == Dragging)
        {
            QRect rect = QRect(pre_click_px, current_mouse_pos);
            painter.drawRect(rect);
        }
        //emit viewChanged(currentCoordinate(), currentZoom());
    }

    // mouse events
    void MapControl::mousePressEvent(QMouseEvent* evnt)
    {
        //rotating (experimental)
        // QMouseEvent* me = new QMouseEvent(evnt->type(), qm.map(QPoint(evnt->x(),evnt->y())), evnt->button(), evnt->buttons(), evnt->modifiers());
        // evnt = me;
        // qDebug() << "evnt: " << evnt->x() << ", " << evnt->y() << ", " << evnt->pos();

        layermanager->mouseEvent(evnt);

        if (layermanager->layers().size()>0)
        {
            if (evnt->button() == 1)
            {
                mousepressed = true;
                pre_click_px = QPoint(evnt->x(), evnt->y());
            }
            else if ( evnt->button() == 2  &&
                      mouseWheelEventsEnabled() &&
                      mymousemode != None) // zoom in
            {
                zoomIn();
            }
            else if  ( evnt->button() == 4 &&
                         mouseWheelEventsEnabled() &&
                         mymousemode != None) // zoom out
            {
                zoomOut();
            }
        }

        // emit(mouseEvent(evnt));
        emit(mouseEventCoordinate(evnt, clickToWorldCoordinate(evnt->pos())));
    }

    void MapControl::mouseReleaseEvent(QMouseEvent* evnt)
    {
        mousepressed = false;
        if (mymousemode == Dragging)
        {
            QPointF ulCoord = clickToWorldCoordinate(pre_click_px);
            QPointF lrCoord = clickToWorldCoordinate(current_mouse_pos);

            QRectF coordinateBB = QRectF(ulCoord, QSizeF( (lrCoord-ulCoord).x(), (lrCoord-ulCoord).y()));

            emit(boxDragged(coordinateBB));
        }

        emit(mouseEventCoordinate(evnt, clickToWorldCoordinate(evnt->pos())));
    }

    void MapControl::mouseMoveEvent(QMouseEvent* evnt)
    {
        // emit(mouseEvent(evnt));

        /*
        // rotating
           QMouseEvent* me = new QMouseEvent(evnt->type(), qm.map(QPoint(evnt->x(),evnt->y())), evnt->button(), evnt->buttons(), evnt->modifiers());
           evnt = me;
        */
        if (mousepressed && mymousemode == Panning)
        {
            QPoint offset = pre_click_px - QPoint(evnt->x(), evnt->y());
            layermanager->scrollView(offset);
            pre_click_px = QPoint(evnt->x(), evnt->y());
        }
        else if (mousepressed && mymousemode == Dragging)
        {
            current_mouse_pos = QPoint(evnt->x(), evnt->y());
        }

        update();
    }

    void MapControl::wheelEvent(QWheelEvent *evnt)
    {
        if(mouse_wheel_events &&
            evnt->orientation() == Qt::Vertical)
        {
            if(evnt->delta() > 0)
            {
                if( currentZoom() == 17 )
                {
                    return;
                }

                setView(clickToWorldCoordinate(evnt->pos())); //zoom in under mouse cursor
                zoomIn();
            }
            else
            {
                if( currentZoom() == 0 )
                {
                    return;
                }
                zoomOut();
            }
            evnt->accept();
        }
        else
        {
            evnt->ignore();
        }
    }

    QPointF MapControl::clickToWorldCoordinate(QPoint click)
    {
        if ( !layermanager->layer() || !layermanager->layer()->mapadapter() )
        {
            qDebug() << "MapControl::clickToWorldCoordinate() - no layers configured";
            return QPointF();
        }
        // click coordinate to image coordinate
        QPoint displayToImage= QPoint(click.x()-screen_middle.x()+layermanager->getMapmiddle_px().x(),
                                      click.y()-screen_middle.y()+layermanager->getMapmiddle_px().y());

        // image coordinate to world coordinate
        return layermanager->layer()->mapadapter()->displayToCoordinate(displayToImage);
    }

    void MapControl::updateRequest(QRect rect)
    {
        update(rect);
    }

    void MapControl::updateRequestNew()
    {
        layermanager->forceRedraw();
    }

    // slots
    void MapControl::zoomIn()
    {
        if( currentZoom() == 17 )
        {
            return;
        }

        layermanager->zoomIn();
        updateView();
        emit viewChanged(currentCoordinate(), currentZoom());
    }

    void MapControl::zoomOut()
    {
        if( currentZoom() == 0 )
        {
            return;
        }

        layermanager->zoomOut();
        updateView();
        emit viewChanged(currentCoordinate(), currentZoom());
    }

    void MapControl::setZoom(int zoomlevel)
    {
        if ( currentZoom() == zoomlevel ||
             zoomlevel < 0 ||
             zoomlevel > 17 )
        {
            return;
        }

        layermanager->setZoom(zoomlevel);
        updateView();
        emit viewChanged(currentCoordinate(), currentZoom());
    }

    int MapControl::currentZoom() const
    {
        return layermanager->currentZoom();
    }

    void MapControl::scrollLeft(int pixel)
    {
        layermanager->scrollView(QPoint(-pixel,0));
        updateView();
    }

    void MapControl::scrollRight(int pixel)
    {
        layermanager->scrollView(QPoint(pixel,0));
        updateView();
    }

    void MapControl::scrollUp(int pixel)
    {
        layermanager->scrollView(QPoint(0,-pixel));
        updateView();
    }

    void MapControl::scrollDown(int pixel)
    {
        layermanager->scrollView(QPoint(0,pixel));
        updateView();
    }

    void MapControl::scroll(const QPoint scroll)
    {
        layermanager->scrollView(scroll);
        updateView();
    }

    void MapControl::updateView() const
    {
        layermanager->setView( currentCoordinate() );
        emit viewChanged(currentCoordinate(), currentZoom());
    }

    void MapControl::setView(const QPointF& coordinate) const
    {
        layermanager->setView(coordinate);
        emit viewChanged(currentCoordinate(), currentZoom());
    }

    void MapControl::setView(const QList<QPointF> coordinates) const
    {
        layermanager->setView(coordinates);
        emit viewChanged(currentCoordinate(), currentZoom());
    }

    void MapControl::setViewAndZoomIn(const QList<QPointF> coordinates) const
    {
        layermanager->setViewAndZoomIn(coordinates);
        emit viewChanged(currentCoordinate(), currentZoom());
    }

    void MapControl::setView(const Point* point) const
    {
        layermanager->setView(point->coordinate());
    }

    void MapControl::loadingFinished()
    {
        // qDebug() << "MapControl::loadingFinished()";
        layermanager->removeZoomImage();
    }
    void MapControl::addLayer(Layer* layer)
    {
        layermanager->addLayer(layer);
        update();
    }

    void MapControl::removeLayer( Layer* layer )
    {
        disconnect(layer, 0, 0, 0);
        layermanager->removeLayer( layer );
        update();
    }

    void MapControl::setMouseMode(MouseMode mousemode)
    {
        mymousemode = mousemode;
    }

    MapControl::MouseMode MapControl::mouseMode()
    {
        return mymousemode;
    }

    void MapControl::stopFollowing(const Geometry* geom) const
    {
        disconnect(geom,SIGNAL(positionChanged(Geometry*)), this, SLOT(positionChanged(Geometry*)));
    }

    void MapControl::enablePersistentCache( int tileExpiry, const QDir& path)
    {
        ImageManager::instance()->setCacheDir(tileExpiry, path);
    }

    void MapControl::setProxy(QString host, int port, const QString username, const QString password)
    {
        ImageManager::instance()->setProxy(host, port, username, password);
    }

    void MapControl::showScale(bool visible)
    {
        scaleVisible = visible;
    }

    void MapControl::showCrosshairs(bool visible)
    {
        crosshairsVisible = visible;
    }

    void MapControl::resize(const QSize newSize)
    {
        this->size = newSize;
        screen_middle = QPoint(newSize.width()/2, newSize.height()/2);

        this->setMaximumSize(newSize.width()+1, newSize.height()+1);
        layermanager->resize(newSize);

        emit viewChanged(currentCoordinate(), currentZoom());
    }

   void MapControl::setUseBoundingBox( bool usebounds )
   {
        if( layermanager )
            layermanager->setUseBoundingBox( usebounds );
   }

   bool MapControl::isBoundingBoxEnabled()
   {
        if( layermanager )
            return layermanager->isBoundingBoxEnabled();
        return false;
   }

   void MapControl::setBoundingBox( QRectF &rect )
   {
        if( layermanager )
            layermanager->setBoundingBox( rect );
   }

   QRectF MapControl::getBoundingBox()
   {
        if( layermanager )
            return layermanager->getBoundingBox();

        // Return an empty QRectF if there is no layermanager
        return QRectF();
   }

   QRectF MapControl::getViewport()
   {
       if( layermanager )
           return layermanager->getViewport();

       // Return an empty QRectF if there is no layermanager
       return QRectF();
   }

   bool MapControl::isGeometryVisible( Geometry * geometry)
   {
       if ( !geometry || getViewport() == QRectF() )
           return false;

       return getViewport().contains( geometry->boundingBox() );
   }
}
