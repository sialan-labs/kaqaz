import QtQuick 2.0

GlowedText {
    id: glow_txt

    property int direction: Qt.LeftToRight
    property real speed: 1000

    QtObject {
        id: privates
        property bool anims: false
    }

    Behavior on glowX {
        NumberAnimation{ easing.type: Easing.Linear; duration: privates.anims? glow_txt.speed : 0 }
    }

    Timer {
        id: reset_timer
        interval: glow_txt.speed*1.7
        onTriggered: glow_txt.start()
    }

    function start() {
        switch(direction)
        {
        case Qt.LeftToRight:
            privates.anims = false
            glowX = -glowWidth
            privates.anims = true
            glowX = glow_txt.width
            reset_timer.restart()
            break;

        case Qt.RightToLeft:
            privates.anims = false
            glowX = glow_txt.width
            privates.anims = true
            glowX = -glowWidth
            reset_timer.restart()
            break;
        }
    }

    function stop() {
        privates.anims = false
        glowX = glow_txt.width
        reset_timer.stop()
    }
}
