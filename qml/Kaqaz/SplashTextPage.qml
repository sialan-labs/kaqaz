import QtQuick 2.0

Item {
    width: 100
    height: 62

    property alias text: txt.text

    Text {
        id: txt
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        font.pointSize: 18*fontsScale
        font.family: globalFontFamily
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        color: "#333333"
    }
}
