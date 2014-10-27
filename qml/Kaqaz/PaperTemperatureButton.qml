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

PaperAbstractButton {
    id: pt_btn
    background: "files/paperbuttons/temperature.png"

    property int paperTemperature: paperItem? database.paperTemperature(paperItem) : 0
    property variant temperatureChooser

    onClicked: {
        if( !temperatureChooser )
            temperatureChooser = showBottomPanel(paper_temperature_component,true)
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 3*physicalPlatformScale
        font.pixelSize: 30*fontsScale
        font.family: SApp.globalFontFamily
        font.bold: true
        color: "#ffffff"
        text: paperTemperature + "°"
    }

    Component {
        id: paper_temperature_component

        Column {
            width: 20
            spacing: 4*physicalPlatformScale

            Item { width: 20; height: 10*physicalPlatformScale }

            Button {
                id: done_btn
                anchors.right: parent.right
                anchors.margins: 10*physicalPlatformScale
                height: 30*physicalPlatformScale
                width: 100*physicalPlatformScale
                color: "#4098bf"
                highlightColor: "#3B8DB1"
                textColor: "#ffffff"
                text: qsTr("Done")
                onClicked: {
                    var temp = Math.floor((slider.value-50)*2)
                    database.setPaperTemperature(paperItem,temp)
                    main.refreshMenu()
                    hideBottomPanel()
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 10*physicalPlatformScale

                Slider {
                    id: slider
                    anchors.verticalCenter: parent.verticalCenter
                    width: 220*physicalPlatformScale
                    height: 25*physicalPlatformScale
                    maximum: 100
                    value: 50 + paperTemperature/2
                    backColor: "#333333"
                }

                Text {
                    width: 30*physicalPlatformScale
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 10*physicalPlatformScale
                    font.family: SApp.globalFontFamily
                    font.pixelSize: 20*fontsScale
                    color: "#333333"
                    text: Math.floor((slider.value-50)*2) + "°"
                }
            }
        }
    }
}
