import QtQuick 2.2
import Kaqaz 1.0

Rectangle {
    id: sidebar_list
    width: 100
    height: 62
    color: "#00000000"

    signal itemSelected( int id, int type )
    signal commandSelected( string cmd )

    property color fontColor: "#333333"

    property variant cacheDate

    Connections{
        target: database
        onGroupsListChanged: refresh()
        onDatesListChanged: refresh()
    }

    ListView {
        id: list_view
        anchors.fill: parent
        anchors.topMargin: 20*physicalPlatformScale
        anchors.bottomMargin: 20*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true
        maximumFlickVelocity: flickVelocity

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: list_view.width
            height: 32*physicalPlatformScale
            color: (press && type != -1)? "#3B97EC" : "#00000000"
            radius: 3*physicalPlatformScale

            property string text: textValue
            property int iid: guidValue
            property int type: typeValue
            property string command: cmdValue
            property string icon: iconValue

            property bool press: false

            Component.onCompleted:  {
                if( iid == -1 )
                    return
                if( type == 1 ){
                    color_rect.color = database.groupColor(iid)
                    text = database.groupName(iid)
                }
                else
                if( type == 0 ){
                    var days = iid
                    if( days === kaqaz.currentDays )
                        text = qsTr("Today")
                    else
                    if( days === kaqaz.currentDays-1 )
                        text = qsTr("Yesterday")
                    else
                    if( days === kaqaz.currentDays-2 )
                        text = qsTr("Two days ago")
                    else
                        text = kaqaz.convertIntToStringDate(days,"yyyy MMM dd - dddd")
                }
            }

            Connections{
                target: list_view
                onMovementStarted: press = false
                onFlickStarted: press = false
            }

            Rectangle {
                id: color_rect
                anchors.top: item.top
                anchors.bottom: item.bottom
                anchors.margins: 1*physicalPlatformScale
                anchors.left: icon_img.left
                width: 7*physicalPlatformScale
                color: "#00000000"
            }

            Image {
                id: icon_img
                height: 22*physicalPlatformScale
                width: height
                anchors.left: item.left
                anchors.leftMargin: 6*physicalPlatformScale
                anchors.verticalCenter: item.verticalCenter
                source: item.icon
                smooth: true
            }

            Text{
                id: txt
                anchors.left: (icon_img.source != "")? icon_img.right : color_rect.right
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                anchors.leftMargin: 6*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text
                font.pointSize: 9*fontsScale
                font.family: globalFontFamily
                horizontalAlignment: Qt.AlignLeft
                color: item.press? "#ffffff" : fontColor
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    if( item.command === "clean" )
                        main.clean()
                    else
                    if( item.command === "search" )
                        main.showSearch()
                    else
                    if( item.command === "lock" )
                        lock()
                    else
                    if( item.command === "preferences" )
                        main.showPrefrences()
                    else
                    if( item.command === "history" )
                        main.showHistory()

                    if( item.command !== "" )
                        sidebar_list.commandSelected( item.command )
                    else
                    if( item.type != -1 )
                        sidebar_list.itemSelected( item.iid, (item.type==0)? PaperManager.Date : PaperManager.Group )
                }
            }
        }

        focus: true
        currentIndex: -1

        Component.onCompleted: refresh()
        function refresh(){
            model.clear()

            model.append({"textValue": qsTr("Clean Papers"), "cmdValue": "clean", "typeValue": 0, "guidValue": -1, "iconValue": "files/clean-papers.png"})
            model.append({"textValue": qsTr("Search"), "cmdValue": "search", "typeValue": 0, "guidValue": -1, "iconValue": "files/search.png"})
            if( kaqaz.isDesktop() && database.password().length != 0 )
                model.append({"textValue": qsTr("Lock"), "cmdValue": "lock", "typeValue": 0, "guidValue": -1, "iconValue": "files/lock.png"})
            model.append({"textValue": qsTr("Preferences"), "cmdValue": "preferences", "typeValue": 0, "guidValue": -1, "iconValue": "files/preferences.png"})

            model.append({"textValue": "", "cmdValue": "", "typeValue": -1, "guidValue": -1, "iconValue": ""})

            model.append({"textValue": qsTr("History"), "cmdValue": "history", "typeValue": 0, "guidValue": -1, "iconValue": "files/history.png"})
            var list = database.lastThreeDays()
            for( var i=0; i<list.length; i++ )
                model.append({"textValue": "", "cmdValue": "", "typeValue": 0, "guidValue": list[i], "iconValue": "files/history.png"})

            model.append({"textValue": "", "cmdValue": "", "typeValue": -1, "guidValue": -1, "iconValue": ""})

            list = database.groups()
            for( var i=0; i<list.length; i++ ) {
                var gid = list[i]
                var name = database.groupName(gid)
                if( database.groupIsDeleted(gid) )
                    continue

                model.append({"textValue": "", "cmdValue": "", "typeValue": 1, "guidValue": gid, "iconValue": ""})
            }
        }
    }

    ScrollBar {
        scrollArea: list_view; height: list_view.height; width: 8
        anchors.right: list_view.right; anchors.top: list_view.top; color: "#ffffff"
    }

    Connections{
        target: kaqaz
        onLanguageChanged: sidebar_list.refresh()
    }

    function refresh(){
        list_view.refresh()
    }
}
