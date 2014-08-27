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
    id: search_panel
    width: 100
    height: 50*physicalPlatformScale

    property alias text: txt.text

    signal keywordChanged( string text )

    onTextChanged: search_timer.restart()

    Rectangle{
        id: back
        color: "#66ffffff"
        anchors.fill: parent
        anchors.margins: 20*physicalPlatformScale
        anchors.topMargin: 10*physicalPlatformScale
        anchors.bottomMargin: 0
        radius: 3
    }

    Image {
        id: icon
        anchors.top: back.top
        anchors.bottom: back.bottom
        anchors.left: back.left
        anchors.margins: 10*physicalPlatformScale
        width: height
        source: "files/search.png"
    }

    Text{
        id: placeholder_txt
        anchors.verticalCenter: back.verticalCenter
        anchors.left: icon.right
        anchors.right: back.right
        anchors.margins: 10*physicalPlatformScale
        color: "#ffffff"
        visible: (!txt.focus && txt.text == "")
        font: txt.font
    }

    TextInput{
        id: txt
        anchors.verticalCenter: back.verticalCenter
        anchors.left: icon.right
        anchors.right: back.right
        anchors.margins: 10*physicalPlatformScale
        font.pixelSize: 13*fontsScale
        font.family: globalFontFamily
        inputMethodHints: Qt.ImhNoPredictiveText
    }

    Timer{
        id: active_focus_timer
        interval: 501
        repeat: false
        onTriggered: txt.focus = true
    }

    Timer{
        id: search_timer
        interval: 700
        repeat: false
        onTriggered: search_panel.keywordChanged(text)
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        placeholder_txt.text = qsTr("Search keyword")
    }

    Component.onCompleted: {
        active_focus_timer.start()
        touchToBack = true
        initTranslations()
    }
}
