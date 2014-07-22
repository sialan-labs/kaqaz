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

Image {
    id: un_version
    anchors.fill: parent
    source: "files/background.jpg"
    fillMode: Image.PreserveAspectCrop

    Text{
        id: txt
        y: un_version.height/2-(txt.height+email_label.height+email_frame.height+signup_btn.height+
                                50*platformScale)/2
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 20*platformScale
        font.pixelSize: 13*platformScale
        font.family: globalFontFamily
        color: "#333333"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Text{
        id: email_label
        y: un_version.height/2-height/2
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: txt.bottom
        anchors.margins: 40*platformScale
        font.pixelSize: 13*platformScale
        font.family: globalFontFamily
        color: "#333333"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        id: email_frame
        color: "white"
        smooth: true
        radius: 3*platformScale
        height: 40*platformScale
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: email_label.bottom
        anchors.topMargin: 4*platformScale
        anchors.leftMargin: 40*platformScale
        anchors.rightMargin: 40*platformScale

        TextInput{
            id: email
            color: "#333333"
            font.pixelSize: 13*platformScale
            font.family: globalFontFamily
            y: email_frame.height/2-height/2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 20*platformScale
            font.capitalization: Font.AllLowercase
        }
    }

    Button{
        id: signup_btn
        height: 40*platformScale
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: email_frame.bottom
        anchors.topMargin: 4*platformScale
        anchors.leftMargin: 40*platformScale
        anchors.rightMargin: 40*platformScale
        fontSize: 11*fontsScale
        onClicked: kaqaz.close()
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        txt.text = qsTr("This version of Kaqaz is not compatible with smart phones.\nKaqaz is coming soon for smart phones.\n\nSignup below to know when Kaqaz is available for smart phones!");
        email_label.text = qsTr("Enter Your Email Address:")
        signup_btn.text = qsTr("Keep me posted!")
    }

    Component.onCompleted: initTranslations()
}
