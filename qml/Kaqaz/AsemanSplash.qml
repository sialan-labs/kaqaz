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
    width: 100
    height: 62

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Image {
            width: 80*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            source: "files/aseman.png"
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "ASEMAN"
            font.pixelSize: 20*fontsScale
            font.weight: Font.DemiBold
            font.family: SApp.globalFontFamily
            color: "#333333"
        }
    }

    GlowedAnimatedText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20*physicalPlatformScale
        text: "slide to next"
        font.pixelSize: 12*fontsScale
        font.family: SApp.globalFontFamily
        color: "#333333"
        speed: 1200
        glowWidth: 60*physicalPlatformScale
        direction: Qt.RightToLeft
        Component.onCompleted: start()
    }
}
