import QtQuick 2.0

Item {
    width: 100
    height: 62

    property int selectedGid: -1

    ListView {
        id: groups_list
        anchors.fill: parent
        highlightMoveDuration: 250
        maximumFlickVelocity: flickVelocity

        model: ListModel {}
        delegate: MenuButton {
            height: 40*physicalPlatformScale
            width: groups_list.width
            normalColor: "#00000000"
            highlightColor: "#4098bf"
            textColor: press? "#ffffff" : "#4098bf"
            textFont.weight: Font.Normal
            textFont.pixelSize: 11*fontsScale
            textFont.bold: false
            textAlignment: Text.AlignLeft
            text: name
            onClicked: selectedGid = gid
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

            main.focus = true
        }
    }

    ScrollBar {
        scrollArea: groups_list; height: groups_list.height; width: 6*physicalPlatformScale
        anchors.right: groups_list.right; anchors.top: groups_list.top; color: "#000000"
    }
}
