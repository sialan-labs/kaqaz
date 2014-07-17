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

import QtQuick 2.2

Item {
    property alias color : rectangle.color
    property alias shadowOpacity: shadow.opacity
    property alias radius: rectangle.radius
    property alias visibleShadow: shadow.visible
    property real shadowSize: 8

    BorderImage {
        id: shadow
        opacity: 0.6
        anchors.fill: rectangle
        anchors { leftMargin: -shadowSize; topMargin: -shadowSize; rightMargin: -shadowSize; bottomMargin: -shadowSize }
        border { left: 10; top: 10; right: 10; bottom: 10 }
        source: "files/shadow.png";
        smooth: true
    }

    Rectangle {
        id: rectangle;
        smooth: true
        anchors.fill: parent
        radius: 5
    }
}
