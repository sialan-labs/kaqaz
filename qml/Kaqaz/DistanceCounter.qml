import QtQuick 2.2

Timer {
    id: counter
    repeat: true
    interval: 1

    property int ms: 0
    property real distance: 60*physicalPlatformScale

    property real cache: 0
    property real cache_time: 0

    onTriggered: cache_time += 1

    function startCounter(){
        cache_time = 0
        ms = 0
        cache = 0
        start()
    }

    function stopCounter(){
        stop()
        return cache_time
    }

    function addDistance( size ){
        cache += Math.abs(size)
        if( cache < distance )
            return

        ms = cache_time
        cache = 0
    }

    function getTime(){
        return ms
    }

    function speed(){
        return distance/ms
    }
}
