import QtQuick 2.0
import SialanTools 1.0

ListView {
    id: color_list
    anchors.fill: parent
    anchors.margins: 15*physicalPlatformScale
    clip: true
    model: ListModel{}

    property real selectedPen: 1

    delegate: Rectangle {
        anchors.right: parent.right
        anchors.left: parent.left
        height: 48*physicalPlatformScale
        color: mousearea.pressed? "#aa0d80ec" : "#00000000"

        Item {
            id: item
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 4*physicalPlatformScale
            width: height

            Rectangle{
                id: rectangle
                anchors.centerIn: parent
                width: (itemWidth+2)*physicalPlatformScale
                height: width
                radius: width/2
                color: "#000000"
            }
        }

        Text {
            x: 40*physicalPlatformScale
            anchors.verticalCenter: parent.verticalCenter
            text: itemWidth + " " + qsTr("Pixel")
            horizontalAlignment: Text.AlignLeft
            font.family: SApp.globalFontFamily
            font.pixelSize: 11*fontsScale
            color: "#333333"
        }

        MouseArea{
            id: mousearea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                selectedPen = itemWidth
                hidePointDialog()
            }
        }
    }

    ScrollBar {
        scrollArea: color_list; height: color_list.height; width: 6*physicalPlatformScale
        anchors.right: color_list.right; anchors.top: color_list.top; color: "#000000"
    }

    Component.onCompleted: {
        model.clear()
        for( var i=1; i<5; i++ )
            model.append({"itemWidth": i})
    }
}
