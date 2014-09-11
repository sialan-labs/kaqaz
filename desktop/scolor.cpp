/*
 * File:      scolor.h
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

#include "scolor.h"




/*================================*
 |                                |
 |             SColor             |
 |                                |
 *================================*/

SColor::SColor()
{
}

SColor::SColor( const QColor & color ) : QColor( color )
{
}

QColor SColor::operator+ (QColor colorB)
{
    colorB.setRed( (red()+colorB.red()) / 2 );
    colorB.setGreen( (green()+colorB.green()) / 2 );
    colorB.setBlue( (blue()+colorB.blue()) / 2 );

    return colorB;
}

QColor SColor::operator+ (int num)
{
    QColor result;

    int value;

    value = red()+num;
    if( value > 255 )
        value = 255;

    result.setRed( value );

    value = green()+num;
    if( value > 255 )
        value = 255;

    result.setGreen( value );

    value = blue()+num;
    if( value > 255 )
        value = 255;

    result.setBlue( value );

    return result;
}

QColor SColor::operator- (int num)
{
    QColor result;

    int value;

    value = red()-num;
    if( value > 255 )
        value = 255;

    result.setRed( value );

    value = green()-num;
    if( value > 255 )
        value = 255;

    result.setGreen( value );

    value = blue()-num;
    if( value > 255 )
        value = 255;

    result.setBlue( value );

    return result;
}

QColor SColor::operator* (double num)
{
    QColor result;

    int value;

    value = (double)red()*num;
    if( value > 255 )
        value = 255;

    result.setRed( value );

    value = (double)green()*num;
    if( value > 255 )
        value = 255;

    result.setGreen( value );

    value = (double)blue()*num;
    if( value > 255 )
        value = 255;

    result.setBlue( value );

    return result;
}

QColor SColor::operator/ (double num)
{
    QColor result;

    int value;

    value = (double)red()/num;
    if( value > 255 )
        value = 255;

    result.setRed( value );

    value = (double)green()/num;
    if( value > 255 )
        value = 255;

    result.setGreen( value );

    value = (double)blue()/num;
    if( value > 255 )
        value = 255;

    result.setBlue( value );

    return result;
}

QColor SColor::operator= (const QColor & colorB)
{
    setColor( colorB );
    return colorB;
}

QColor SColor::operator= (const SColor & colorB)
{
    setColor( colorB );
    return colorB;
}

void SColor::invert()
{
    setRed( 255-red() );
    setGreen( 255-green() );
    setBlue( 255-blue() );
}

void SColor::setColor(const QColor & colorB)
{
    setRed(colorB.red());
    setGreen(colorB.green());
    setBlue(colorB.blue());
    setAlpha( colorB.alpha() );
}
