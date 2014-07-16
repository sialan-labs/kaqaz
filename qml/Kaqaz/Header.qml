import QtQuick 2.0

Item {
    id: header
    width: 100
    height: 60*physicalPlatformScale

    property alias text: title_txt.text
    property bool light: false

    Row {
        id: back_row
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10*physicalPlatformScale
        width: 75*physicalPlatformScale
        visible: !kaqaz.isAndroid() && !backHandler

        Image {
            anchors.verticalCenter: parent.verticalCenter
            height: 20*physicalPlatformScale
            source: (!back_row.press && header.light)||(back_row.press && !header.light)? (height>48? "files/back_light_64.png" : "files/back_light_32.png") : (height>48? "files/back_64.png" : "files/back_32.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: 0.8
        }

        Text {
            id: back_txt
            font.pointSize: 14*fontsScale
            font.family: globalFontFamily
            y: parent.height/2 - height/2 + 2*physicalPlatformScale
            color: (!back_row.press && header.light)||(back_row.press && !header.light)? "#ffffff" : "#111111"
        }

        property bool press: false
    }

    MouseArea {
        anchors.fill: back_row
        onClicked: kaqaz_root.back()
        onPressed: back_row.press = true
        onReleased: back_row.press = false
        visible: back_row.visible
    }

    Text {
        id: title_txt
        font.pointSize: 16*fontsScale
        font.family: globalFontFamily
        y: parent.height/2 - height/2 + 2*physicalPlatformScale
        anchors.horizontalCenter: parent.horizontalCenter
        color: header.light? "#ffffff" : "#333333"
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    Component.onCompleted: {
        initTranslations()
    }

    function initTranslations(){
        back_txt.text = qsTr("Back")
    }
}
