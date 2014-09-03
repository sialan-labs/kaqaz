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

Rectangle {
    id: dt_chooser
    width: 400*physicalPlatformScale
    height: 100*physicalPlatformScale
    clip: true

    property color textsColor
    property bool dateVisible: true
    property bool timeVisible: true

    property alias dateLabel: date_text.text
    property alias timeLabel: time_text.text

    Row {
        id: row
        anchors.top: date_line.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        SelectableList {
            id: year_list
            height: parent.height
            width: timeVisible? dt_chooser.width/5.333 : dt_chooser.width*(75*physicalPlatformScale)/(225*physicalPlatformScale)
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: dateVisible

            Component.onCompleted: {
                var objs = new Array
                var year = kaqaz.currentYear()
                for( var i = 0; i<200; i++ )
                    objs[i] = i+year-100

                items = objs
                positionViewAtIndex(100)
            }
        }

        SelectableList {
            id: month_list
            height: parent.height
            width: timeVisible? dt_chooser.width/4 : dt_chooser.width*(100*physicalPlatformScale)/(225*physicalPlatformScale)
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: dateVisible
            nameMethodObject: kaqaz
            nameMethodFunction: "monthName"

            Component.onCompleted: {
                var objs = new Array
                var month = kaqaz.currentMonth()
                for( var i = 0; i<12; i++ )
                    objs[i] = i+1

                items = objs
                positionViewAtIndex(month-1)
            }
        }

        SelectableList {
            id: day_list
            height: parent.height
            width: timeVisible? dt_chooser.width/8 : dt_chooser.width*(50*physicalPlatformScale)/(225*physicalPlatformScale)
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: dateVisible

            property int daysCount: kaqaz.daysOfMonth(year_list.currentItem,month_list.currentItem)
            property int currentDay: kaqaz.currentDay()

            onDaysCountChanged: {
                var objs = new Array
                if( currentDay > daysCount )
                    currentDay = daysCount

                for( var i = 0; i<daysCount; i++ )
                    objs[i] = i+1

                items = objs
                positionViewAtIndex(currentDay-1)
            }
        }

        Item {
            height: parent.height
            width: dt_chooser.width/16
            visible: dateVisible && timeVisible
        }

        SelectableList {
            id: hour_list
            height: parent.height
            width: dateVisible? dt_chooser.width/8 : dt_chooser.width*(50*physicalPlatformScale)/(150*physicalPlatformScale)
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: timeVisible
            nameMethodObject: row
            nameMethodFunction: "rightJustify"

            Component.onCompleted: {
                var objs = new Array
                var data = new Date()
                var hour = data.getHours()%12
                for( var i = 0; i<12; i++ )
                    objs[i] = i

                items = objs
                positionViewAtIndex(hour)
            }
        }

        SelectableList {
            id: minute_list
            height: parent.height
            width: dateVisible? dt_chooser.width/8 : dt_chooser.width*(50*physicalPlatformScale)/(150*physicalPlatformScale)
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: timeVisible
            nameMethodObject: row
            nameMethodFunction: "rightJustify"

            Component.onCompleted: {
                var objs = new Array
                var data = new Date()
                var minute = data.getMinutes()
                for( var i = 0; i<60; i++ )
                    objs[i] = i

                items = objs
                positionViewAtIndex(minute)
            }
        }

        SelectableList {
            id: clock_list
            height: parent.height
            width: dateVisible? dt_chooser.width/8 : dt_chooser.width*(50*physicalPlatformScale)/(150*physicalPlatformScale)
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            visible: timeVisible
            nameMethodObject: clock_list
            nameMethodFunction: "clockType"

            Component.onCompleted: {
                var objs = new Array
                var data = new Date()
                var clock = Math.floor(data.getHours()/12)
                for( var i = 0; i<2; i++ )
                    objs[i] = i

                items = objs
                positionViewAtIndex(clock)
            }

            function clockType(index) {
                return index==0? qsTr("AM") : qsTr("PM")
            }
        }

        function rightJustify( str ) {
            var tempString = str.toString()
            while( tempString.length < 2 )
                tempString = "0" + tempString

            return tempString
        }
    }

    Rectangle {
        id: date_line
        x: 0
        height: 2*physicalPlatformScale
        width: timeVisible? dt_chooser.width/1.777 : dt_chooser.width
        anchors.top: date_text.bottom
        visible: dateVisible
        color: "#88888888"
    }

    Rectangle {
        id: time_line
        x: parent.width-width
        height: 2*physicalPlatformScale
        width: dateVisible? dt_chooser.width/2.666 : dt_chooser.width
        anchors.top: time_text.bottom
        visible: timeVisible
        color: "#88888888"
    }

    Text {
        id: date_text
        anchors.horizontalCenter: date_line.horizontalCenter
        anchors.top: parent.top
        font.family: globalFontFamily
        font.pixelSize: 10*fontsScale
        color: dt_chooser.textsColor
        visible: dateVisible
        text: qsTr("Date")
    }

    Text {
        id: time_text
        anchors.horizontalCenter: time_line.horizontalCenter
        anchors.top: parent.top
        font.family: globalFontFamily
        font.pixelSize: 10*fontsScale
        color: dt_chooser.textsColor
        visible: timeVisible
        text: qsTr("Time")
    }

    function getDate() {
        var date = kaqaz.convertDateToGragorian(year_list.currentItem,month_list.currentItem,day_list.currentItem)
        date.setHours( clock_list.currentItem*12 + hour_list.currentItem )
        date.setMinutes( minute_list.currentItem )
        return date
    }
}
