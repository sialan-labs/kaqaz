import QtQuick 2.0

Rectangle {
    id: dt_chooser
    width: 400*physicalPlatformScale
    height: 100*physicalPlatformScale
    clip: true

    property color textsColor

    Row {
        id: row
        anchors.fill: parent

        SelectableList {
            id: year_list
            height: parent.height
            width: dt_chooser.width/5.333
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color

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
            width: dt_chooser.width/4
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
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
            width: dt_chooser.width/8
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color

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
        }

        SelectableList {
            id: hour_list
            height: parent.height
            width: dt_chooser.width/8
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
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
            width: dt_chooser.width/8
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
            nameMethodObject: row
            nameMethodFunction: "rightJustify"

            Component.onCompleted: {
                var objs = new Array
                var data = new Date()
                var minute = data.getMinutes()
                for( var i = 0; i<60; i++ )
                    objs[i] = i+1

                items = objs
                positionViewAtIndex(minute-1)
            }
        }

        SelectableList {
            id: clock_list
            height: parent.height
            width: dt_chooser.width/8
            textsColor: dt_chooser.textsColor
            color: dt_chooser.color
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
}