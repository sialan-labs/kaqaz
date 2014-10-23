import QtQuick 2.0
import Kaqaz 1.0
import SialanTools 1.0

Item {
    width: 100
    height: 62

    property string defaultFile: ":/translations_sources/lang-en.ts"

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        onBeginBack: {
            tr_model.saveTo( kaqaz.translatorFilePath() )
        }
    }

    Row {
        id: section_row
        anchors.top: parent.top
        anchors.right: parent.right
        height: done_section_text.height
        anchors.margins: 4*physicalPlatformScale

        Text {
            id: done_section_text
            font.pixelSize: 20*fontsScale
            font.family: SApp.globalFontFamily
            text: tr_model.doneCount + "/"
        }

        Text {
            id: count_section_text
            font.pixelSize: 12*fontsScale
            font.family: SApp.globalFontFamily
            anchors.bottom: parent.bottom
            text: tr_model.count
        }
    }

    TranslationModel {
        id: tr_model
        Component.onCompleted: reload()

        function reload() {
            file = ""
            if( kaqaz.existsFile(kaqaz.translatorFilePath()) )
                file = kaqaz.translatorFilePath()
            else
                file = defaultFile
        }
    }

    ListView {
        id: tr_view
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.bottom: btns_row.top
        anchors.right: parent.right
        maximumFlickVelocity: flickVelocity
        clip: true
        spacing: 20*physicalPlatformScale
        model: tr_model

        delegate: Item {
            id: item
            width: tr_view.width
            height: column.height

            Column {
                id: column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 20*physicalPlatformScale
                spacing: 2*physicalPlatformScale

                Text {
                    width: column.width
                    text: originalText
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font.pixelSize: 14*fontsScale
                    font.family: SApp.globalFontFamily
                    textFormat: Text.PlainText
                    color: "#333333"
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: tr_text.height + 20*physicalPlatformScale<40*physicalPlatformScale? 40*physicalPlatformScale : tr_text.height + 20*physicalPlatformScale
                    color: "#88ffffff"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: tr_text.focus = true
                    }

                    STextEdit {
                        id: tr_text
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.margins: 20*physicalPlatformScale
                        wrapMode: TextInput.WrapAnywhere
                        text: translation
                        font.pixelSize: 11*fontsScale
                        font.family: SApp.globalFontFamily
                        color: "#333333"
                        onTextChanged: translation = text
                    }
                }
            }
        }
    }

    ScrollBar {
        scrollArea: tr_view; height: tr_view.height; width: 6*physicalPlatformScale
        anchors.right: tr_view.right; anchors.top: tr_view.top; color: "#000000"
    }

    Row {
        id: btns_row
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        height: 42*physicalPlatformScale

        Column {
            id: clear_column
            width: parent.width/2
            height: acceptMode? btns_row.height*3 : btns_row.height
            anchors.bottom: parent.bottom
            clip: true

            property bool acceptMode: false

            Timer {
                id: accept_timer
                interval: 2000
                repeat: false
                onTriggered: clear_column.acceptMode = false
            }

            Behavior on height {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 300 }
            }

            Button {
                id: clear_btn
                height: btns_row.height
                width: clear_column.width
                color: "#ff5532"
                highlightColor: "#E34B2C"
                textColor: "#ffffff"
                text: qsTr("Clear")
                onClicked: {
                    clear_column.acceptMode = !clear_column.acceptMode
                    if( clear_column.acceptMode ) {
                        accept_timer.restart()
                        return
                    }

                    kaqaz.removeFile(kaqaz.translatorFilePath())
                    tr_model.reload()
                    showTooltip( qsTr("Cleared") )
                }
            }

            Button {
                id: clear_cancel_btn
                height: btns_row.height
                width: clear_column.width
                color: "#4098bf"
                highlightColor: "#3B8DB1"
                textColor: "#ffffff"
                text: qsTr("Cancel")
                onClicked: {
                    clear_column.acceptMode = false
                }
            }

            Rectangle {
                height: btns_row.height
                width: clear_column.width
                color: "#333333"

                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 12*fontsScale
                    font.family: SApp.globalFontFamily
                    text: qsTr("Are you sure?")
                    color: "#ffffff"
                }
            }
        }

        Button {
            id: save_btn
            height: btns_row.height
            width: parent.width/2
            color: "#33ccad"
            highlightColor: "#50ab99"
            textColor: "#ffffff"
            text: qsTr("Save")
            onClicked: {
                tr_model.saveTo( kaqaz.translatorFilePath() )
                showSubMessage(translation_save_component)
            }
        }
    }

    Component {
        id: translation_save_component
        TranslationSaveDialog {
            anchors.fill: parent
            anchors.topMargin: View.statusBarHeight
            anchors.bottomMargin: View.navigationBarHeight
            countries: tr_model.countries()
            languages: tr_model.languages()
            onLetsGo: {
                tr_model.language = currentLanguage
                tr_model.country = currentCountry
                tr_model.saveTo( kaqaz.translatorFilePath() )

                var path = kaqaz.getTempPath() + ".ts"

                kaqaz.removeFile(path)
                kaqaz.copyFile(kaqaz.translatorFilePath(), path)

                showTooltip( qsTr("Saved Successfully on") + "\n" + kaqaz.translatorFilePath() )
                hideSubMessage()
            }
        }
    }
}
