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

import QtQuick 2.2
import AsemanTools 1.0

Rectangle {
    id: helper_back
    anchors.fill: parent
    opacity: 0
    color: "#aa000000"

    Behavior on opacity {
        NumberAnimation { easing.type: Easing.OutCubic; duration: 1000 }
    }

    Component.onCompleted: {
        opacity_timer.start()
        initTranslations()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: helper_back.finish()
    }

    Item {
        id: helper
        anchors.fill: parent
        anchors.topMargin: View.statusBarHeight
        anchors.bottomMargin: View.navigationBarHeight
        clip: true

        Image {
            id: swype_circle
            source: "helper/swype_left.png"
            width: 200*physicalPlatformScale
            height: 75*physicalPlatformScale
            smooth: true
            anchors.right: helper.right
            anchors.rightMargin: -1*height/3
            anchors.top: helper.verticalCenter
        }

        Text {
            id: swype_p_text
            font.pixelSize: 10*fontsScale
            font.family: SApp.globalFontFamily
            color: "#0d80ec"
            anchors.top: swype_circle.bottom
            anchors.right: helper.right
            anchors.rightMargin: 10*physicalPlatformScale
            horizontalAlignment: Text.AlignHCenter
        }

        Image {
            id: swype_group
            source: "helper/circle_1.png"
            width: 50*physicalPlatformScale
            height: 50*physicalPlatformScale
            x: 40*physicalPlatformScale
            y: 10*physicalPlatformScale
            smooth: true
        }

        Text {
            id: swype_group_text
            font.pixelSize: 10*fontsScale
            font.family: SApp.globalFontFamily
            color: "#0d80ec"
            anchors.verticalCenter: swype_group.verticalCenter
            anchors.left: swype_group.right
            horizontalAlignment: Text.AlignHCenter
        }

        Image {
            id: swype_left
            source: "helper/swype_left.png"
            width: 240*physicalPlatformScale
            height: 70*physicalPlatformScale
            anchors.horizontalCenter: helper.horizontalCenter
            anchors.bottom: helper.verticalCenter
            smooth: true
        }

        Text {
            id: swype_left_text
            font.pixelSize: 10*fontsScale
            font.family: SApp.globalFontFamily
            color: "#0d80ec"
            anchors.top: swype_left.bottom
            anchors.horizontalCenter: swype_left.horizontalCenter
            anchors.topMargin: 10*physicalPlatformScale
            horizontalAlignment: Text.AlignHCenter
        }

        Image {
            id: swype_right
            source: "helper/swype_right.png"
            width: 240*physicalPlatformScale
            height: 70*physicalPlatformScale
            anchors.horizontalCenter: helper.horizontalCenter
            anchors.bottom: swype_left.top
            smooth: true
        }

        Text {
            id: swype_right_text
            font.pixelSize: 10*fontsScale
            font.family: SApp.globalFontFamily
            color: "#0d80ec"
            anchors.bottom: swype_right.top
            anchors.horizontalCenter: helper.horizontalCenter
            anchors.bottomMargin: 10*physicalPlatformScale
            horizontalAlignment: Text.AlignHCenter
        }

        Image {
            id: title_pointer
            source: "helper/title.png"
            width: 140*physicalPlatformScale
            height: 60*physicalPlatformScale
            anchors.horizontalCenter: helper.horizontalCenter
            anchors.top: helper.top
            anchors.topMargin: 60*physicalPlatformScale
            smooth: true
            visible: false
        }

        Image {
            id: date_pointer
            source: "helper/date.png"
            width: 40*physicalPlatformScale
            height: 60*physicalPlatformScale
            anchors.left: helper.left
            anchors.bottom: helper.bottom
            anchors.bottomMargin: 30*physicalPlatformScale
            smooth: true
        }

        Text {
            id: date_p_text
            font.pixelSize: 10*fontsScale
            font.family: SApp.globalFontFamily
            color: "#0d80ec"
            anchors.top: date_pointer.top
            anchors.left: date_pointer.right
            anchors.leftMargin: 10*physicalPlatformScale
            horizontalAlignment: Text.AlignHCenter
        }

        Button {
            id: got_it_btn
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: helper.bottom
            height: 40*physicalPlatformScale
            width: 160*physicalPlatformScale
            fontSize: 11*fontsScale
            anchors.margins: 10*physicalPlatformScale
            normalColor: "#333333"
            highlightColor: "#222222"
            onClicked: helper_back.finish()
        }
    }

    Timer {
        id: opacity_timer
        interval: 1000
        repeat: false
        onTriggered: helper_back.opacity = 1
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        got_it_btn.text = qsTr("Got it")
        date_p_text.text = qsTr("Paper create date and time.")
        swype_right_text.text = qsTr("Put your finger here and\nswipe right to previous paper.")
        swype_left_text.text = qsTr("Put your finger here and\nswipe left to next paper.")
        swype_group_text.text = qsTr("Tap here to select Labels")
        swype_p_text.text = qsTr("Put your finger here and swipe it\nleft to select categories.")
    }

    function finish() {
        kaqaz.setTutorialCompleted(true)
        helper_back.opacity = 0
        helper_back.destroy()
    }
}
