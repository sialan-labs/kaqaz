import QtQuick 2.2

AnimationItem {
    id: side_panel
    x: pinX-padX
    easing.type: Easing.OutQuint
    anim_time: 400

    property real edge: 20

    property real pinX: 0
    property real padX: 0

    property real percent: (pinX - x)*100/(side_panel.width + edge)
    property bool visibled: (side_panel.padX != 0 || x != pinX-padX)

    signal itemSelected( int id, int type )

    MouseArea{
        id: mousearea
        x: maximizeMode? -kaqaz_root.width : -10*physicalPlatformScale
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: maximizeMode? kaqaz_root.width + 30*physicalPlatformScale : 40*physicalPlatformScale

        onMouseXChanged: {
            if( Math.abs(mapToItem(side_panel.parent,mouseX,0).x-pin_g_x) > 10 )
                moved_x = true
            if( !moved_x )
                return
            if( side_panel.padX + (pin_x-mouseX) > side_panel.width + edge )
            {
                side_panel.padX = side_panel.width + edge
                return
            }
            if( side_panel.padX + (pin_x-mouseX) < 0 )
            {
                side_panel.padX = 0
                return
            }

            var move_size = pin_x-mouseX
            last_move_x = (move_size != 0)? move_size : last_move_x
            side_panel.padX += move_size
        }

        onPressed: {
            pin_g_x = mapToItem(side_panel.parent,mouseX,0).x
            pin_x = mouseX
            last_move_x = 0
            moved_x = false
            opened = side_panel.isVisible()

            main.focus = true
            kaqaz.hideKeyboard()
        }

        onReleased: {
            startAnimation()
            if( !moved_x && maximizeMode )
                side_panel.padX = 0

            if( opened ) {
                if( side_panel.padX < 2*(side_panel.width + edge)/3 )
                    side_panel.padX = 0
                else
                    side_panel.padX = side_panel.width + edge
            } else {
                if( side_panel.padX < 1*(side_panel.width + edge)/3 )
                    side_panel.padX = 0
                else
                    side_panel.padX = side_panel.width + edge
            }

            if( side_panel.padX == 0 )
                maximizeMode = false
            else
                maximizeMode = true
        }

        property real pin_x: 0
        property real pin_g_x: 0
        property real last_move_x: 0
        property bool moved_x: false
        property bool opened: true

        property bool maximizeMode: false

        function end(){
            startAnimation()
            side_panel.padX = 0
            maximizeMode = false
        }
    }

    function end(){
        mousearea.end()
    }

    function isVisible(){
        if( side_panel.padX == side_panel.width + edge )
            return true
        else
            return false
    }

    function hidePanel(){
        startAnimation()
        side_panel.padX = 0
    }

    function showPanel(){
        startAnimation()
        side_panel.padX = side_panel.width + edge
        mousearea.opened = true
        mousearea.maximizeMode = true
    }
}
