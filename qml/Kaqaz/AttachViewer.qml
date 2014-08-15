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

Item {
    id: attach_viewer
    anchors.fill: parent
    opacity: 0
    clip: true

    property int paperItem: -1
    property variant paper

    onPaperItemChanged: {
        attach_list.refresh()
    }

    function deleteRequest( it ){
        msg_item.fileID = it.fileId
        showRollerDialog( it.mapToItem(kaqaz_root,0,0).y + it.height/2 - it.paintedHeight/2,
                         it.mapToItem(kaqaz_root,0,0).y + it.height/2 + it.paintedHeight/2, msg_item )
        it.controlFrame = false
    }

    Behavior on opacity {
        NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
    }

    Item {
        id: msg_item
        height: 54*physicalPlatformScale
        visible: false

        property string fileID

        Text {
            id: delete_warn
            font.pixelSize: 17*fontsScale
            font.family: globalFontFamily
            anchors.margins: 10*physicalPlatformScale
            anchors.left: parent.left
            anchors.right: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#ffffff"
        }

        Button {
            id: yes_button
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: no_button.left
            anchors.rightMargin: 5*physicalPlatformScale
            anchors.margins: 10*physicalPlatformScale
            width: parent.width/4 - 5*physicalPlatformScale
            normalColor: "#aaC80000"
            onClicked: {
                database.removeFileFromPaper(paperItem,msg_item.fileID)
                kaqaz.deleteFileIfPossible(msg_item.fileID)
                hideRollerDialog()
                attach_list.refresh()
            }
        }

        Button {
            id: no_button
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 5*physicalPlatformScale
            anchors.margins: 10*physicalPlatformScale
            width: parent.width/4 - 5*physicalPlatformScale
            normalColor: "#66ffffff"
            onClicked: {
                hideRollerDialog()
            }
        }
    }

    ListView {
        id: attach_list
        anchors.fill: parent
        anchors.topMargin: 10*physicalPlatformScale
        anchors.bottomMargin: 10*physicalPlatformScale
        highlightMoveDuration: 250
        orientation: ListView.Horizontal
        spacing: 10*physicalPlatformScale
        maximumFlickVelocity: flickVelocity
        leftMargin: spacing
        rightMargin: spacing
        cacheBuffer: width

        onMovementStarted: attach_list.edited = ""
        onFlickStarted: attach_list.edited = ""

        property string edited

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: attach_list.width<4*parent.height/3? attach_list.width : imgWidth
            height: parent.height
            color: "#00000000"

            property string fileId: fid
            property string path: filePath

            property variant viewer
            property alias controlFrame: control_frame

            property real imgHeight: 0
            property real imgWidth: attach_list.width
            property real imgY: 0
            property real imgX: 0

            function itemWidthChanged(){
                imgWidth = viewer.width
            }
            function itemHeightChanged(){
                imgHeight = viewer.height
            }
            function itemXChanged(){
                imgX = viewer.x
            }
            function itemYChanged(){
                imgY = viewer.y
            }

            MouseArea{
                anchors.fill: parent
                onClicked: attach_list.edited = item.fileId
                onPressed: hideRollerDialog()
            }

            Item {
                id: control_frame
                y: item.imgY + item.imgHeight - height - 2*physicalPlatformScale
                height: 30*physicalPlatformScale
                width: height*2 + 10*physicalPlatformScale
                anchors.horizontalCenter: item.horizontalCenter
                visible: attach_list.edited == item.fileId
                z: 100

                Button {
                    id: open_btn
                    icon: "files/open.png"
                    width: height
                    anchors.top: control_frame.top
                    anchors.bottom: control_frame.bottom
                    anchors.right: control_frame.right
                    radius: 2*physicalPlatformScale
                    normalColor: "#333333"
                    highlightColor: "#222222"
                    onClicked: {
                        var p = kaqaz.cacheFile(item.path)
                        devices.openFile( "file://" + p )
                        control_frame.visible = false
                    }
                }

                Button {
                    id: delete_btn
                    icon: "files/delete.png"
                    width: height
                    anchors.top: control_frame.top
                    anchors.bottom: control_frame.bottom
                    anchors.left: control_frame.left
                    radius: 2*physicalPlatformScale
                    normalColor: "#333333"
                    highlightColor: "#222222"
                    onClicked: {
                        msg_item.fileID = item.fileId
                        showRollerDialog( item.mapToItem(kaqaz_root,0,item.imgY).y,
                                          item.mapToItem(kaqaz_root,0,item.imgY).y + item.imgHeight, msg_item )
                        control_frame.visible = false
                    }
                }
            }

            Component.onCompleted: {
                var suffix = kaqaz.fileSuffix(item.path)
                var component;
                if( suffix === "jpg" || suffix === "jpeg" || suffix === "png" )
                    component = Qt.createComponent("ImageViewer.qml");
                else
                if( suffix === "mp3" || suffix === "wav" || suffix === "ogg" )
                    component = Qt.createComponent("MusicViewer.qml");
                else
                if( suffix === "txt" || suffix === "text" )
                    component = Qt.createComponent("TextViewer.qml");
                else
                if( suffix === "pdf" )
                    component = Qt.createComponent("PdfViewer.qml");

                var it = component.createObject(item);
                it.fileId = item.fileId
                it.path = item.path
                viewer = it

                it.deleteRequest.connect( attach_viewer.deleteRequest )
                it.widthChanged.connect( item.itemWidthChanged )
                it.heightChanged.connect( item.itemHeightChanged )
                it.xChanged.connect( item.itemXChanged )
                it.yChanged.connect( item.itemYChanged )

                if( it.width != 0 )  imgWidth = it.width
                if( it.height != 0 ) imgHeight = it.height
                imgX = it.x
                imgY = it.y
            }
        }

        focus: true
        highlight: Rectangle { color: "#3B97EC"; radius: 3; smooth: true }
        currentIndex: -1

        function refresh() {
            if( !model )
                return

            model.clear()
            if( attach_viewer.paperItem == -1 )
                return

            var files = database.paperFiles(attach_viewer.paperItem)
            for( var i=0; i<files.length; i++ )
                model.append({ "fid": files[i], "filePath": repository.getPath(files[i])})

            focus = true
        }

        onCurrentItemChanged: {
            if( !currentItem )
                return
        }

        Component.onCompleted: refresh()
    }

    ScrollBar {
        scrollArea: attach_list; width: attach_list.width; height: 8
        anchors.bottom: parent.bottom; anchors.bottomMargin: 8*physicalPlatformScale;
        color: "#ffffff"; orientation: Qt.Horizontal
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        delete_warn.text = qsTr("Are you sure?")
        yes_button.text  = qsTr("Delete")
        no_button.text   = qsTr("Cancel")
    }

    Component.onCompleted: {
        opacity = 1
        initTranslations()
    }
}
