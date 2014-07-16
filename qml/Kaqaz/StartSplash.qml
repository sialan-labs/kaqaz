import QtQuick 2.0

Item {
    id: start_splash
    anchors.fill: parent

    signal finished()

    ListView {
        id: splashes
        anchors.fill: parent
        anchors.topMargin: statusBarHeight
        anchors.bottomMargin: navigationBarHeight
        orientation: Qt.Horizontal
        snapMode: ListView.SnapOneItem
        rebound: Transition { NumberAnimation {duration: 0} }
        boundsBehavior: Flickable.StopAtBounds
        model: ListModel{}

        property bool squaresCreated: false

        delegate: Item {
            id: item
            width: splashes.width
            height: splashes.height

            property int index: idx
            property variant object

            Component.onCompleted: {
                var component = Qt.createComponent(cmpnt)
                object = component.createObject(item)
                object.anchors.fill = item
                initTranslations()
            }

            function initTranslations() {
                switch(idx-1)
                {
                case 1:
                    object.text = qsTr("It's easy to add notes to Kaqaz!")
                    break;
                case 2:
                    object.text = qsTr("Write your Note on a clean paper")
                    object.image = "files/splash/1.jpg"
                    break;
                case 3:
                    object.text = qsTr("Snap a label to your note")
                    object.image = "files/splash/2.jpg"
                    break;
                case 4:
                    object.text = qsTr("Done. Now add next... :)")
                    object.image = "files/splash/4.jpg"
                    break;
                case 5:
                    object.text = qsTr("And some tricks!")
                    break;
                case 6:
                    object.text = qsTr("Manage and View your notes here")
                    object.image = "files/splash/5.jpg"
                    break;
                case 7:
                    object.text = qsTr("Sync your notes between devices")
                    object.image = "files/splash/8.jpg"
                    break;
                case 8:
                    object.finished.connect(start_splash.finish)
                    break;
                }
            }

            Connections{
                target: kaqaz
                onLanguageChanged: item.initTranslations()
            }
        }

        function refresh() {
            model.clear()

            var items = ["SialanSplash.qml","SplashLanguage.qml","SplashTextPage.qml","SplashMessagePage.qml","SplashMessagePage.qml","SplashMessagePage.qml"
                    ,"SplashTextPage.qml","SplashMessagePage.qml","SplashMessagePage.qml","SplashDone.qml"]

            for( var i=0; i<items.length; i++ ) {
                model.append({"cmpnt":items[i],"idx":i})

                if( !squaresCreated ) {
                    var square = square_component.createObject(squares_row)
                    square.index = i
                    if( i == 0 )
                        square.highlight = true
                }
            }

            squaresCreated = true
        }

        Component.onCompleted: refresh()
    }

    ScrollBar {
        scrollArea: splashes; width: splashes.width; height: 8
        anchors.bottom: parent.bottom; anchors.bottomMargin: 1*physicalPlatformScale;
        color: "#ffffff"; orientation: Qt.Horizontal
    }

    Row {
        id: squares_row
        anchors.top: parent.top
        anchors.topMargin: 8*physicalPlatformScale + statusBarHeight
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Component {
        id: square_component
        Item {
            id: square
            width: height
            height: 14*physicalPlatformScale

            property bool highlight: false
            property int index: 0

            Connections {
                target: splashes
                onContentXChanged: {
                    var obj = splashes.itemAt(splashes.contentX+splashes.width/2,splashes.height/2)
                    square.highlight = (square.index == obj.index)
                }
            }

            Rectangle {
                id: square_rect
                anchors.centerIn: parent
                width: parent.width - 4*physicalPlatformScale - pad
                height: parent.height - 4*physicalPlatformScale - pad
                color: "#ffffff"

                property real pad: square.highlight? 0 : 4*physicalPlatformScale
            }
        }
    }

    function finish() {
        start_splash.finished()
        start_splash.destroy()
    }
}
