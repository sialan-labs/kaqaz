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
    id: gallery_dialog
    width: 100
    height: 62

    property variant sizeSelector

    signal selected( string repID )

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        light: true
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

        property int dept: -1
        property string path

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: preference_list.width
            height: 100*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string text: name
            property string path: adrs
            property bool directory: isDir
            property bool press: false

            onPressChanged: hideRollerDialog()

            Connections{
                target: preference_list
                onMovementStarted: press = false
                onFlickStarted: press = false
            }

            Image{
                id: img
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 10*physicalPlatformScale
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                width: height*4/3
                sourceSize.width: width
                sourceSize.height: height
                source: item.directory? "files/folder.png" : "file://" + item.path
            }

            Text{
                id: txt
                anchors.left: img.right
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text.length == 0? qsTr("Back") : parent.text
                font.pixelSize: 12*fontsScale
                font.family: globalFontFamily
                color: "#ffffff"
                clip: true
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    if( item.directory )
                        gallery_dialog.open(item.path)
                    else {
                        var component = Qt.createComponent("ImageSizeSelector.qml");
                        var i = component.createObject(main);
                        i.path = item.path
                        i.selected.connect(gallery_dialog.selected)
                        main.pushPreference(i)
                        gallery_dialog.sizeSelector = i
                    }
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

        Component.onCompleted: {

            refresh( kaqaz.picturesLocation() )
        }

        function refresh( path ){
            model.clear()
            preference_list.path = path

            var dirs = kaqaz.dirEntryDirs(path)
            for( var i=0; i<dirs.length ; i++ )
                model.append({"name": kaqaz.fileName(dirs[i]), "adrs": dirs[i], "isDir": true})

            var files = kaqaz.dirEntryFiles(path,["*.jpg","*.JPEG","*.jpeg","*.JPG","*.png","*.PNG"])
            for( var i=0; i<files.length ; i++ )
                model.append({"name": kaqaz.fileName(files[i]), "adrs": files[i], "isDir": false})

            focus = true
        }
    }

    ScrollBar {
        scrollArea: preference_list; height: preference_list.height; width: 6*physicalPlatformScale
        anchors.right: preference_list.right; anchors.top: preference_list.top;color: "#ffffff"
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("Gallery")
    }

    function open( path ){
        preference_list.refresh(path)
        preference_list.dept++
    }

    function back(){
        if( sizeSelector )
            return false
        if( preference_list.dept < 0 )
        {
            backHandler = 0
            return false
        }

        preference_list.refresh(preference_list.path+"/..")
        preference_list.dept--

        return true
    }

    Component.onCompleted: {
        initTranslations()
        backHandler = gallery_dialog
    }
}
