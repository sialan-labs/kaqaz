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

#include "layer.h"
namespace qmapcontrol
{
Layer::Layer()
    :visible(true), mylayertype(MapLayer), mymapadapter(0), takeevents(true), myoffscreenViewport(QRect(0,0,0,0))
{

}

Layer::Layer(QString layername, MapAdapter* mapadapter, enum LayerType layertype, bool takeevents)
            :visible(true), mylayername(layername), mylayertype(layertype), mymapadapter(mapadapter), takeevents(takeevents), myoffscreenViewport(QRect(0,0,0,0))
    {
        //qDebug() << "creating new Layer: " << layername << ", type: " << contents;
        //qDebug() << this->layertype;
    }

    Layer::~Layer()
    {
        if( mymapadapter )
            delete mymapadapter;
    }

    void Layer::setSize(QSize size)
    {
        this->size = size;
        screenmiddle = QPoint(size.width()/2, size.height()/2);
        //QMatrix mat;
        //mat.translate(480/2, 640/2);
        //mat.rotate(45);
        //mat.translate(-480/2,-640/2);
        //screenmiddle = mat.map(screenmiddle);

        emit(updateRequest());
    }

    QString Layer::layerName() const
    {
        return mylayername;
    }

    void Layer::setLayerName(const QString &ln)
    {
        if( mylayername == ln )
            return;

        mylayername = ln;
        emit layerNameChanged();
    }

    MapAdapter* Layer::mapAdapter()
    {
        return mymapadapter;
    }

    void Layer::setMapAdapter(MapAdapter* mapadapter)
    {
        if( mymapadapter == mapadapter )
            return;

        mymapadapter = mapadapter;
        emit updateRequest();
        emit mapAdapterChanged();
    }

    QObject *Layer::mapAdapterObject()
    {
        return mapAdapter();
    }

    void Layer::setMapAdapterObject(QObject *mapAdapter)
    {
        setMapAdapter( static_cast<MapAdapter*>(mapAdapter) );
    }

    QObject *Layer::layerObject()
    {
        return this;
    }

    void Layer::setVisible(bool visible)
    {
        this->visible = visible;
        emit(updateRequest());
    }

    QList<Geometry*> Layer::getGeometries()
    {
        return geometries;
    }

    bool Layer::containsGeometry( Geometry* geometry )
    {
        return geometry && geometries.contains( geometry );
    }

    void Layer::addGeometry(Geometry* geom)
    {
        if ( !geom || containsGeometry( geom ) )
        {
            return;
        }
        //qDebug() << geom->getName() << ", " << geom->getPoints().at(0)->getWidget();

        geometries.append(geom);
        emit(updateRequest(geom->boundingBox()));
        //a geometry can request a redraw, e.g. when its position has been changed
        connect(geom, SIGNAL(updateRequest(QRectF)),
                this, SIGNAL(updateRequest(QRectF)));
    }

    void Layer::removeGeometry(Geometry* geometry, bool qDeleteObject)
    {
        if ( !geometry )
        {
            return;
        }

        QRectF boundingBox = geometry->boundingBox();

        foreach( Geometry* geo, geometries )
        {
            if ( geo && geo == geometry )
            {
                disconnect(geometry);
                geometries.removeAll( geometry );
                if (qDeleteObject)
                {
                    delete geo;
                    geo = 0;
                }
            }
        }
        emit(updateRequest(boundingBox));
    }

    void Layer::clearGeometries( bool qDeleteObject )
    {
        foreach(Geometry *geometry, geometries)
        {
            disconnect(geometry);
            if ( qDeleteObject )
            {
                delete geometry;
                geometry = 0;
            }
        }
        geometries.clear();
    }

    bool Layer::isVisible() const
    {
        return visible;
    }
    void Layer::zoomIn() const
    {
        mymapadapter->zoom_in();
    }
    void Layer::zoomOut() const
    {
        mymapadapter->zoom_out();
    }

    void Layer::mouseEvent(const QMouseEvent* evnt, const QPoint mapmiddle_px)
    {
        if (takesMouseEvents())
        {
            if ( geometries.size() > 0 &&
                 evnt->button() == Qt::LeftButton &&
                 evnt->type() == QEvent::MouseButtonPress)
            {
                // check for collision
                QPointF c = mymapadapter->displayToCoordinate(QPoint(evnt->x()-screenmiddle.x()+mapmiddle_px.x(),
                                                                   evnt->y()-screenmiddle.y()+mapmiddle_px.y()));
                Point* tmppoint = new Point(c.x(), c.y());
                for (int i=0; i<geometries.count(); i++)
                {
                    if (geometries.at(i)->isVisible() && geometries.at(i)->Touches(tmppoint, mymapadapter))

                        //if (geometries.at(i)->Touches(c, mapAdapter))
                    {
                        emit(geometryClicked(geometries.at(i), QPoint(evnt->x(), evnt->y())));
                    }
                }
                delete tmppoint;
            }
        }
    }

    bool Layer::takesMouseEvents() const
    {
        return takeevents;
    }

