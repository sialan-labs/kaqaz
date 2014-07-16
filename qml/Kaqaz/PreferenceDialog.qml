import QtQuick 2.2

AnimationItem {
    id: preference_dialog
    x: 0
    y: 0
    width: parent.width
    height: parent.height

    property variant item
    property variant prevItem

    Behavior on opacity {
        NumberAnimation { easing.type: preference_dialog.easing.type; duration: anim? anim_time : 0 }
    }

    onItemChanged: {
        if( !item )
            return

        item.parent = preference_dialog
        item.x = 0
        item.y = 0
        item.width = width
        item.height = height
        item.visible = true

        if( prevItem )
            prevItem.visible = false
        prevItem = item
    }

    onWidthChanged: {
        if( !item )
            return

        item.width = width
    }

    onHeightChanged:  {
        if( !item )
            return

        item.height = height
    }
}
