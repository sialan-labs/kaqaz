import QtQuick 2.0

Rectangle {
    id: line_edit_frame
    color: "#88eeeeee"
    height: 42*physicalPlatformScale
    width: 100*physicalPlatformScale

    property alias placeholder: pholder.text
    property alias text: main_item.text
    property alias echoMode: main_item.echoMode
    property alias lineFocus: main_item.focus

    signal accepted()

    Text {
        id: pholder
        anchors.fill: main_item
        font: main_item.font
        color: "#888888"
        visible: main_item.length == 0
        verticalAlignment: Text.AlignVCenter
    }

    TextInput {
        id: main_item
        anchors.fill: parent
        anchors.margins: 4*physicalPlatformScale
        font.pixelSize: 11*fontsScale
        font.family: globalFontFamily
        color: "#333333"
        verticalAlignment: Text.AlignVCenter
        onAccepted: line_edit_frame.accepted()
    }
}
