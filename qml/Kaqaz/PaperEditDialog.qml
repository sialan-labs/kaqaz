import QtQuick 2.0

Item {
    id: edit_dialog
    anchors.fill: parent
    anchors.topMargin: statusBarHeight
    anchors.bottomMargin: navigationBarHeight

    property variant item
    property variant paperItem: item? item.paperItem : 0

    property variant coo: edit_dialog.item? database.paperLocation(edit_dialog.item.paperItem.paperItem) : 0
    property real longitude: coo? coo.longitude : 0
    property real latitude: coo? coo.latitude : 0

    Connections {
        target: database
        onPaperChanged: {
            if( !item )
                return
            if( id != item.paperItem.paperItem )
                return

            var tmp = item
            item = 0
            item = tmp
        }
    }

    MouseArea {
        anchors.fill: parent
    }

    Header {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    Text {
        id: title
        x: 40*physicalPlatformScale
        y: 60*physicalPlatformScale
        width: parent.width-2*x
        text: paperItem && paperItem.text.length!=0? paperItem.text: qsTr("Untitled Paper")
        font.pixelSize: 25*fontsScale
        font.weight: Font.Light
        font.family: globalFontFamily
        color: "#333333"
        elide: Text.ElideRight
        wrapMode: Text.WrapAnywhere
        maximumLineCount: 1
    }

    Text {
        id: body
        x: 50*physicalPlatformScale
        width: parent.width-2*x
        anchors.top: title.bottom
        text: paperItem? paperItem.bodyText : ""
        font.pixelSize: 10*fontsScale
        font.weight: Font.Light
        font.family: globalFontFamily
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        maximumLineCount: 2
        elide: Text.ElideRight
        color: "#666666"
    }

    Flickable {
        id: edit_flick
        anchors.left: title.left
        anchors.right: title.right
        anchors.top: body.bottom
        anchors.topMargin: 20*physicalPlatformScale
        anchors.bottom: parent.bottom
        contentHeight: column.height
        contentWidth: width
        bottomMargin: 20*physicalPlatformScale
        clip: true

        Column {
            id: column
            width: edit_flick.width

            MenuButton {
                height: 50*physicalPlatformScale
                width: column.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: 13*fontsScale
                textFont.bold: false
                text: qsTr("Share Paper")
                onClicked: {
                    if( devices.isLinux && !devices.isAndroid ) {
                        hideSubMessage()
                        var path = kaqaz.getStaticTempPath()
                        kaqaz.shareToFile( database.paperTitle(edit_dialog.item.paperItem.paperItem),
                                           database.paperText(edit_dialog.item.paperItem.paperItem),
                                           path )

                        var msg = showSubMessage("ShareDialog.qml")
                        msg.sources = [path]

                    } else {
                        devices.share( database.paperTitle(edit_dialog.item.paperItem.paperItem),
                                     database.paperText(edit_dialog.item.paperItem.paperItem) )
                    }
                }
            }

            MenuButton {
                height: 50*physicalPlatformScale
                width: column.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: 13*fontsScale
                textFont.bold: false
                text: qsTr("Force sync")
                onClicked: {
                    if( sync.tokenAvailable ) {
                        sync.refreshForce()
                        syncProgressBar.visible = true
                    }
                    hideSubMessage()
                }
            }

            Item {
                id: update_frame
                height: editMode? date_chooser.height+update_btn.height : update_btn.height
                width: column.width
                clip: true

                property bool editMode: false

                Behavior on height {
                    NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
                }

                DateTimeChooser {
                    id: date_chooser
                    width: parent.width
                    height: 150*physicalPlatformScale
                    color: "#F4F4F4"
                    textsColor: "#111111"
                    anchors.bottom: update_btn.top
                }

                MenuButton {
                    id: update_btn
                    height: 50*physicalPlatformScale
                    width: parent.width
                    anchors.bottom: parent.bottom
                    normalColor: update_frame.editMode? "#4098bf" : "#00000000"
                    highlightColor: "#4098bf"
                    textColor: press || update_frame.editMode? "#ffffff" : "#4098bf"
                    textFont.weight: Font.Normal
                    textFont.pixelSize: 13*fontsScale
                    textFont.bold: false
                    text: update_frame.editMode? qsTr("Confirm") : qsTr("Update Date")
                    onClicked: {
                        if( update_frame.editMode ) {
                            var date = date_chooser.getDate()
                            database.setPaperCreatedDate(item.paperItem.paperItem,date)
                            item.paperItem.refreshDateLabel()
                            main.refreshMenu()
                        }

                        update_frame.editMode = !update_frame.editMode
                    }
                }
            }

            MenuButton {
                height: 50*physicalPlatformScale
                width: column.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: 13*fontsScale
                textFont.bold: false
                text: qsTr("Update Location")
                visible: !map_image.visible
                onClicked: {
                    database.setPaperLocation(item.paperItem.paperItem,positioning.position.coordinate)
                }
            }

            MapView {
                id: map_image
                width: column.width
                height: width/2
                latitude: edit_dialog.latitude
                longitude: edit_dialog.longitude
                visible: !unknown
                paperId: edit_dialog.item? edit_dialog.item.paperItem.paperItem : 0
            }

            Item {
                id: delete_frame
                height: 50*physicalPlatformScale + (confirm?delete_confirm_text.height:0)
                width: column.width
                clip: true

                property bool confirm: false

                Behavior on height {
                    NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
                }

                Timer {
                    id: confirm_timer
                    interval: 2000
                    onTriggered: delete_frame.confirm = false
                }

                Timer {
                    id: block_timer
                    interval: 400
                }

                Text {
                    id: delete_confirm_text
                    width: column.width
                    font.weight: Font.Normal
                    font.pixelSize: 15*fontsScale
                    font.bold: false
                    anchors.bottom: delete_btn.top
                    color: "#ff5532"
                    text: qsTr("Are you sure?")
                }

                MenuButton {
                    id: delete_btn
                    height: 50*physicalPlatformScale
                    width: column.width
                    anchors.bottom: parent.bottom
                    normalColor: "#00000000"
                    highlightColor: "#ff5532"
                    textColor: press? "#ffffff" : "#ff5532"
                    textFont.weight: Font.Normal
                    textFont.pixelSize: 13*fontsScale
                    textFont.bold: false
                    text: qsTr("Delete Paper")
                    onClicked: {
                        if( block_timer.running )
                            return
                        if( delete_frame.confirm ) {
                            item.deleteRequest()
                            hideSubMessage()
                        }

                        delete_frame.confirm = !delete_frame.confirm
                        confirm_timer.restart()
                        block_timer.restart()
                    }
                }
            }
        }
    }

    ScrollBar {
        scrollArea: edit_flick; height: edit_flick.height; width: 6*physicalPlatformScale
        anchors.right: parent.right; anchors.top: edit_flick.top; color: "#000000"
        anchors.rightMargin: 4*physicalPlatformScale
    }
}
