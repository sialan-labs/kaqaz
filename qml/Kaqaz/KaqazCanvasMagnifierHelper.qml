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

Rectangle {
    id: kcmhelper
    width: 100
    height: 62
    color: "#66ffffff"

    Timer {
        id: timer
        interval: 500
        repeat: true
        onTriggered: count1x++
        Component.onCompleted: start()
        property int count2x: Math.floor(count1x/2)
        property int count1x: 3
    }

    Text {
        anchors.centerIn: parent
        text: qsTr("Put your fingers on screen\nand move them on screen")
        font.family: SApp.globalFontFamily
        font.pixelSize: 15*fontsScale
        font.bold: true
        rotation: -45
        transformOrigin: Item.Center
        horizontalAlignment: Text.AlignHCenter
        color: "#0d80ec"
        opacity: timer.count2x>1? 1 : 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 600 }
        }
    }

    Image {
        id: point1
        x: kcmhelper.width/2 - width/2 - 60*physicalPlatformScale
        y: kcmhelper.height/2 - height/2 - 60*physicalPlatformScale
        width: 64*physicalPlatformScale
        height: 64*physicalPlatformScale
        sourceSize: Qt.size(width,height)
        source: "helper/finger-point.png"
        opacity: timer.count2x>2? 1 : 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 600 }
        }
    }

    Image {
        id: point2
        x: kcmhelper.width/2 - width/2 + 60*physicalPlatformScale
        y: kcmhelper.height/2 - height/2 + 60*physicalPlatformScale
        width: 64*physicalPlatformScale
        height: 64*physicalPlatformScale
        sourceSize: Qt.size(width,height)
        source: "helper/finger-point.png"
        opacity: timer.count2x>2? 1 : 0

        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 600 }
        }
    }

    Image {
        id: pointer1
        x: 0<startCount && (startCount%4==1 || startCount%4==2)? point1.x - width + point1.width - 50*physicalPlatformScale : point1.x - width + point1.width
        y: 0<startCount && (startCount%4==1 || startCount%4==2)? point1.y - height + point1.height - 50*physicalPlatformScale : point1.y - height + point1.height
        width: 92*physicalPlatformScale
        height: 92*physicalPlatformScale
        sourceSize: Qt.size(width,height)
        source: "helper/finger-move-tl.png"
        opacity: 0<startCount && startCount%4==1? 1 : 0

        property int startCount: timer.count1x-7

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 1000 }
        }
        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 1000 }
        }
        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 500 }
        }
    }

    Image {
        id: pointer2
        x: 0<startCount && (startCount%4==1 || startCount%4==2)? point2.x + 50*physicalPlatformScale : point2.x
        y: 0<startCount && (startCount%4==1 || startCount%4==2)? point2.y + 50*physicalPlatformScale : point2.y
        width: 92*physicalPlatformScale
        height: 92*physicalPlatformScale
        sourceSize: Qt.size(width,height)
        source: "helper/finger-move-br.png"
        opacity: 0<startCount && startCount%4==1? 1 : 0

        property int startCount: timer.count1x-7

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 1000 }
        }
        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 1000 }
        }
        Behavior on opacity {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 500 }
        }
    }
}
