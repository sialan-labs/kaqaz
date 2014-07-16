import QtQuick 2.2

Item {
    id: picker_handler
    width: 100
    height: 62

    property alias press: marea.pressed

    onPressChanged: {
        if( !press )
            commited()
    }

    signal commited()
    signal moved()

    MouseArea {
        id: marea
        anchors.fill: parent
        onMouseXChanged: {
            picker_handler.x += mouseX - last_x
            picker_handler.moved()
        }
        onMouseYChanged: {
            picker_handler.y += mouseY - last_y
            picker_handler.moved()
        }
        onPressed: {
            last_x = width/2
            last_y = height
        }

        property real last_x
        property real last_y
    }
}
