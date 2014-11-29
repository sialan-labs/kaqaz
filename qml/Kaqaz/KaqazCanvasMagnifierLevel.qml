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

ListView {
    id: color_list
    anchors.fill: parent
    anchors.margins: 15*physicalPlatformScale
    clip: true
    model: ListModel{}

    property real selectedLevel: 1

    signal levelSelected( int level )

    delegate: Rectangle {
        anchors.right: parent.right
        anchors.left: parent.left
        height: 48*physicalPlatformScale
        color: mousearea.pressed? "#aa0d80ec" : "#00000000"

        Text {
            x: 8*physicalPlatformScale
            anchors.verticalCenter: parent.verticalCenter
            text: magLevel + "x " + qsTr("Zoom")
            horizontalAlignment: Text.AlignLeft
            font.family: SApp.globalFontFamily
            font.pixelSize: 11*fontsScale
            font.bold: selectedLevel == magLevel
            color: "#333333"
        }

        MouseArea{
            id: mousearea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                selectedLevel = magLevel
                color_list.levelSelected(selectedLevel)
                hidePointDialog()
            }
        }
    }

    ScrollBar {
        scrollArea: color_list; height: color_list.height; width: 6*physicalPlatformScale
        anchors.right: color_list.right; anchors.top: color_list.top; color: "#000000"
    }

    Component.onCompleted: {
        model.clear()
        for( var i=1; i<15; i++ )
            model.append({"magLevel": i})
    }
}
