import QtQuick 2.0

Item {
    id: tp_handler

    property variant touchPoint

    signal positionChanged( real x, real y )

    Connections {
        target: touchPoint
        onPressedChanged: update_timer.stop()
        onXChanged: update_timer.startTimer(touchPoint.x,touchPoint.y,true,false)
        onYChanged: update_timer.startTimer(touchPoint.x,touchPoint.y,false,true)
    }

    Timer {
        id: update_timer
        interval: 1
        onTriggered: {
            tp_handler.positionChanged(bx,by)
            x_avlb = false
            y_avlb = false
        }

        property real bx
        property real by

        property bool x_avlb: false
        property bool y_avlb: false

        function startTimer(x,y,xSignal,ySignal) {
            bx = x
            by = y

            if( (xSignal && x_avlb) || (ySignal && y_avlb) ) {
                tp_handler.positionChanged(bx,by)
                x_avlb = false
                y_avlb = false
                stop()
            }

            if( xSignal )
                x_avlb = true
            if( ySignal )
                y_avlb = true

            if( x_avlb && y_avlb ) {
                tp_handler.positionChanged(bx,by)
                x_avlb = false
                y_avlb = false
                stop()
            } else {
                restart()
            }
        }
    }
}
