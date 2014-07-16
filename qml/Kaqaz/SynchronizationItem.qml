import QtQuick 2.0


Rectangle {
    id: sync_item
    anchors.left: parent.left
    anchors.right: parent.right
    height: column.height + 20*physicalPlatformScale
    color: marea.pressed? "#880d80ec" : "#88ffffff"

    property alias image: img.source
    property alias text: txt.text

    signal clicked()

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Image {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            width: 128*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectFit
        }

        Text {
            id: txt
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 12*fontsScale
            font.family: globalFontFamily
            color: "#007ee5"
        }
    }

    MouseArea {
        id: marea
        anchors.fill: parent
        onClicked: sync_item.clicked()
    }
}
