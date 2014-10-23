import QtQuick 2.0
import SialanTools 1.0

Item {
    width: 100
    height: 62

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    ListView {
        id: preference_list
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true
        focus: true

        model: ListModel {}
        delegate: Item {
            id: item
            anchors.left: parent.left
            anchors.right: parent.right
            height: column.height + 20*physicalPlatformScale

            Column {
                id: column
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.margins: 10*physicalPlatformScale

                Item {
                    id: title_item
                    height: title_txt.height
                    width: column.width

                    Text {
                        id: title_txt
                        font.pixelSize: 14*fontsScale
                        font.family: SApp.globalFontFamily
                        anchors.left: parent.left
                        color: "#111111"
                        text: title
                    }

                    Text {
                        id: license_txt
                        font.pixelSize: 10*fontsScale
                        font.family: SApp.globalFontFamily
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        color: "#111111"
                        text: license
                    }
                }

                Text {
                    id: description_txt
                    font.pixelSize: 9*fontsScale
                    font.family: SApp.globalFontFamily
                    anchors.left: parent.left
                    anchors.right: parent.right
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    color: "#333333"
                    text: description
                }

                Text {
                    id: link_txt
                    font.pixelSize: 9*fontsScale
                    font.family: SApp.globalFontFamily
                    color: "#0000D9"
                    text: link

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Qt.openUrlExternally(link_txt.text)
                    }
                }
            }
        }

        Component.onCompleted: {
            model.clear()

            model.append({"title": "Droid fonts", "license": "Apache License v2", "link": "https://www.google.com/fonts/specimen/Droid+Sans", "description": "Droid Sans is a humanist sans serif typeface designed by Steve Matteson, Type Director of Ascender Corp."})
            model.append({"title": "Faenza icons", "license": "GNU GPL v3", "link": "https://code.google.com/p/faenza-icon-theme/", "description": "An icons set for Gnome."})
            model.append({"title": "KFaenza icons", "license": "GNU GPL v3", "link": "http://kde-look.org/content/show.php?content=143890", "description": "Faenza-Cupertino icon theme for KDE!"})
            model.append({"title": "Oxygen icons", "license": "GNU LGPL v3", "link": "https://techbase.kde.org/Projects/Oxygen", "description": "KDE4 default icons set."})
            model.append({"title": "QDropBox", "license": "GNU LGPL v3", "link": "https://github.com/lycis/QtDropbox/", "description": "QtDropbox is an API for the well known cloud storage service Dropbox."})
            model.append({"title": "QMapControl", "license": "GNU LGPL v2", "link": "http://sourceforge.net/projects/qmapcontrol/", "description": "QMapControl is a Qt widget which enables your applications to use map data from different sources on desktop or mobiles. Maps can be enriched by custom objects which will be drawn into the map."})
            model.append({"title": "Qt Framework " + Tools.qtVersion(), "license": "GNU GPL v3", "link": "http://qt.io", "description": "Qt is a cross-platform application and UI framework for developers using C++ or QML, a CSS & JavaScript like language."})
            model.append({"title": "QtSingleApplication", "license": "GNU GPL v3", "link": "https://github.com/lycis/QtDropbox/", "description": "The QtSingleApplication component provides support for applications that can be only started once per user."})
            model.append({"title": "Sialan Qt Tools", "license": "GNU GPL v3", "link": "https://github.com/sialan-labs/sialan-qt-tools", "description": "Some tools, creating for Sialan Qt projects and used on many of Sialan's projects"})
            model.append({"title": "SimpleQtCryptor", "license": "GNU GPL v3", "link": "http://zo0ok.com/techfindings/archives/595", "description": "Simple Qt encryption library and tools."})

            focus = true
        }
    }

    ScrollBar {
        scrollArea: preference_list; height: preference_list.height; width: 6*physicalPlatformScale
        anchors.right: preference_list.right; anchors.top: preference_list.top;color: "#000000"
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("Open Source Projects")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
