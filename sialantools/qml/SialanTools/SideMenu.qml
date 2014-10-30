import QtQuick 2.0

Item {
    id: sidemenu
    width: 100
    height: 62

    property Component delegate
    property variant item

    property real handleWidth: 20*physicalPlatformScale

    property alias menuWidth: item_frame.width
    property real percent: (menuWidth+item_frame.x)/menuWidth

    onDelegateChanged: {
        if( item )
            item.destroy()
        if( !delegate )
            return

        item = delegate.createObject(item_frame)
    }

    Item {
        id: item_frame
        width: sidemenu.width/2
        height: parent.height
        x: -width

        property bool anim: false

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: item_frame.anim? 400 : 0 }
        }
    }

    MouseArea {
        id: marea
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: handleWidth + menuWidth
        x: item_frame.x
        onMouseXChanged: {
            var newX = item_frame.x + mouseX-pinX
            if( newX > 0 )
                newX = 0

            item_frame.x = newX
        }
        onPressed: {
            pinX = mouseX
            item_frame.anim = false
        }
        onReleased: {
            item_frame.anim = true

            var basePercent = lastState? 0.8 : 0.2

            if( sidemenu.percent > basePercent ) {
                item_frame.x = 0
                lastState = true
            } else {
                item_frame.x = -menuWidth
                lastState = false
            }
        }

        property real pinX: 0
        property bool lastState: false
    }
}
