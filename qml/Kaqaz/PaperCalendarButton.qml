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
    id: pcal_btn
    background: "files/paperbuttons/calendar.png"

    property variant paperDate: paperItem>0? database.paperCreatedDate(paperItem) : 0
    property variant dateChooser

    onClicked: {
        if( !dateChooser )
            dateChooser = showBottomPanel(calendar_component,true)
    }

    onRefresh: {
        if( !paperDate )
            return

        var day = CalendarConv.dateDay(paperDate)
        day_txt.text = day
        if( day_txt.text.length==1 )
            day_txt.text = "0" + day_txt.text

        month_txt.text = CalendarConv.monthName( CalendarConv.dateMonth(paperDate) )
        year_txt.text = CalendarConv.dateYear(paperDate)
    }

    onPaperDateChanged: refresh()

    Text {
        id: day_txt
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: "#333333"
        font.pixelSize: 30*physicalPlatformScale
        font.family: SApp.globalFontFamily
        font.bold: true
    }

    Text {
        id: month_txt
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 18*physicalPlatformScale
        color: "#ffffff"
        font.pixelSize: 11*physicalPlatformScale
        font.family: SApp.globalFontFamily
    }

    Text {
        id: year_txt
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30*physicalPlatformScale
        color: "#333333"
        font.pixelSize: 11*physicalPlatformScale
        font.family: SApp.globalFontFamily
    }

    Component {
        id: calendar_component
        Item {
            id: calendar_dialog
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
                    var date = dateChooser.getDate()
                    date = CalendarConv.combineDateAndTime( date, database.paperCreatedDate(paperItem) )

                    database.setPaperCreatedDate(paperItem,date)
                    paperObject.refreshDateLabel()
                    pcal_btn.refresh()
                    main.refreshMenu()
                    hideBottomPanel()
                }
            }

            DateTimeChooser {
                id: dateChooser
                width: 260*physicalPlatformScale
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.top: done_btn.bottom
                anchors.margins: 20*physicalPlatformScale
                anchors.topMargin: 10*physicalPlatformScale
                dateVisible: true
                timeVisible: false
                color: "#D9D9D9"
                textsColor: "#111111"
                Component.onCompleted: setDate(paperDate)
            }
        }
    }
}
