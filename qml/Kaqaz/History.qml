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

import QtQuick 2.2
import Kaqaz 1.0

Item {
    id: history
    width: 100
    height: 62

    Image {
        anchors.fill: parent
        anchors.topMargin: -statusBarHeight
        anchors.bottomMargin: -navigationBarHeight
        source: "files/menu_background.jpg"
        fillMode: Image.PreserveAspectCrop
    }

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        light: true
    }

    ListView {
        id: history_list
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true
        maximumFlickVelocity: flickVelocity

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: history_list.width
            height: 50*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string text
            property int date: daysDate
            property bool press: false

            onDateChanged: {
                var days = date
                if( days === kaqaz.currentDays )
                    text = qsTr("Today")
                else
                if( days === kaqaz.currentDays-1 )
                    text = qsTr("Yesterday")
                else
                if( days === kaqaz.currentDays-2 )
                    text = qsTr("Two days ago")
                else
                    text = kaqaz.convertIntToFullStringDate(days)

                papers_count_txt.text = database.papersCountOf(kaqaz.convertDaysToDate(date))
            }

            Connections{
                target: history_list
                onMovementStarted: press = false
                onFlickStarted: press = false
            }

            Text{
                id: txt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 25*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text
                font.pixelSize: 11*fontsScale
                font.family: globalFontFamily
                color: "#ffffff"
            }

            Rectangle{
                id: papers_count
                width: height
                height: 22*physicalPlatformScale
                radius: 3*physicalPlatformScale
                color: "#ffffff"
                anchors.verticalCenter: item.verticalCenter
                anchors.left: (txt.horizontalAlignment == Qt.AlignRight)? item.left : item.right
                anchors.leftMargin: (txt.horizontalAlignment == Qt.AlignRight)? 10*physicalPlatformScale : -width - 10*physicalPlatformScale

                Text{
                    id: papers_count_txt
                    x: papers_count.width/2 - width/2
                    y: papers_count.height/2 - height/2
                    color: "#235089"
                }
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    var nodes = database.papersOf(kaqaz.convertDaysToDate(item.date))
                    if( nodes.length === 0 )
                        return

                    main.setCurrentGroup(item.date,PaperManager.Date)
                    main.popPreference()
                }
            }
        }

        focus: true
        highlight: Rectangle { color: "#3B97EC"; radius: 3; smooth: true }
        currentIndex: -1

        onCurrentItemChanged: {
            if( !currentItem )
                return
        }

        Component.onCompleted: {
            model.clear()

            var bkps = database.dates()
            for( var i=0; i<bkps.length; i++ )
                model.append({"daysDate": bkps[i]})

            focus = true
        }
    }

    ScrollBar {
        scrollArea: history_list; height: history_list.height; width: 6*physicalPlatformScale
        anchors.right: history_list.right; anchors.top: history_list.top; color: "#ffffff"
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("History")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
