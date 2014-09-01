import QtQuick 2.0

Item {
    id: todo_item
    height: 40*physicalPlatformScale

    property alias alignment: txt.horizontalAlignment
    property color checkColor: "#888888"
    property alias text: txt.text
    property alias checked: check_check.visible

    Item {
        id: check_frame
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: height
        x: alignment==Text.AlignLeft? 0 : todo_item.width-width

        Rectangle {
            id: check
            anchors.fill: parent
            anchors.margins: 6*physicalPlatformScale
            radius: height/2
            border.color: checkColor
            border.width: 1*physicalPlatformScale
            color: "#00000000"

            Rectangle {
                id: check_check
                color: checkColor
                radius: height/2
                anchors.fill: parent
                anchors.margins: 3*physicalPlatformScale
                visible: false
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: check_check.visible = !check_check.visible
        }
    }

    Text {
        id: txt
        x: alignment==Text.AlignLeft? check_frame.width : 0
        width: todo_item.width - check_frame.width
        anchors.verticalCenter: parent.verticalCenter
    }
}
