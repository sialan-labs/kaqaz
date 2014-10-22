/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Kaqaz 1.0
import SialanTools 1.0

Item {
    id: edit_dialog
    anchors.fill: parent
    anchors.topMargin: View.statusBarHeight
    anchors.bottomMargin: View.navigationBarHeight

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
        font.pixelSize: Devices.isMobile? 22*fontsScale : 25*fontsScale
        font.weight: Font.Light
        font.family: SApp.globalFontFamily
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
        font.pixelSize: Devices.isMobile? 9*fontsScale : 10*fontsScale
        font.weight: Font.Light
        font.family: SApp.globalFontFamily
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
                textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
                textFont.bold: false
                text: qsTr("Share Paper")
                onClicked: {
                    if( Devices.isLinux && !Devices.isAndroid ) {
                        hideSubMessage()
                        var path = kaqaz.getStaticTempPath()
                        kaqaz.shareToFile( database.paperTitle(edit_dialog.item.paperItem.paperItem),
                                           database.paperText(edit_dialog.item.paperItem.paperItem),
                                           path )

                        var msg = showSubMessage(Qt.createComponent("ShareDialog.qml"))
                        msg.sources = [path]

                    } else {
                        Devices.share( database.paperTitle(edit_dialog.item.paperItem.paperItem),
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
                textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
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

            MenuButton {
                height: 50*physicalPlatformScale
                width: column.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
                textFont.bold: false
                text: qsTr("Paper Type")
//                visible: false
                onClicked: {
                    if( !paperTypeObj )
                        paperTypeObj = showBottomPanel(paper_type_component,true)
                }

                property variant paperTypeObj
            }

            MenuButton {
                id: update_btn
                height: 50*physicalPlatformScale
                width: parent.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
                textFont.bold: false
                text: qsTr("Update Date")
                onClicked: {
                    if( !dateChooser )
                        dateChooser = showBottomPanel(date_component,true)
                }

                property variant dateChooser
            }

            MenuButton {
                height: 50*physicalPlatformScale
                width: column.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
                textFont.bold: false
                text: qsTr("Update Location")
                onClicked: {
                    showBottomPanel(geo_component,true)
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
                    font.pixelSize: Devices.isMobile? 13*fontsScale : 15*fontsScale
                    font.family: SApp.globalFontFamily
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
                    textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
                    textFont.bold: false
                    text: qsTr("Delete Paper")
                    onClicked: {
                        if( block_timer.running )
                            return
                        if( delete_frame.confirm ) {
                            item.paperItem.deleteRequest()
                            hideSubMessage()
                        }

                        delete_frame.confirm = !delete_frame.confirm
                        confirm_timer.restart()
                        block_timer.restart()
                    }
                }
            }

            Item {
                width: 10
                height: 100*physicalPlatformScale
            }
        }
    }

    ScrollBar {
        scrollArea: edit_flick; height: edit_flick.height; width: 6*physicalPlatformScale
        anchors.right: parent.right; anchors.top: edit_flick.top; color: "#000000"
        anchors.rightMargin: 4*physicalPlatformScale
    }

    MouseArea {
        id: back_marea
        anchors.fill: parent
        visible: bottomPanel.item? true : false
        onClicked: hideBottomPanel()
    }

    Component {
        id: paper_type_component
        Column {
            id: paper_types
            height: 100*physicalPlatformScale

            MenuButton {
                height: 50*physicalPlatformScale
                width: paper_types.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
                textFont.bold: false
                text: qsTr("Normal")
                onClicked: {
                    database.setPaperType(item.paperItem.paperItem,Enums.Normal)
                    hideBottomPanel()
                }
            }

            MenuButton {
                height: 50*physicalPlatformScale
                width: paper_types.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
                textFont.bold: false
                text: qsTr("To-Do")
                onClicked: {
                    item.paperItem.save()
                    database.setPaperType(item.paperItem.paperItem,Enums.ToDo)
                    hideBottomPanel()
                }
            }
        }
    }

    Component {
        id: date_component
        Item {
            id: date_dialog
            height: 230*physicalPlatformScale

            MouseArea {
                anchors.fill: parent
            }

            Button {
                id: done_btn
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10*physicalPlatformScale
                height: 30*physicalPlatformScale
                width: 100*physicalPlatformScale
                color: "#4098bf"
                highlightColor: "#3B8DB1"
                textColor: "#ffffff"
                text: qsTr("Done")
                onClicked: {
                    var date = dateChooser.getDate()
                    database.setPaperCreatedDate(edit_dialog.item.paperItem.paperItem,date)
                    item.paperItem.refreshDateLabel()
                    main.refreshMenu()
                    hideBottomPanel()
                }
            }

            DateTimeChooser {
                id: dateChooser
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: done_btn.bottom
                anchors.margins: 20*physicalPlatformScale
                anchors.topMargin: 10*physicalPlatformScale
                dateVisible: true
                timeVisible: true
                color: "#D9D9D9"
                textsColor: "#111111"
            }
        }
    }

    Component {
        id: geo_component
        Item {
            id: geo_dialog
            height: 230*physicalPlatformScale

            MouseArea {
                anchors.fill: parent
            }

            Button {
                id: done_btn
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 10*physicalPlatformScale
                height: 30*physicalPlatformScale
                width: 100*physicalPlatformScale
                color: "#4098bf"
                highlightColor: "#3B8DB1"
                textColor: "#ffffff"
                text: qsTr("Done")
                onClicked: {
                    var geo = map_switcher.view
                    database.setPaperLocation(item.paperItem.paperItem,geo)
                    main.refreshMenu()
                    hideBottomPanel()
                }
            }

            MapSwitcher {
                id: map_switcher
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: done_btn.bottom
                anchors.topMargin: 10*physicalPlatformScale
                Component.onCompleted: crosshairs = true
            }
        }
    }
}
