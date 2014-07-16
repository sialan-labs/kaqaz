import QtQuick 2.0

Rectangle {
    id: tooltip
    width: txt.width + padding*2
    height: txt.height + padding*1.5
    radius: 3*physicalPlatformScale
    smooth: true
    opacity: 0
    color: "#333333"
    visible: opacity != 0

    property int interval: 1500
    property real padding: 8*physicalPlatformScale

    Behavior on opacity {
        NumberAnimation { id: anim_item; easing.type: Easing.OutCubic; duration: 250 }
    }

    Text{
        id: txt
        x: tooltip.padding
        y: tooltip.padding*0.75
        font.pointSize: 10*fontsScale
        font.family: globalFontFamily
        color: "#ffffff"
    }

    Timer{
        id: hide_timer
        interval: tooltip.interval + 250
        repeat: false
        onTriggered: tooltip.opacity = 0
    }

    function showText( text ){
        txt.text = text
        opacity = 0.9
        hide_timer.restart()
    }
}
