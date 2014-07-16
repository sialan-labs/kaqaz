import QtQuick 2.2

Item {
    id: profile_settings
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
            width: data_list.width
            height: 60*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string text: name
            property string path: pathValue
            property bool press: false

            Connections{
                target: data_list
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
                    if( database.password().length !== 0 ) {
                        var passItem = getPass(backup_restore)
                        passItem.success.connect(move)
                        passItem.allowBack = true
                    }
                    else
                        move()
                }

                function move(){
                    var component = Qt.createComponent("DataMoveWait.qml");
                    var it = component.createObject(main);
                    it.path = item.path
                    main.pushPreference(it)
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

            model.append({"name": qsTr("Keep on Device memory"), "pathValue": ""})
            model.append({"name": qsTr("Keep on SD Card"), "pathValue": kaqaz.sdcardPath()})

            focus = true
        }
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("Data Location")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
