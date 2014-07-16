import QtQuick 2.2

Item {
    id: timer_point
    width: 80*physicalPlatformScale
    height: width
    smooth: true

    property bool anim: false
    property bool repeat: false
    property real animSpeed: 1500
    property real delay: 100
    property real endDelay: 100

    property alias color: point.color

    onRotationChanged: {
        if( rotation == 359 )
        {
            anim = false
            rotation = 0
            anim = true
            if( repeat )
                restart_timer.start()
        }
    }

    Behavior on rotation {
        NumberAnimation { easing.type: Easing.InOutQuint; duration: timer_point.anim? animSpeed : 0 }
    }

    Rectangle {
        id: point
        width: 15*physicalPlatformScale
        height: width
        x: timer_point.width - width
        y: timer_point.height/2 - height/2
        color: "#3B97EC"
        radius: width/2
    }

    Timer{
        id: timer
        interval: timer_point.delay
        repeat: false
        onTriggered: timer_point.rotation = 359
    }

    Timer{
        id: restart_timer
        interval: timer_point.endDelay
        repeat: false
        onTriggered: timer_point.start()
    }

    function start(){
        timer_point.anim = false
        timer_point.rotation = 0
        timer_point.anim = true
        timer.start()
    }
}
