import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: modern_pbar
    anchors.fill: parent
    opacity: 0

    Behavior on opacity {
        NumberAnimation { easing.type: Easing.OutCubic; duration: 400 }
    }

    property alias source: desaturate.source
    property real percent: 0

    Desaturate {
        id: desaturate
        anchors.fill: parent
        desaturation: 1-modern_pbar.percent/100
        cached: true
    }

    ProgressBar {
        y: parent.height/2 + 30*physicalPlatformScale
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*physicalPlatformScale
        height: 5*physicalPlatformScale
        percent: modern_pbar.percent
    }

    function setValue(value){
        percent = value
    }

    Component.onCompleted: opacity = 1
}
