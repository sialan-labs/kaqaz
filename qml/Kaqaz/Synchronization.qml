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

    Column {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*physicalPlatformScale
        anchors.verticalCenter: parent.verticalCenter

        SynchronizationItem {
            image: "files/dropbox.png"
            text: sync.tokenAvailable? qsTr("Click to disconnect") : qsTr("Sync using Dropbox")
            onClicked: {
                if( sync.tokenAvailable )
                    sync.stop();
                else
                    showSubMessage("DropBoxAuthorize.qml")
            }
        }
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text   = qsTr("Synchronization")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
