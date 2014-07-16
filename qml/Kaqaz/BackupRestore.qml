import QtQuick 2.2

Item {
    id: backup_restore
    width: 100
    height: 62

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    ListView {
        id: backup_restore_list
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true
        maximumFlickVelocity: flickVelocity

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: backup_restore_list.width
            height: 60*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string text: name
            property string command: cmd
            property bool press: false

            Connections{
                target: backup_restore_list
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
                    if( item.command == "backup" ) {
                        if( database.password().length !== 0 ) {
                            var passItem = getPass(backup_restore)
                            passItem.success.connect(backup_restore.backup)
                            passItem.allowBack = true
                        }
                        else
                            backup_restore.backup()
                    }
                    if( item.command == "restore" ) {
                        var component = Qt.createComponent("RestoreDialog.qml");
                        var a = component.createObject(main);
                        main.pushPreference(a)
                    }
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

            model.append({"name": qsTr("Make Backup"), "cmd": "backup"})
            model.append({"name": qsTr("Restore"), "cmd": "restore"})

            focus = true
        }
    }

    function backup(){
        var component = Qt.createComponent("BackupWait.qml");
        var item = component.createObject(main);
        main.pushPreference(item)
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("Backup and Restore")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
