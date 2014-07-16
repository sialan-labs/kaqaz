import QtQuick 2.0

Item {
    id: group_chooser_back
    width: kaqaz.mobile? 75*physicalPlatformScale : 100*physicalPlatformScale
    height: 30*physicalPlatformScale

    property real radius: 5*physicalPlatformScale
    property color color: "#aaaaaa"

    property int group
    property bool press: false

    onGroupChanged: {
        txt.text = database.groupName(group)
        color = database.groupColor(group)
    }

    Rectangle{
        anchors.fill: parent
        anchors.bottomMargin: group_chooser_back.radius
        color: group_chooser_back.press? "#3B97EC" : group_chooser_back.color
    }

    Rectangle{
        anchors.fill: parent
        radius: group_chooser_back.radius
        color: group_chooser_back.press? "#3B97EC" : group_chooser_back.color
    }

    Text{
        id: txt
        x: (width>group_chooser_back.width)? 0 : group_chooser_back.width/2 - width/2
        y: group_chooser_back.height/2 - height/2
        font.bold: kaqaz.tablet
        font.pointSize: kaqaz.touchDevice? (kaqaz.mobile? 8*fontsScale : 9*fontsScale) : 10*fontsScale
        font.family: globalFontFamily
        color: "#ffffff"
        text: qsTr("No Label")
    }

}
