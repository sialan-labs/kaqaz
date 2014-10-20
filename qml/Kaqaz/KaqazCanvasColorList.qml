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

    property color selectedColor: "black"

    delegate: Rectangle {
        anchors.right: parent.right
        anchors.left: parent.left
        height: 48*physicalPlatformScale
        color: mousearea.pressed? "#aa0d80ec" : "#00000000"

        Rectangle{
            id: rectangle
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 4*physicalPlatformScale
            width: height
            radius: width/2
            border.color: selectedColor==color? "#aaaaaa" : "#ffffff"
            border.width: 3*physicalPlatformScale
            color: itemColor
        }

        Text {
            anchors.left: rectangle.right
            anchors.leftMargin: 6*physicalPlatformScale
            anchors.verticalCenter: parent.verticalCenter
            text: itemColor
            horizontalAlignment: Text.AlignLeft
            font.family: SApp.globalFontFamily
            font.pixelSize: 11*fontsScale
            color: "#333333"
        }

        MouseArea{
            id: mousearea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                selectedColor = itemColor
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

        model.append({"itemColor": "black"})
        model.append({"itemColor": "dodgerblue"})
        model.append({"itemColor": "darkgreen"})
        model.append({"itemColor": "gold"})

        model.append({"itemColor": "maroon"})
        model.append({"itemColor": "purple"})
        model.append({"itemColor": "orangered"})
        model.append({"itemColor": "magenta"})

        model.append({"itemColor": "darkslateblue"})
        model.append({"itemColor": "violet"})
        model.append({"itemColor": "saddlebrown"})
        model.append({"itemColor": "black"})

        model.append({"itemColor": "chocolate"})
        model.append({"itemColor": "firebrick"})
        model.append({"itemColor": "teal"})
        model.append({"itemColor": "darkviolet"})

        model.append({"itemColor": "olive"})
        model.append({"itemColor": "mediumvioletred"})
        model.append({"itemColor": "darkorange"})
        model.append({"itemColor": "darkslategray"})
    }
}
