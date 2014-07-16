import QtQuick 2.0

Item {
    id: page
    width: 100
    height: 62

    property alias text: txt.text
    property alias image: img.source

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*physicalPlatformScale

        Text {
            id: txt
            anchors.left: parent.left
            anchors.right: parent.right
            font.pointSize: 18*fontsScale
            font.family: globalFontFamily
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#333333"
        }

        Image {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width*0.7
            height: width*1.47
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectFit
        }
    }
}
