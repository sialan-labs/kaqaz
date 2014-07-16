import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    width: 100
    height: 62

    Text {
        id: title
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: lang_list.top
        anchors.leftMargin: 40*physicalPlatformScale
        anchors.rightMargin: 40*physicalPlatformScale
        anchors.bottomMargin: 10*physicalPlatformScale
        font.pointSize: 20*fontsScale
        horizontalAlignment: Text.AlignHCenter
        font.family: globalFontFamily
        color: "#333333"
    }

    ListView {
        id: lang_list
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 100*physicalPlatformScale
        anchors.verticalCenter: parent.verticalCenter
        height: 300*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true

        property string lang: kaqaz.currentLanguage()

        model: ListModel {}
        header: Item{ width: 10; height: 20*physicalPlatformScale }
        footer: Item{ width: 10; height: 20*physicalPlatformScale }
        delegate: Rectangle {
            id: item
            width: lang_list.width
            height: 40*physicalPlatformScale
            color: marea.pressed || selected? "#883B97EC" : "#00000000"
            radius: 3*physicalPlatformScale

            property string text: name
            property bool selected: lang_list.lang == text

            Text{
                id: txt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text
                font.pointSize: 13*fontsScale
                font.family: globalFontFamily
                color: marea.pressed? "#ffffff" : "#333333"
            }

            MouseArea{
                id: marea
                anchors.fill: parent
                onClicked: {
                    kaqaz.setCurrentLanguage(item.text)
                    lang_list.lang = kaqaz.currentLanguage()
                }
            }
        }

        focus: true
        highlight: Rectangle { color: "#3B97EC"; radius: 3; smooth: true }
        currentIndex: -1

        onCurrentItemChanged: {
            if( !currentItem )
                return
        }

        Component.onCompleted: {
            model.clear()

            var langs = kaqaz.languages()
            for( var i=0; i<langs.length; i++ )
                model.append({"name": langs[i]})

            focus = true
        }
    }

    ScrollBar {
        scrollArea: lang_list; height: lang_list.height; width: 8
        anchors.left: lang_list.right; anchors.top: lang_list.top;color: "#888888"
    }

    Rectangle {
        id: lang_rect
        anchors.fill: lang_list

        gradient: Gradient {
            GradientStop { position: 0.0; color: "#F4F4F4" }
            GradientStop { position: 0.1; color: "#00000000" }
            GradientStop { position: 0.9; color: "#00000000" }
            GradientStop { position: 1.0; color: "#F4F4F4" }
        }
    }

    function initTranslations() {
        title.text = qsTr("Select Language")
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    Component.onCompleted: initTranslations()
}
