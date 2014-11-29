/*
    Copyright (C) 2014 Aseman
    http://aseman.co

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
import AsemanTools 1.0

Item {
    id: group_chooser_back
    width: Devices.isMobile? 75*physicalPlatformScale : 100*physicalPlatformScale
    height: 30*physicalPlatformScale

    property real radius: 3*physicalPlatformScale
    property color color: "#aaaaaa"

    property int group
    property bool press: false

    onGroupChanged: {
        txt.text = database.groupName(group)
        color = database.groupColor(group)
    }

    Rectangle{
        anchors.fill: parent
        anchors.bottomMargin: group_chooser_back.radius
        color: group_chooser_back.press? "#3B97EC" : group_chooser_back.color
    }

    Rectangle{
        anchors.fill: parent
        radius: group_chooser_back.radius
        color: group_chooser_back.press? "#3B97EC" : group_chooser_back.color
    }

    Text{
        id: txt
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        font.bold: Devices.isTablet
        font.pixelSize: Devices.isTouchDevice? (Devices.isMobile? 8*fontsScale : 9*fontsScale) : 10*fontsScale
        font.family: SApp.globalFontFamily
        color: "#ffffff"
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: 1
        elide: Text.ElideRight
        wrapMode: Text.WrapAnywhere
        text: qsTr("No Label")
    }

}
