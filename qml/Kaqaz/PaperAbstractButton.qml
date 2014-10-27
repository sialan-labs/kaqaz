/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0

Item {
    id: pa_btn
    width: 92*physicalPlatformScale
    height: 92*physicalPlatformScale

    property int paperItem
    property variant paperObject
    property alias background: back_image.source

    signal clicked()
    signal refresh()

    Image {
        id: back_image
        anchors.fill: parent
        asynchronous: true
        sourceSize: Qt.size(width,height)
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    MouseArea {
        anchors.fill: parent
        onClicked: pa_btn.clicked()
    }
}
