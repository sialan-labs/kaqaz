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
import SialanTools 1.0

ListView {
    id: color_list
    anchors.fill: parent
    anchors.margins: 15*physicalPlatformScale
    clip: true
    model: ListModel{}

    property real selectedMode: 0

    delegate: Rectangle {
        anchors.right: parent.right
        anchors.left: parent.left
        height: 48*physicalPlatformScale
        color: mousearea.pressed? "#aa0d80ec" : "#00000000"

        Text {
            anchors.left: parent.left
            anchors.margins: 10*physicalPlatformScale
            anchors.verticalCenter: parent.verticalCenter
            text: itemText
            horizontalAlignment: Text.AlignLeft
            font.family: SApp.globalFontFamily
            font.bold: selectedMode == itemMode
            font.pixelSize: 11*fontsScale
            color: "#333333"
        }

        MouseArea{
            id: mousearea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                selectedMode = itemMode
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
        model.append({"itemMode": 0, "itemText": qsTr("Normal Pen") })
        model.append({"itemMode": 1, "itemText": qsTr("Star Pen") })
        model.append({"itemMode": 2, "itemText": qsTr("Eraser") })
    }
}
