/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Kaqaz 1.0
import SialanTools 1.0

Item {
    id: geo_domain
    width: 100
    height: 62

    property variant domain

    Column {
        id: column
        anchors.fill: parent

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        MenuButton {
            height: 50*physicalPlatformScale
            width: column.width
            normalColor: "#00000000"
            highlightColor: "#4098bf"
            textColor: press? "#ffffff" : "#4098bf"
            textFont.weight: Font.Normal
            textFont.pixelSize: 13*fontsScale
            textFont.bold: false
            text: qsTr("No Location")
            onClicked: {
                geo_domain.domain = 0
            }
        }

        MenuButton {
            height: 50*physicalPlatformScale
            width: column.width
            normalColor: "#00000000"
            highlightColor: "#4098bf"
            textColor: press? "#ffffff" : "#4098bf"
            textFont.weight: Font.Normal
            textFont.pixelSize: 13*fontsScale
            textFont.bold: false
            text: qsTr("Current Location")
            onClicked: {
                geo_domain.domain = position.coordinate
            }
        }

        MenuButton {
            height: 50*physicalPlatformScale
            width: column.width
            normalColor: "#00000000"
            highlightColor: "#4098bf"
            textColor: press? "#ffffff" : "#4098bf"
            textFont.weight: Font.Normal
            textFont.pixelSize: 13*fontsScale
            textFont.bold: false
            textFont.strikeout: true
            text: qsTr("Select on Map (Soon)")
            onClicked: {
            }
        }
    }
}
