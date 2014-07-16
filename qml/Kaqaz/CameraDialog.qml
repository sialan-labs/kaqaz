import QtQuick 2.2

Item {
    id: camera_dialog
    width: 100
    height: 62

    signal selected( string repID )

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        light: true
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
        maximumFlickVelocity: flickVelocity

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: preference_list.width
            height: 100*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string text: name
            property string path: adrs
            property bool press: false

            onPressChanged: hideRollerDialog()

            Connections{
                target: preference_list
                onMovementStarted: press = false
                onFlickStarted: press = false
            }

            Image{
                id: img
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 10*physicalPlatformScale
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                width: height*4/3
                sourceSize.width: width
                sourceSize.height: height
                source: "file://" + item.path
            }

            Text{
                id: txt
                anchors.left: img.right
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text
                font.pointSize: 12*fontsScale
                font.family: globalFontFamily
                color: "#ffffff"
                clip: true
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    var component = Qt.createComponent("ImageSizeSelector.qml");
                    var i = component.createObject(main);
                    i.path = item.path
                    i.selected.connect(camera_dialog.selected)
                    main.pushPreference(i)
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

        Component.onCompleted: refresh()

        function refresh(){
            model.clear()

            var files = kaqaz.findEntryFiles(kaqaz.cameraLocation(),["*.jpg","*.JPEG","*.jpeg","*.JPG"])
            for( var i=0; i<20 && i<files.length ; i++ )
                model.append({"name": kaqaz.fileName(files[i]), "adrs": files[i]})

            focus = true
        }
    }

    ScrollBar {
        scrollArea: preference_list; height: preference_list.height; width: 8
        anchors.right: preference_list.right; anchors.top: preference_list.top;color: "#ffffff"
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("Last Photos")
    }

    Component.onCompleted: {
        initTranslations()
        if( kaqaz.startCameraPicture() )
            return
        else
        if( !kaqaz.isTouchDevice() ) {
            var component = Qt.createComponent("CameraItem.qml");
            var item = component.createObject(camera_dialog);
        }
    }

    Connections{
        target: filesystem
        onDirectoryChanged: preference_list.refresh()
    }
}
