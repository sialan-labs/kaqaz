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

import QtQuick 2.2
import SialanTools 1.0

Item {
    id: attach_menu
    width: 100
    height: opened? (kaqaz_root.width>minimumHeight? minimumHeight : kaqaz_root.width) : toggle_btn.height + 10 +20*physicalPlatformScale

    property real minimumHeight: kaqaz_root.height - 50*physicalPlatformScale - View.navigationBarHeight - View.statusBarHeight

    property bool opened: false
    property int paperItem
    property string paperUuid: database.paperUuid(paperItem)
    property variant paper
    property variant attachments
    property bool paperIsEmpty: true

    onPaperItemChanged: {
        if( paperItem == -1 )
        {
            attachments = 0
            attach_img.dynamicSource = "files/attachment.png"
            return
        }

        attachments = database.paperFiles(paperItem)
    }

    onAttachmentsChanged: {
        if( !attachments )
            return

        attach_img.dynamicSource = (attachments.length === 0)? "files/attachment.png" : "files/attachment_blue.png"
    }

    onOpenedChanged: {
        if( opened )
            BackHandler.pushHandler(attach_menu,attach_menu.hide)
        else
            BackHandler.removeHandler(attach_menu)

        sidePanel = !opened
        if( opened )
            load_timer.restart()
        else {
            load_timer.stop()
            if( gallery_frame.item )
                gallery_frame.item.destroy()
        }
    }

    Behavior on height {
        NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
    }

    Rectangle {
        id: back_img
        anchors.fill: parent
        anchors.bottomMargin: -6*physicalPlatformScale - View.navigationBarHeight
        color: "#000000"
        opacity: attach_menu.opened? 0.9 : 0

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }
    }

    Timer{
        id: load_timer
        repeat: false
        interval: 500
        onTriggered: {
            var component = Qt.createComponent("AttachViewer.qml")
            var item = component.createObject(gallery_frame);
            item.paperItem = attach_menu.paperItem
            item.paper = attach_menu.paper
            item.editRequest.connect(attach_menu.showCanvas)

            gallery_frame.item = item
        }
    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        visible: attach_menu.opened
    }

    MouseArea {
        id: hide_area
        hoverEnabled: true
        anchors.bottom: attach_menu.top
        width: kaqaz_root.width
        height: kaqaz_root.height - attach_menu.height
        onClicked: attach_menu.opened = false
        visible: attach_menu.opened
    }

    Rectangle {
        id: shadow
        width: parent.width
        height: 5*physicalPlatformScale
        anchors.bottom: attach_menu.top
        opacity: attach_menu.opened? 1 : 0
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#66000000" }
        }

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }
    }

    Button{
        id: attach_btn
        anchors.verticalCenter: toggle_btn.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10*physicalPlatformScale
        width: 30*physicalPlatformScale
        normalColor: "#00000000"
        radius: 2*physicalPlatformScale
        visible: attach_menu.opened
        opacity: attach_menu.opened? 1 : 0
        icon: "files/add.png"
        border.width: 1*physicalPlatformScale
        border.color: "#ffffff"
        onClicked: {
            if( !Devices.isTouchDevice ){
                var list = kaqaz.getOpenFileNames( qsTr("Select media files."), "Images (*.png *.jpg);;Musics (*.mp3 *.ogg);;Documents (*.pdf *.txt *.text)" )
                for( var i=0; i<list.length; i++ ){
                    var id = repository.insert( list[i] )
                    attach_menu.selected(id)
                }
            } else {
                var component = Qt.createComponent("AttachInsertDialog.qml")
                var item = component.createObject(main);
                item.selected.connect(attach_menu.selected)
                main.pushPreference(item)
            }
        }

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }
    }

    Button{
        id: canvas_btn
        anchors.verticalCenter: toggle_btn.verticalCenter
        anchors.right: attach_btn.left
        anchors.rightMargin: 10*physicalPlatformScale
        width: 30*physicalPlatformScale
        normalColor: "#00000000"
        radius: 2*physicalPlatformScale
        visible: attach_menu.opened && kaqaz.proBuild
        opacity: canvas_btn.opacity
        icon: "files/pen.png"
        iconHeight: 16*physicalPlatformScale
        border.width: 1*physicalPlatformScale
        border.color: "#ffffff"
        onClicked: {
            var component = Qt.createComponent("KaqazCanvas.qml")
            var item = component.createObject(main);
            item.done.connect(attach_menu.canvasDone)
            main.showDialog(item)
        }
    }

    Rectangle {
        id: toggle_btn
        y: 5*physicalPlatformScale
        anchors.horizontalCenter: attach_menu.horizontalCenter
        width: 40*physicalPlatformScale
        height: width
        radius: width/2
        color: press? "#3B97EC" : normalColor
        smooth: true
        border.width: 1*physicalPlatformScale
        border.color: attach_menu.opened || !sync.tokenAvailable || attach_menu.paperIsEmpty? "#ffffff" : (synced!=-1? "#50ab99" : "#C51313")

        property int synced: database.revisionOf(paperUuid)

        property bool press: false
        property color normalColor: attach_menu.opened? "#00000000" : "#cccccc"

        Behavior on normalColor {
            ColorAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }
        Behavior on border.color {
            ColorAnimation { easing.type: Easing.Linear; duration: 400 }
        }

        Connections {
            target: database
            onRevisionChanged: if( iid == attach_menu.paperUuid )toggle_btn.synced = database.revisionOf( database.paperUuid(attach_menu.paperItem) )
        }

        Image {
            id: attach_img
            anchors.fill: parent
            anchors.margins: 10*physicalPlatformScale
            source: toggle_btn.press || attach_menu.opened? "files/attachment.png" : dynamicSource
            smooth: true

            property string dynamicSource: "files/attachment.png"
        }

        MouseArea {
            anchors.fill: parent
            onPressed: toggle_btn.press = true
            onReleased: toggle_btn.press = false
            onClicked: attach_menu.opened = !attach_menu.opened
        }
    }

    Item {
        id: gallery_frame
        x: 0
        y: toggle_btn.y + toggle_btn.height
        width: parent.width
        height: parent.height - (toggle_btn.y + toggle_btn.height)
        transformOrigin: Item.TopLeft

        property variant item

        property real root_x: 0
        property real root_y: 0
    }

    function selected( id ){
        if( paperItem == -1 )
            paper.save()

        var attachments = database.paperFiles(paperItem)
        var attach_res = new Array

        for( var i=0; i<attachments.length; i++ )
            attach_res[attach_res.length] = attachments[i]

        attach_res[attach_res.length] = id
        attach_menu.attachments = attach_res

        database.addFileToPaper(paperItem,id)

        if( gallery_frame.item ){
            gallery_frame.item.paperItem = -1
            gallery_frame.item.paperItem = paperItem
        }
    }

    function showCanvas( fid ) {
        var component = Qt.createComponent("KaqazCanvas.qml")
        var item = component.createObject(main)
        item.done.connect(attach_menu.canvasDone)
        item.fileId = fid

        main.showDialog(item)
    }

    function canvasDone( fileName, fileId ) {
        if( fileId.length == 0 ) {
            var id = repository.insert( fileName )
            attach_menu.selected(id)
        } else {
            var newFileId = repository.insert( fileName )
            var filePath  = repository.getPath(fileId)

            var date = database.fileTime(paperItem,fileId)
            database.removeFileFromPaper(paperItem,fileId)
            database.addCustomFileToPaper(paperItem,newFileId,date)

            if( gallery_frame.item ){
                gallery_frame.item.paperItem = -1
                gallery_frame.item.paperItem = paperItem
            }
        }
    }

    function hide(){
        if( !opened )
            return false

        opened = false
        return true
    }
}
