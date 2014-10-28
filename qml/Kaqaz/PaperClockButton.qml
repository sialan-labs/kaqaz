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
    id: pclk_btn
    background: "files/paperbuttons/clock.png"

    property variant paperDate: paperItem>0? database.paperCreatedDate(paperItem) : 0
    property variant dateChooser

    onClicked: {
        if( !dateChooser )
            dateChooser = showBottomPanel(clock_component,true)
    }

    onRefresh: {
        if( !paperDate )
            return

        second_rect.rotation = 90 + paperDate.getSeconds()*360/60
        minute_rect.rotation = 90 + paperDate.getMinutes()*360/60
        hour_rect.rotation = 90 + (paperDate.getHours()%12 + paperDate.getMinutes()/60)*360/12
        day_night_txt.text = (paperDate.getHours()<12)? qsTr("AM") : qsTr("PM")
    }

    onPaperDateChanged: refresh()

    Rectangle {
        id: hour_rect
        anchors.right: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: 2*physicalPlatformScale
        width: parent.width/2 - 28*physicalPlatformScale
        transformOrigin: Item.Right
        rotation: 90
        color: "#000000"
    }

    Rectangle {
        id: minute_rect
        anchors.right: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: 2*physicalPlatformScale
        width: parent.width/2 - 20*physicalPlatformScale
        transformOrigin: Item.Right
        rotation: 90
        color: "#000000"
    }

    Rectangle {
        id: second_rect
        anchors.right: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: 1*physicalPlatformScale
        width: parent.width/2 - 18*physicalPlatformScale
        transformOrigin: Item.Right
        rotation: 90
        color: "#ff0000"
    }

    Text {
        id: day_night_txt
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 8*physicalPlatformScale
        anchors.bottomMargin: 1*physicalPlatformScale
        color: "#ffffff"
        font.pixelSize: 10*physicalPlatformScale
        font.family: SApp.globalFontFamily
        font.bold: true
    }

    Component {
        id: clock_component
        Item {
            id: clock_dialog
            height: 230*physicalPlatformScale

            MouseArea {
                anchors.fill: parent
            }

            Button {
                id: done_btn
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10*physicalPlatformScale
                height: 30*physicalPlatformScale
                width: 100*physicalPlatformScale
                color: "#4098bf"
                highlightColor: "#3B8DB1"
                textColor: "#ffffff"
                text: qsTr("Done")
                onClicked: {
                    var time = dateChooser.getDate()
                    time = CalendarConv.combineDateAndTime( database.paperCreatedDate(paperItem), time )

                    database.setPaperCreatedDate(paperItem,time)
                    paperObject.refreshDateLabel()
                    pclk_btn.refresh()
                    main.refreshMenu()
                    hideBottomPanel()
                }
            }

            DateTimeChooser {
                id: dateChooser
                width: 220*physicalPlatformScale
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.top: done_btn.bottom
                anchors.margins: 20*physicalPlatformScale
                anchors.topMargin: 10*physicalPlatformScale
                dateVisible: false
                timeVisible: true
                color: "#D9D9D9"
                textsColor: "#111111"
                Component.onCompleted: setDate(paperDate)
            }
        }
    }
}
