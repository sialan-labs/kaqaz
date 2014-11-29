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
    id: paper_delete
    anchors.fill: parent

    property bool started: false

    signal deleteRequest()

    MouseArea {
        anchors.fill: parent
        onClicked: hideSubMessage()
    }

    Rectangle {
        id: delete_btn
        y: started? paper_delete.height/2 - (delete_btn.height+cancel_btn.height+10*physicalPlatformScale)/2 : -height
        width: 250*physicalPlatformScale
        anchors.horizontalCenter: parent.horizontalCenter
        height: width
        color: "#00000000"
        border.color: "#a60000"
        border.width: 2*physicalPlatformScale
        radius: 6*physicalPlatformScale
        opacity: delete_marea.pressed? 1.0 : 0.7

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Image {
            id: delete_img
            anchors.fill: parent
            anchors.margins: delete_btn.width/4
            sourceSize.width: width
            sourceSize.height: height
            source: "files/delete_btn.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        MouseArea {
            id: delete_marea
            anchors.fill: parent
            onClicked: {
                paper_delete.deleteRequest()
                hideSubMessage()
            }
        }
    }

    Rectangle {
        id: cancel_btn
        y: started? paper_delete.height/2 + (delete_btn.height-cancel_btn.height+10*physicalPlatformScale)/2 : parent.height
        width: delete_btn.width
        anchors.horizontalCenter: parent.horizontalCenter
        height: 50*physicalPlatformScale
        color: "#00000000"
        border.color: "#333333"
        border.width: 2*physicalPlatformScale
        radius: 6*physicalPlatformScale
        opacity: cancel_marea.pressed? 1.0 : 0.6

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        Text {
            id: cancel_txt
            anchors.centerIn: parent
            text: qsTr("Cancel")
            font.family: SApp.globalFontFamily
            font.pixelSize: 15*fontsScale
            color: "#333333"
        }

        MouseArea {
            id: cancel_marea
            anchors.fill: parent
            onClicked: hideSubMessage()
        }
    }

    function hide() {
        started = false
    }

    Component.onCompleted: started = true
}
