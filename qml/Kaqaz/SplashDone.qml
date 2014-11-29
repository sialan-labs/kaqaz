/*
    Copyright (C) 2014 Aseman
    http://aseman.co

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
import AsemanTools 1.0

Item {
    id: done_page
    width: 100
    height: 62

    signal finished()

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20*physicalPlatformScale

        Image {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            width: 140*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectFit
            source: "files/done.png"
        }

        Text {
            id: txt
            anchors.left: parent.left
            anchors.right: parent.right
            font.pixelSize: 18*fontsScale
            font.family: SApp.globalFontFamily
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#333333"
            text: qsTr("Start Kaqaz")
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            kaqaz.setTutorialCompleted(true)
            done_page.finished()
        }
    }
}
