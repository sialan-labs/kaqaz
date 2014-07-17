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
