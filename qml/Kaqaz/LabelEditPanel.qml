import QtQuick 2.2

Item {
    id: labeledit_panel
    width: 100
    height: 62
    clip: true

    property variant item

    Item {
        id: btns_item
        x: 0
        y: 0
        width: parent.width
        height: parent.height
        clip: true

        Behavior on y {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }

        Button {
            id: share_button
            anchors.top: parent.top
            anchors.topMargin: 10*physicalPlatformScale
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 5*physicalPlatformScale/2
            width: parent.width/3 - 5*physicalPlatformScale
            normalColor: "#88ffffff"
            highlightColor: "#aa0d80ec"
            textColor: "#ffffff"
            onClicked: {
                if( kaqaz.isLinux() && !kaqaz.isAndroid() ) {
                    var path = kaqaz.getStaticTempPath()
                    kaqaz.shareToFile( database.paperTitle(labeledit_panel.item.paperItem.paperItem),
                                       database.paperText(labeledit_panel.item.paperItem.paperItem),
                                       path )

                    var msg = showSubMessage("ShareDialog.qml")
                    msg.sources = [path]

                } else {
                    kaqaz.share( database.paperTitle(labeledit_panel.item.paperItem.paperItem),
                                 database.paperText(labeledit_panel.item.paperItem.paperItem) )
                }

                main.closePanel()
            }
        }

        Button {
            id: paste_btn
            anchors.top: parent.top
            anchors.topMargin: 10*physicalPlatformScale
            anchors.bottom: parent.bottom
            anchors.left: share_button.right
            anchors.leftMargin: 5*physicalPlatformScale
            width: parent.width/3 - 5*physicalPlatformScale
            normalColor: "#88ffffff"
            highlightColor: "#aa0d80ec"
            textColor: "#ffffff"
            onClicked: {
                item.insertAtCurrent( kaqaz.clipboard() )
                main.closePanel()
            }
        }

        Button {
            id: delete_button
            anchors.top: parent.top
            anchors.topMargin: 10*physicalPlatformScale
            anchors.bottom: parent.bottom
            anchors.left: paste_btn.right
            anchors.leftMargin: 5*physicalPlatformScale
            width: parent.width/3 - 5*physicalPlatformScale
            normalColor: "#88ffffff"
            highlightColor: "#aa0d80ec"
            textColor: "#ffffff"
            onClicked: {
                var stt = true
                if( kaqaz.isTouchDevice() || stt ) {
                    btns_item.y = labeledit_panel.height
                } else {
                    main.closePanel()
                    var msg = showSubMessage("PaperDeleteDialog.qml")
                    msg.deleteRequest.connect( item.deleteRequest )
                }
            }
        }
    }

    Item{
        id: delete_sure
        x: 5*physicalPlatformScale
        anchors.bottom: btns_item.top
        anchors.bottomMargin: 1*physicalPlatformScale
        width: parent.width
        height: parent.height - 10*physicalPlatformScale
        clip: true

        Text {
            id: delete_warn
            font.pointSize: 17*fontsScale
            font.family: globalFontFamily
            anchors.left: parent.left
            anchors.right: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
        }

        Button {
            id: yes_button
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: no_button.left
            anchors.rightMargin: 10*physicalPlatformScale
            width: parent.width/4 - 5*physicalPlatformScale
            normalColor: "#aaC80000"
            onClicked: {
                item.deleteRequest()
                main.closePanel()
            }
        }

        Button {
            id: no_button
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 10*physicalPlatformScale
            width: parent.width/4 - 5*physicalPlatformScale
            normalColor: "#88ffffff"
            onClicked: {
                btns_item.y = 0
            }
        }
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        delete_button.text = qsTr("Delete")
        paste_btn.text = qsTr("Paste Text")
        share_button.text = qsTr("Share")
        delete_warn.text = qsTr("Are you sure?")
        yes_button.text  = qsTr("Delete")
        no_button.text   = qsTr("Cancel")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
