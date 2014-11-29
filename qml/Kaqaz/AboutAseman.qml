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

    Item {
        anchors.fill: parent
        anchors.bottomMargin: -View.navigationBarHeight

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: -View.statusBarHeight
            color: "#ccffffff"
        }

        Flickable {
            id: flickable
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: visit_btn.top
            anchors.topMargin: title.height
            flickableDirection: Flickable.VerticalFlick
            contentHeight: column.height
            contentWidth: width

            Column {
                id: column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 80*physicalPlatformScale
                    height: width
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width,height)
                    smooth: true
                    source: "files/aseman.png"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "ASEMAN"
                    font.pixelSize: 20*fontsScale
                    font.weight: Devices.isWindows? Font.Normal : Font.DemiBold
                    font.family: SApp.globalFontFamily
                    color: "#333333"
                }

                Item {
                    width: 10
                    height: 20*physicalPlatformScale
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20*physicalPlatformScale
                    text: Tools.aboutAseman()
                    font.pixelSize: 9*fontsScale
                    font.family: SApp.globalFontFamily
                    wrapMode: Text.WordWrap
                    color: "#333333"
                }
            }
        }

        ScrollBar {
            scrollArea: flickable; height: flickable.height; width: 8
            anchors.right: flickable.right; anchors.top: flickable.top; color: "#888888"
        }

        Button {
            id: visit_btn
            anchors.left: parent.left
            anchors.bottom: nav_rect.top
            anchors.right: parent.right
            height: 42*physicalPlatformScale
            normalColor: "#4098bf"
            highlightColor: "#337fa2"
            text: qsTr("Check Aseman website")
            onClicked: Qt.openUrlExternally("http://aseman.co/")
        }

        Rectangle {
            id: nav_rect
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            height: View.navigationBarHeight
            color: visit_btn.press? visit_btn.highlightColor : visit_btn.normalColor
        }

        Header {
            id: title
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
        }
    }
}
