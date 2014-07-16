import QtQuick 2.0

Item {
    id: buy_pro
    anchors.fill: parent

    signal buy()

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 40*physicalPlatformScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*physicalPlatformScale

        Text {
            id: limit_text
            anchors.left: parent.left
            anchors.right: parent.right
            font.pointSize: 30*fontsScale
            font.family: globalFontFamily
            height: 70*physicalPlatformScale
            horizontalAlignment: Text.AlignHCenter
            color: "#333333"
            text: qsTr("BUY KAQAZ")
        }

        Text {
            id: choice_text
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: 12*fontsScale
            font.family: globalFontFamily
            color: "#333333"
            text: qsTr("Buy kaqaz unlimit version")
        }
    }

    Button {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 40*physicalPlatformScale
        anchors.rightMargin: 40*physicalPlatformScale
        anchors.bottomMargin: 20*physicalPlatformScale
        height: 42*physicalPlatformScale
        normalColor: "#4098bf"
        highlightColor: "#337fa2"
        text: qsTr("Buy")
        onClicked: buy_pro.buy()
    }
}
