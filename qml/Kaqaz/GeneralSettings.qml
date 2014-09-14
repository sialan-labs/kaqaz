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

Item {
    id: configure
    width: 100
    height: 62

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    ListView {
        id: prefrences
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: preference_list.width
            height:  50*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string dstFile: file
            property alias press: marea.pressed
            property bool checkable: check

            property string prprt: pr

            Text{
                id: txt
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                y: parent.height/2 - height/2
                font.pixelSize: devices.isMobile? 11*fontsScale : 13*fontsScale
                font.family: globalFontFamily
                color: item.press? "#ffffff" : "#333333"
                wrapMode: TextInput.WordWrap
                text: name
            }

            MouseArea{
                id: marea
                anchors.fill: parent
                onClicked: {
                    if( !item.checkable ) {
                        var component = Qt.createComponent(item.dstFile)
                        var citem = component.createObject(sub_frame)
                        sub_frame.item = citem
                        configure.viewMode = true
                    } else {
                        checkbox.checked = !checkbox.checked
                    }
                }
            }

            CheckBox {
                id: checkbox
                x: kaqaz.languageDirection == Qt.RightToLeft? 20 : item.width - width - 20
                anchors.verticalCenter: parent.verticalCenter
                visible: item.checkable
                checked: item.prprt.length==0? false : kaqaz.property(kaqaz,item.prprt)
                color: item.press? "#ffffff" : "#333333"
                onCheckedChanged: kaqaz.setProperty(kaqaz,item.prprt,checked)
            }
        }

        highlight: Rectangle { color: "#3B97EC"; radius: 3; smooth: true }
        currentIndex: -1

        function refresh() {
            model.clear()
            model.append({ "name": qsTr("All papers item"), "file": "", "check": true, "pr":"allPaper"})
            if( kaqaz.proBuild )
                model.append({ "name": qsTr("Notes positioning"), "file": "", "check": true, "pr":"positioning"})
            if( devices.isMacX )
                model.append({ "name": qsTr("Desktop Touch"), "file": "", "check": true, "pr":"desktopTouchMode"})
            if( !devices.isDesktop )
                model.append({ "name": qsTr("Fullscreen"), "file": "", "check": true, "pr":"fullscreen"})
            model.append({ "name": qsTr("Word suggestions"), "file": "", "check": true, "pr":"keyboardPredicative"})
            model.append({ "name": qsTr("Groups count"), "file": "", "check": true, "pr":"groupsCount"})
        }
    }

    ScrollBar {
        scrollArea: prefrences; height: prefrences.height; width: 6*physicalPlatformScale
        anchors.right: prefrences.right; anchors.top: prefrences.top; color: "#000000"
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        prefrences.refresh()
        title.text = qsTr("General Settings")
    }

    Component.onCompleted: {
        initTranslations()
    }
}
