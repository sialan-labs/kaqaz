import QtQuick 2.0

Item {
    id: share_dialog
    anchors.fill: parent

    property bool started: false
    property variant sources

    onSourcesChanged: apps_list.refresh()

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.LeftButton
        hoverEnabled: true
        onWheel: wheel.accepted = true
        onClicked: hideSubMessage()
    }

    Header {
        id: header
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        z: 10
    }

    Text {
        id: title
        x: 40*physicalPlatformScale
        y: 60*physicalPlatformScale
        text: qsTr("Select Application")
        font.pointSize: 25*fontsScale
        font.weight: Font.Light
        font.family: globalFontFamily
        color: "#333333"
    }

    ListView {
        id: apps_list
        anchors.left: title.left
        anchors.right: parent.right
        anchors.top: title.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20*physicalPlatformScale
        anchors.topMargin: 10*physicalPlatformScale
        model: ListModel{}
        clip: true
        delegate: Rectangle {
            id: item
            height: 48*physicalPlatformScale
            width: apps_list.width
            color: marea.pressed? "#880d80ec" : "#00000000"

            Image {
                id: img
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 4*physicalPlatformScale
                height: 36*physicalPlatformScale
                width: height
                sourceSize: Qt.size(width,height)
                source: "image://icon/" + mimeApps.appIcon(appId)
            }

            Text {
                id: txt
                anchors.left: img.right
                anchors.leftMargin: 10*physicalPlatformScale
                anchors.verticalCenter: parent.verticalCenter
                font.family: globalFontFamily
                font.pointSize: 9*fontsScale
                text: mimeApps.appName(appId)
            }

            MouseArea {
                id: marea
                anchors.fill: parent
                onClicked: {
                    mimeApps.openFiles(appId,share_dialog.sources)
                    hideSubMessage()
                }
            }
        }

        function refresh() {
            model.clear()
            if( !share_dialog.sources || share_dialog.sources.length == 0 )
                return

            var apps = mimeApps.appsOfFile(share_dialog.sources[0])
            for( var i=0; i<apps.length; i++ )
                model.append({"appId":apps[i]})
        }

        Component.onCompleted: refresh()
    }

    ScrollBar {
        scrollArea: apps_list; height: apps_list.height; width: 8
        anchors.right: apps_list.right; anchors.top: apps_list.top; color: "#333333"
    }

    function hide() {
        started = false
    }

    Component.onCompleted: started = true
}
