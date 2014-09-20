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
    id: restore_dialog
    width: 100
    height: 62

    Item {
        id: msg_item
        height: 54*physicalPlatformScale
        visible: false

        property string filePath

        Text {
            id: delete_warn
            font.pixelSize: 17*fontsScale
            font.family: SApp.globalFontFamily
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
                if( msg_item.filePath != "" )
                    kaqaz.removeFile(msg_item.filePath)

                hideRollerDialog()
                preference_list.refresh()
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

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
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
            height:  50*physicalPlatformScale
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

            Text{
                id: txt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text
                font.pixelSize: 12*fontsScale
                font.family: SApp.globalFontFamily
                color: item.press? "#ffffff" : "#333333"
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    var component = Qt.createComponent("RestoreWait.qml");
                    var rw = component.createObject(main);
                    rw.path = item.path
                    main.pushPreference(rw)
                }
            }

            Button {
                id: delete_btn
                height: parent.height
                width: height
                iconHeight: 22*physicalPlatformScale
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 10*physicalPlatformScale
                icon: "files/delete.png"
                normalColor: "#00000000"
                onClicked: {
                    msg_item.filePath = item.path
                    showRollerDialog( item.mapToItem(kaqaz_root,0,0).y, item.mapToItem(kaqaz_root,0,item.height).y, msg_item )
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

            var bkps = kaqaz.findBackups()
            for( var i=0; i<bkps.length; i++ )
                model.append({"name": Tools.fileName(bkps[i]), "adrs": bkps[i]})

            focus = true
        }
    }

    ScrollBar {
        scrollArea: preference_list; height: preference_list.height; width: 6*physicalPlatformScale
        anchors.right: preference_list.right; anchors.top: preference_list.top;color: "#000000"
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text       = qsTr("Available backups")
        delete_warn.text = qsTr("Are you sure?")
        yes_button.text  = qsTr("Delete")
        no_button.text   = qsTr("Cancel")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
