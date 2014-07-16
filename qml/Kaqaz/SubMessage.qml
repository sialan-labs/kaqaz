import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: submsg
    anchors.fill: parent
    opacity: 0
    visible: opacity != 0

    property variant item
    property alias source: blur.source

    Behavior on opacity {
        NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
    }

    Timer {
        id: destroy_timer
        interval: 400
        repeat: false
        onTriggered: submsg.destroy()
    }

    onItemChanged: {
        if( !item ) {
            opacity = 0
            destroy_timer.restart()
        } else {
            item.parent = submsg
            opacity = 1
        }
    }

    MouseArea {
        anchors.fill: parent
    }

    FastBlur {
        id: blur
        anchors.fill: parent
        radius: 64*physicalPlatformScale
        cached: true
    }

    Rectangle {
        anchors.fill: parent
        color: "#66ffffff"
    }

    function hide() {
        if( item && item.hide )
            item.hide()

        opacity = 0
        destroy_timer.restart()
    }

    Component.onCompleted: subMessage = submsg
    Component.onDestruction: if( item ) item.destroy()
}
