import QtQuick 2.0

Rectangle {
    id: bpanel
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: "#D9D9D9"
    height: 0

    property variant item

    Behavior on height {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
    }

    onItemChanged: {
        if( privates.oldItem )
            privates.oldItem.destroy()

        if( item ) {
            item.parent = bpanel
            item.anchors.top = bpanel.top
            item.anchors.left = bpanel.left
            item.anchors.right = bpanel.right
            bpanel.height = item.height + navigationBarHeight
        }

        privates.oldItem = item
    }

    QtObject {
        id: privates
        property variant oldItem
    }

    Timer {
        id: destroy_timer
        interval: 400
        onTriggered: if(bpanel.item) bpanel.item.destroy()
    }

    function hide() {
        height = 0
        destroy_timer.restart()
    }
}
