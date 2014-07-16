import QtQuick 2.2

Item {
    id: search_panel
    width: 100
    height: 62

    property alias text: txt.text

    signal keywordChanged( string text )

    onTextChanged: search_timer.restart()

    Rectangle{
        id: back
        color: "#66ffffff"
        anchors.fill: parent
        anchors.margins: 20*physicalPlatformScale
        anchors.topMargin: 10*physicalPlatformScale
        anchors.bottomMargin: 0
        radius: 3
    }

    Image {
        id: icon
        anchors.top: back.top
        anchors.bottom: back.bottom
        anchors.left: back.left
        anchors.margins: 10*physicalPlatformScale
        width: height
        source: "files/search.png"
    }

    Text{
        id: placeholder_txt
        anchors.verticalCenter: back.verticalCenter
        anchors.left: icon.right
        anchors.right: back.right
        anchors.margins: 10*physicalPlatformScale
        color: "#ffffff"
        visible: (!txt.focus && txt.text == "")
        font: txt.font
    }

    TextInput{
        id: txt
        anchors.verticalCenter: back.verticalCenter
        anchors.left: icon.right
        anchors.right: back.right
        anchors.margins: 10*physicalPlatformScale
        font.pointSize: 13*fontsScale
        font.family: globalFontFamily
        inputMethodHints: Qt.ImhNoPredictiveText
    }

    Timer{
        id: active_focus_timer
        interval: 501
        repeat: false
        onTriggered: txt.focus = true
    }

    Timer{
        id: search_timer
        interval: 700
        repeat: false
        onTriggered: search_panel.keywordChanged(text)
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        placeholder_txt.text = qsTr("Search keyword")
    }

    Component.onCompleted: {
        active_focus_timer.start()
        touchToBack = true
        initTranslations()
    }
}
