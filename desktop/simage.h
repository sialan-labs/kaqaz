/*
 * File:      simage.h
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

#ifndef SIMAGE_H
#define SIMAGE_H

#include <QImage>
#include <QRgb>

/*!
 * The SImage class provides an image class based on QImage.
 */
class SImage : public QImage
{
public:

    enum SnapType {
        TopLeft,
        TopRight,
        BottomLeft,
        BottomRight
    };

    /*!
     * Constructs a SImage class whith "image" image.
     */
    SImage( const QImage & image = QImage() );
    SImage( const QString & image );


    /*!
     * Set Image colorize with rgb color.
     * \sa colorize
     */
    void setColorize( const QRgb & rgb );


    /*!
     * Colorize This Image ro rgb color and Returns
     * result . This Function dont make any change to class.
     * \sa setColorize
     */
    SImage colorize( const QRgb & rgb );


    /*!
     * Colorize "image" image to rgb color and Returns result.
     * It's an static function.
     */
    static QImage colorize( const QImage & image, const QRgb & rgb  );


    /*!
     * Add another image to the SImage.
     */
    void addImage( const QImage & image , SnapType type = TopLeft );

};

#endif // SIMAGE_H
