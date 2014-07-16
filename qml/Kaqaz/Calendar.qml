import QtQuick 2.2

Item {
    width: 100
    height: 62

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    ListView {
        id: preference_list
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: preference_list.width
            height: 60*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string text: name
            property int calendarID: type
            property bool press: false

            Connections{
                target: preference_list
                onMovementStarted: press = false
                onFlickStarted: press = false
            }

            Text{
                id: txt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text
                font.pointSize: 15*fontsScale
                font.family: globalFontFamily
                color: item.press? "#ffffff" : "#333333"
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    kaqaz.setCalendar(item.calendarID)
                    showTooltip( qsTr("Calendar changed") )
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

            var cals = kaqaz.calendarsID()
            for( var i=0; i<cals.length; i++ )
                model.append({"type": cals[i], "name": kaqaz.calendarName(cals[i])})

            focus = true
        }
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("Calendars")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
