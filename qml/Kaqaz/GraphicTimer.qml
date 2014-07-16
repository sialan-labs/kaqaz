import QtQuick 2.2

Item {
    id: graphic_timer
    width: 100
    height: 100
    x: 200
    y: 200
    visible: false

    property real delayStart: 0
    property real interval: 2000

    property bool running: false

    signal done()

    GraphicTimerPoint {
        id: point1
        anchors.fill: parent
        delay: 100
        endDelay: 300
        animSpeed: interval-400
    }

    GraphicTimerPoint {
        id: point2
        anchors.fill: parent
        delay: 200
        endDelay: 200
        animSpeed: interval-400
    }

    GraphicTimerPoint {
        id: point3
        anchors.fill: parent
        delay: 300
        endDelay: 100
        animSpeed: interval-400
    }

    GraphicTimerPoint {
        id: point4
        anchors.fill: parent
        delay: 400
        endDelay: 0
        animSpeed: interval-400
    }

    Timer {
        id: delay_timer
        interval: delayStart
        repeat: false
        onTriggered: {
            visible = true
            point1.start()
            point2.start()
            point3.start()
            point4.start()
            timer.start()
        }
    }

    Timer {
        id: timer
        interval: graphic_timer.interval
        repeat: false
        onTriggered: {
            visible = false
            graphic_timer.running = false
            graphic_timer.done()
        }
    }

    function start(){
        delay_timer.start()
        running = true
    }

    function stop(){
        running = false
        visible = false
        timer.stop()
        delay_timer.stop()
    }
}
