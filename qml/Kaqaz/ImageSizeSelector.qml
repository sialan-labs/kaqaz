import QtQuick 2.2

Item {
    id: size_selector
    width: 100
    height: 62

    property string path

    signal selected( string repID )

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        light: true
    }

    ListView {
        id: options_list
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20*physicalPlatformScale
        anchors.topMargin: 10*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: options_list.width
            height: 60*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string text: optionText
            property int imageWidth: optionWidth
            property bool press: false

            Connections{
                target: options_list
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
                font.pointSize: 12*fontsScale
                font.family: globalFontFamily
                color: "#ffffff"
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    var id = repository.copyImageToRepository( size_selector.path, imageWidth )
                    size_selector.selected(id)

                    backHandler = 0
                    main.popPreference()
                    main.popPreference()
                    main.popPreference()
                    darkBackground = false
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

            model.append({"optionText": qsTr("Small"), "optionWidth": 800 })
            model.append({"optionText": qsTr("Normal"), "optionWidth": 1280 })
            model.append({"optionText": qsTr("High"), "optionWidth": 1920 })
            model.append({"optionText": qsTr("Ultra"), "optionWidth": 3000 })

            focus = true
        }
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("Select best size")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
