import QtQuick 2.0

Item {
    id: done_page
    width: 100
    height: 62

    signal finished()

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: 20*physicalPlatformScale

        Image {
            id: img
            anchors.horizontalCenter: parent.horizontalCenter
            width: 140*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            fillMode: Image.PreserveAspectFit
            source: "files/done.png"
        }

        Text {
            id: txt
            anchors.left: parent.left
            anchors.right: parent.right
            font.pointSize: 18*fontsScale
            font.family: globalFontFamily
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            color: "#333333"
            text: qsTr("Start Kaqaz")
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            kaqaz.setTutorialCompleted(true)
            done_page.finished()
        }
    }
}
