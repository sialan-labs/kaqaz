import QtQuick 2.2

Item {
    id: abs_item
    width: 100
    height: itemHeight
    y: parent.invert? parent.height - height - index*height : index*height

    property int iid
    property string command

    property string tooltip: text
    property string text: iid

    property int index: 0

    property alias font: txt.font
    property alias icon: icn.source

    Image {
        id: icn
        height: 22*physicalPlatformScale
        anchors.verticalCenter: abs_item.verticalCenter
        anchors.left: parent.left
        anchors.margins: 5*physicalPlatformScale
        width: (source == "")? 0 : height
        smooth: true
    }

    Text {
        id: txt
        text: abs_item.text
        anchors.fill: parent
        anchors.margins: 4*physicalPlatformScale
        anchors.leftMargin: icn.x + icn.width + 10*physicalPlatformScale
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.family: globalFontFamily
    }
}
