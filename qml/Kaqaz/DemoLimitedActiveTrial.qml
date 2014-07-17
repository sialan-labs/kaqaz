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
    id: active_trial
    anchors.fill: parent

    signal active()

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 40*physicalPlatformScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10*physicalPlatformScale

        Text {
            id: limit_text
            anchors.left: parent.left
            anchors.right: parent.right
            font.pointSize: 30*fontsScale
            font.family: globalFontFamily
            height: 70*physicalPlatformScale
            horizontalAlignment: Text.AlignHCenter
            color: "#333333"
            text: qsTr("ACTIVE KAQAZ")
        }

        Text {
            id: choice_text
            anchors.left: parent.left
            anchors.right: parent.right
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.family: globalFontFamily
            font.pointSize: 12*fontsScale
            color: "#333333"
            text: qsTr("Active Kaqaz demo until next use.")
        }
    }

    Button {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 40*physicalPlatformScale
        anchors.rightMargin: 40*physicalPlatformScale
        anchors.bottomMargin: 20*physicalPlatformScale
        height: 42*physicalPlatformScale
        normalColor: "#4098bf"
        highlightColor: "#337fa2"
        text: qsTr("Active")
        onClicked: active_trial.active()
    }
}