    void Layer::drawYourImage(QPainter* painter, const QPoint mapmiddle_px) const
    {
        if (mylayertype == MapLayer)
        {
            //qDebug() << ":: " << mapmiddle_px;
            //QMatrix mat;
            //mat.translate(480/2, 640/2);
            //mat.rotate(45);
            //mat.translate(-480/2,-640/2);

            //mapmiddle_px = mat.map(mapmiddle_px);
            //qDebug() << ":: " << mapmiddle_px;
            _draw(painter, mapmiddle_px);
        }

        drawYourGeometries(painter, QPoint(mapmiddle_px.x()-screenmiddle.x(), mapmiddle_px.y()-screenmiddle.y()), myoffscreenViewport);
    }
    void Layer::drawYourGeometries(QPainter* painter, const QPoint mapmiddle_px, QRect viewport) const
    {
        QPoint offset;
        if (mylayertype == MapLayer)
            offset = mapmiddle_px;
        else
            offset = mapmiddle_px-screenmiddle;

        painter->translate(-mapmiddle_px+screenmiddle);
        foreach( Geometry* geometry, geometries )
        {
            geometry->draw(painter, mymapadapter, viewport, offset);
        }
        painter->translate(mapmiddle_px-screenmiddle);

    }
    void Layer::_draw(QPainter* painter, const QPoint mapmiddle_px) const
    {
        // screen middle rotieren...

        int tilesize = mymapadapter->tilesize();
        int cross_x = int(mapmiddle_px.x())%tilesize; // position on middle tile
        int cross_y = int(mapmiddle_px.y())%tilesize;
        //qDebug() << screenmiddle << " - " << cross_x << ", " << cross_y;

        // calculate how many surrounding tiles have to be drawn to fill the display
        int space_left = screenmiddle.x() - cross_x;
        int tiles_left = space_left/tilesize;
        if (space_left>0)
            tiles_left+=1;

        int space_above = screenmiddle.y() - cross_y;
        int tiles_above = space_above/tilesize;
        if (space_above>0)
            tiles_above+=1;

        int space_right = screenmiddle.x() - (tilesize-cross_x);
        int tiles_right = space_right/tilesize;
        if (space_right>0)
            tiles_right+=1;

        int space_bottom = screenmiddle.y() - (tilesize-cross_y);
        int tiles_bottom = space_bottom/tilesize;
        if (space_bottom>0)
            tiles_bottom+=1;

        //int tiles_displayed = 0;
        int mapmiddle_tile_x = mapmiddle_px.x()/tilesize;
        int mapmiddle_tile_y = mapmiddle_px.y()/tilesize;

        const QPoint from = QPoint((-tiles_left+mapmiddle_tile_x)*tilesize, (-tiles_above+mapmiddle_tile_y)*tilesize);
        const QPoint to = QPoint((tiles_right+mapmiddle_tile_x+1)*tilesize, (tiles_bottom+mapmiddle_tile_y+1)*tilesize);

        myoffscreenViewport = QRect(from, to);

        // for the EmptyMapAdapter no tiles should be loaded and painted.
        if (mymapadapter->host() == "")
        {
            return;
        }

        if (mymapadapter->isValid(mapmiddle_tile_x, mapmiddle_tile_y, mymapadapter->currentZoom()))
        {
            QPixmap tile = ImageManager::instance()->getImage(mymapadapter->host(), mymapadapter->query(mapmiddle_tile_x, mapmiddle_tile_y, mymapadapter->currentZoom()));
            if ( !tile.isNull() )
            {
                painter->drawPixmap(-cross_x+size.width(),
                                    -cross_y+size.height(),
                                    tile );
            }
        }

        for (int i=-tiles_left+mapmiddle_tile_x; i<=tiles_right+mapmiddle_tile_x; i++)
        {
            for (int j=-tiles_above+mapmiddle_tile_y; j<=tiles_bottom+mapmiddle_tile_y; j++)
            {
                // check if image is valid
                if (!(i==mapmiddle_tile_x && j==mapmiddle_tile_y))
                    if (mymapadapter->isValid(i, j, mymapadapter->currentZoom()))
                    {
                        QPixmap tile = ImageManager::instance()->getImage(mymapadapter->host(), mymapadapter->query(i, j, mymapadapter->currentZoom()));
                        if ( !tile.isNull() )
                        {
                            painter->drawPixmap(((i-mapmiddle_tile_x)*tilesize)-cross_x+size.width(),
                                                ((j-mapmiddle_tile_y)*tilesize)-cross_y+size.height(),
                                                tile);
                        }
                    }
            }
        }


        // PREFETCHING
        int upper = mapmiddle_tile_y-tiles_above-1;
        int right = mapmiddle_tile_x+tiles_right+1;
        int left = mapmiddle_tile_x-tiles_right-1;
        int lower = mapmiddle_tile_y+tiles_bottom+1;

        int j = upper;
        for (int i=left; i<=right; i++)
        {
            if (mymapadapter->isValid(i, j, mymapadapter->currentZoom()))
                ImageManager::instance()->prefetchImage(mymapadapter->host(), mymapadapter->query(i, j, mymapadapter->currentZoom()));
        }
        j = lower;
        for (int i=left; i<=right; i++)
        {
            if (mymapadapter->isValid(i, j, mymapadapter->currentZoom()))
                ImageManager::instance()->prefetchImage(mymapadapter->host(), mymapadapter->query(i, j, mymapadapter->currentZoom()));
        }
        int i = left;
        for (int j=upper+1; j<=lower-1; j++)
        {
            if (mymapadapter->isValid(i, j, mymapadapter->currentZoom()))
                ImageManager::instance()->prefetchImage(mymapadapter->host(), mymapadapter->query(i, j, mymapadapter->currentZoom()));
        }
        i = right;
        for (int j=upper+1; j<=lower-1; j++)
        {
            if (mymapadapter->isValid(i, j, mymapadapter->currentZoom()))
                ImageManager::instance()->prefetchImage(mymapadapter->host(), mymapadapter->query(i, j, mymapadapter->currentZoom()));
        }
    }

    QRect Layer::offscreenViewport() const
    {
        return myoffscreenViewport;
    }

    Layer::LayerType Layer::layerType() const
    {
        return mylayertype;
    }

    void Layer::setLayerType(Layer::LayerType lt)
    {
        if( lt == mylayertype )
            return;

        mylayertype = lt;
        emit layerTypeChanged();
    }
}
