import QtQuick 2.2

Item {
    id: group_selector
    width: 100
    height: 62

    property real itemsHeight: 50*physicalPlatformScale

    signal selected( string guid )

    ListView {
        id: groups_list
        anchors.fill: parent
        anchors.bottomMargin: 10*physicalPlatformScale
        anchors.topMargin: 10*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true
        maximumFlickVelocity: flickVelocity

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: groups_list.width
            height: group_selector.itemsHeight
            color: press? "#3B97EC" : "#00000000"

            property string text: name
            property int groupId: gid
            property bool press: false

            onPressChanged: hideRollerDialog()

            Connections{
                target: groups_list
                onMovementStarted: press = false
                onFlickStarted: press = false
            }

            Rectangle{
                id: clr_item
                width: item.groupId == -1? item.width : 15*physicalPlatformScale
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.margins: 2*physicalPlatformScale
                anchors.leftMargin: item.groupId == -1? 0 : 10*physicalPlatformScale
                color: item.groupId == -1? "#00CD3A" : database.groupColor(item.groupId)
            }

            Text{
                id: txt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                anchors.leftMargin: 44*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text
                font.pointSize: 10*fontsScale
                font.family: globalFontFamily
                color: item.groupId==-1? "#ffffff" : "#333333"
                horizontalAlignment: Text.AlignLeft
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    group_selector.selected(groupId)
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
            refresh()
        }

        function refresh(){
            model.clear()

            var list = database.groups()
            for( var i=0; i<list.length; i++ ) {
                var gid = list[i]
                var name = database.groupName(gid)
                if( database.groupIsDeleted(gid) )
                    continue

                model.append({"name": name, "gid": gid})
            }

            model.append({"name": qsTr("Add Label"), "gid": -1})
            main.focus = true
        }
    }

    ScrollBar {
        scrollArea: groups_list; height: groups_list.height; width: 8
        anchors.right: groups_list.right; anchors.top: groups_list.top; color: "#000000"
    }

    function realHeight(){
        return groups_list.count*itemsHeight
    }
}
