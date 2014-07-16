import QtQuick 2.0

Item {
    width: 100
    height: 62

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        Image {
            width: 80*physicalPlatformScale
            height: width
            sourceSize: Qt.size(width,height)
            source: "files/sialan.png"
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "SIALAN LABS"
            font.pointSize: 20*fontsScale
            font.weight: Font.DemiBold
            font.family: globalFontFamily
            color: "#333333"
        }
    }

    GlowedAnimatedText {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20*physicalPlatformScale
        text: "slide to next"
        font.pointSize: 12*fontsScale
        font.family: globalFontFamily
        color: "#333333"
        speed: 1200
        glowWidth: 60*physicalPlatformScale
        direction: Qt.RightToLeft
        Component.onCompleted: start()
    }
}
