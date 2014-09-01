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
import QtPositioning 5.2

Rectangle {
    id: map_view
    width: 100
    height: 62

    property real longitude
    property real latitude

    property bool unknown: !latitude && !longitude
    property int paperId

    Item{
        id: fader_item
        height: 60*physicalPlatformScale
        visible: false

        Button {
            id: unpin_map_btn
            anchors.bottom: fader_item.bottom
            anchors.left: fader_item.left
            anchors.margins: 10*physicalPlatformScale
            width: (fader_item.width - 30*physicalPlatformScale)/2
            normalColor: "#ffffff"
            textColor: "#333333"
            onClicked: {
                database.setPaperLocation(paperId,QtPositioning.coordinate(0,0))
                hideRollerDialog()
            }
        }

        Button {
            id: open_map_btn
            anchors.bottom: fader_item.bottom
            anchors.left: fader_item.horizontalCenter
            anchors.leftMargin: 5*physicalPlatformScale
            anchors.margins: 10*physicalPlatformScale
            width: (fader_item.width - 30*physicalPlatformScale)/2
            normalColor: "#ffffff"
            textColor: "#333333"
            onClicked: {
                if( !longitude && !latitude )
                    Qt.openUrlExternally("http://maps.google.com")
                else
                    Qt.openUrlExternally("http://maps.google.com/maps?&q=" + latitude + "," + longitude)
                hideRollerDialog()
            }
        }
    }

    Image {
        id: splash_map
        source: "files/map-loading.png"
        anchors.fill: parent
        sourceSize: Qt.size(width,height)
        visible: !master_map.visible
        fillMode: Image.PreserveAspectCrop
        asynchronous: true

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            font.family: globalFontFamily
            font.pixelSize: 9*fontsScale
            text: latitude + ", " + longitude
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            font.family: globalFontFamily
            font.pixelSize: 13*fontsScale
            text: unknown? qsTr("Unknown point") : qsTr("Loading Map...")
        }
    }

    Image {
        id: master_map
        anchors.fill: parent
        asynchronous: true
        visible: master_map.status == Image.Ready && !unknown
        sourceSize: Qt.size(width,height)
        source: "http://maps.google.com/maps/api/staticmap?center=" + latitude + "," + longitude + "&zoom=15&size=" + Math.floor(width) + "x" + Math.floor(height) + "&sensor=false"
    }

    Image {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        source: "files/map-pin.png"
        sourceSize: Qt.size(width,height)
        fillMode: Image.PreserveAspectFit
        width: 92*physicalPlatformScale
        height: 92*physicalPlatformScale
        visible: master_map.visible
        asynchronous: true
        smooth: true
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        visible: !unknown
        onClicked: {
            showRollerDialog( map_view.mapToItem(kaqaz_root,0,0).y, map_view.mapToItem(kaqaz_root,0,map_view.height).y, fader_item )
        }
    }

    function initTranslations(){
        unpin_map_btn.text = qsTr("Unpin")
        open_map_btn.text = qsTr("Open")
    }

    Component.onCompleted: initTranslations()
}
