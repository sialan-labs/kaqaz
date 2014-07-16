import QtQuick 2.0

Item {
    anchors.fill: parent

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: limit_text
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 30*fontsScale
            font.family: globalFontFamily
            color: "#333333"
            height: 70*physicalPlatformScale
            text: qsTr("DEMO EXPIRED")
        }

        Text {
            id: choice_text
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 13*fontsScale
            font.family: globalFontFamily
            color: "#333333"
            text: qsTr("Now you have 2 choice")
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: scroll_img.top
        font.pointSize: 9*fontsScale
        font.family: globalFontFamily
        color: "#666666"
        text: qsTr("scroll down")
    }

    Image {
        id: scroll_img
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20*physicalPlatformScale
        width: 80*physicalPlatformScale
        height: width
        sourceSize: Qt.size(width,height)
        fillMode: Image.PreserveAspectFit
        source: "files/scroll-down.png"
    }
}
