/*
 * File:      simage.cpp
 * Author:    Bardia Daneshvar (bardia@getsilicon.org)
 * Copyright: (C) 2010 Bardia Daneshvar
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
 * for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "simage.h"

#include <QColor>
#include <QDebug>



/*================================*
 |                                |
 |             SImage             |
 |                                |
 *================================*/

SImage::SImage( const QImage & image ) : QImage(image)
{
}

SImage::SImage(const QString &image) : QImage(image)
{
}

void SImage::setColorize( const QRgb & rgb )
{
    QColor color( rgb );

    for( int i=0 ; i<this->width() ; i++ )
    {
        for( int j=0 ; j<this->height() ; j++ )
        {
            QColor cl( this->pixel(i,j) );
                cl.setHsl( color.hue() , color.saturation() , cl.lightness() , cl.alpha() );

            this->setPixel( i , j , cl.rgba() );
        }
    }

}

SImage SImage::colorize( const QRgb & rgb )
{
    QColor color( rgb );
    SImage result( *this );

    for( int i=0 ; i<result.width() ; i++ )
    {
        for( int j=0 ; j<result.height() ; j++ )
        {
            const QRgb & rgb = result.pixel(i,j);
            QColor cl( rgb );
            cl.setHsl( color.hue() , color.saturation() , cl.lightness() , qAlpha(rgb) );

            result.setPixel( i , j , cl.rgba() );
        }
    }

    return result;
}

QImage SImage::colorize( const QImage & image , const QRgb & rgb )
{
    QColor color( rgb );
    QImage result(image.width() , image.height() , image.format() );

    for( int i=0 ; i<image.width() ; i++ )
    {
        for( int j=0 ; j<image.height() ; j++ )
        {
            QColor cl( image.pixel(i,j) );
            cl.setHsl( color.hue() , color.saturation() , cl.lightness() , cl.alpha() );

            result.setPixel( i , j , cl.rgba() );
        }
    }

    return result;
}

void SImage::addImage( const QImage & sub , SImage::SnapType type )
{
    QImage *result = this;

    for( int i=0 ; i<sub.width() ; i++ )
    {
        for( int j=0 ; j<sub.height() ; j++ )
        {
            int width  = (result->width() - sub.width())*(type==TopRight || type==BottomRight) + i;
            int height = (result->height() - sub.height())*(type==BottomLeft || type==BottomRight) + j;

            int res_alpha = qAlpha(result->pixel(width,height));
            int sub_alpha = qAlpha(sub.pixel(i,j));

            double res_ratio = (double)(255-sub_alpha)/255;
            double sub_ratio = (double)sub_alpha/255;

            QColor cl( sub.pixel(i,j) );
            QColor rcl( result->pixel(width,height) );

            int new_alpha = (sub_alpha+res_alpha);
            if( new_alpha > 255 )
                new_alpha = 255;


            if( res_alpha > 0 && sub_alpha < 255 )
                cl.setRgb( cl.red()*sub_ratio+rcl.red()*res_ratio , cl.green()*sub_ratio+rcl.green()*res_ratio , cl.blue()*sub_ratio+rcl.blue()*res_ratio , new_alpha );
            else
                cl.setRgb( cl.red() , cl.green() , cl.blue() , sub_alpha );

            result->setPixel( width , height , cl.rgba() );
        }
    }
}
