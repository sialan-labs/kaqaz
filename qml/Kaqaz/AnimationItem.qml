import QtQuick 2.2

Item {
    id: animation_item
    property bool anim: false
    property int anim_time: 250
    property alias easing: anim_item.easing

    signal animationFinished()

    Behavior on x {
        NumberAnimation { id: anim_item; easing.type: Easing.OutCubic; duration: anim? anim_time : 0 }
    }

    Timer{
        id: anim_disabler
        interval: anim_time
        repeat: false
        onTriggered: {
            anim = false
            animation_item.animationFinished()
        }
    }

    function startAnimation(){
        anim = true
        anim_disabler.start()
    }
}
