import QtQuick 2.2

Item {
    id: slide_menu
    width: 100
    height: 62

    property bool isVisible: false
    property variant item

    onHeightChanged: refreshItemGeometry()
    onWidthChanged: refreshItemGeometry()
    onItemChanged: {
        if( item )
            item.parent = menu

        refreshItemGeometry()
    }

    Timer{
        id: hide_timer
        repeat: false
        interval: 250
        onTriggered: slide_menu.visible = false
    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        onClicked: slide_menu.close()
    }

    Rectangle{
        id: menu
        x: isVisible? 0 : -width
        width: parent.width/2
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: "#eeeeee"

        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
        }

        Behavior on x {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }
    }

    Rectangle {
        id: shadow
        x: menu.x + menu.width
        y: -height
        width: menu.height
        height: 5*physicalPlatformScale
        opacity: slide_menu.isVisible? 1 : 0
        rotation: 90
        transformOrigin: Item.BottomLeft
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#66000000" }
        }

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }
    }

    function refreshItemGeometry(){
        if( !item )
            return

        item.parent = menu
        item.x = 0
        item.y = 0
        item.height = menu.height
        item.width = menu.width
    }

    function close(){
        hide_timer.restart()
        slide_menu.isVisible = false
        if( slide_menu.item )
            slide_menu.item.destroy()
    }

    function show( item ){
        hide_timer.stop()
        slide_menu.visible = true
        slide_menu.isVisible = true
        slide_menu.item = item
    }
}
