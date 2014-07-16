import QtQuick 2.2

Rectangle {
    id: button
    smooth: true
    width: row.width + 20*physicalPlatformScale
    height: 30*physicalPlatformScale
//    radius: 2*physicalPlatformScale
    color: press? highlightColor : normalColor

    property alias text: txt.text
    property alias icon: icn.source
    property alias fontSize: txt.font.pointSize
    property alias textFont: txt.font

    property alias hoverEnabled: marea.hoverEnabled

    property alias iconHeight: icn.height
    property bool iconCenter: false

    property bool press: false
    property bool enter: false

    property string highlightColor: "#0d80ec"
    property string normalColor: "#00000000"
    property alias textColor: txt.color

    signal clicked()

    Row {
        id: row
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: 4*physicalPlatformScale
        anchors.margins: 3*physicalPlatformScale
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4*physicalPlatformScale

        Image {
            id: icn
            anchors.verticalCenter: parent.verticalCenter
            height: source==""? 0 : parent.height-14*physicalPlatformScale
            width: height
            sourceSize.width: width
            sourceSize.height: height
            smooth: true
        }

        Text{
            id: txt
            y: parent.height/2 - height/2 - 1*physicalPlatformScale
            color: "#ffffff"
            font.bold: kaqaz.isWindows()? false : true
            font.family: globalFontFamily
            font.pointSize: 9*fontsScale
        }
    }

    MouseArea{
        id: marea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: button.enter = true
        onExited: button.enter = false
        onPressed: button.press = true
        onReleased: button.press = false
        onClicked: button.clicked()
    }
}
