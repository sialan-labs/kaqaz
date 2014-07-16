import QtQuick 2.2

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

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: preference_list.width
            height: 60*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string command: cmd
            property string text: name
            property bool press: false

            Connections{
                target: preference_list
                onMovementStarted: press = false
                onFlickStarted: press = false
            }

            Text{
                id: txt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text
                font.pointSize: 15*fontsScale
                font.family: globalFontFamily
                color: item.press? "#ffffff" : "#333333"
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    var component = Qt.createComponent(command);
                    var item = component.createObject(main);
                    main.pushPreference(item)
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

        Connections{
            target: kaqaz
            onLanguageChanged: preference_list.refresh()
        }

        function refresh(){
            model.clear()
            model.append({"name": qsTr("Languages"), "cmd": "LanguageSelector.qml"})
            model.append({"name": qsTr("Calendars"), "cmd": "Calendar.qml" })
            model.append({"name": qsTr("Label Manager"), "cmd": "GroupManager.qml" })
            model.append({"name": qsTr("Backup & Restore"), "cmd": "BackupRestore.qml" })
//            if( kaqaz.isTouchDevice() )
//                model.append({"name": qsTr("Data Location"), "cmd": "ProfileSettings.qml" })
            model.append({"name": qsTr("Synchronization"), "cmd": "Synchronization.qml" })
            model.append({"name": qsTr("Security"), "cmd": "Security.qml" })
            model.append({"name": qsTr("States"), "cmd": "StateDialog.qml" })
            model.append({"name": qsTr("About Kaqaz"), "cmd": "About.qml" })
            model.append({"name": qsTr("About Sialan"), "cmd": "AboutSialan.qml" })
            focus = true

            title.text = qsTr("Preferences")
        }

        Component.onCompleted: refresh()
    }

    ScrollBar {
        scrollArea: preference_list; height: preference_list.height; width: 8
        anchors.right: preference_list.right; anchors.top: preference_list.top; color: "#000000"
    }
}
