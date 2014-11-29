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
import Kaqaz 1.0
import SialanTools 1.0

Item {
    id: ts_dialog
    width: 100
    height: 62

    property variant countries: new Array
    property variant languages: new Array

    property int currentCountry: 0
    property int currentLanguage: 0

    signal letsGo()

    onCountriesChanged: {
        countries_list.model.clear()
        for( var i=0; i<countries.length; i++ )
            countries_list.model.append( {"name": countries[i]} )
    }

    onLanguagesChanged: {
        languages_list.model.clear()
        for( var i=0; i<languages.length; i++ )
            languages_list.model.append( {"name": languages[i]} )
    }

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        text: qsTr("Save and Send")
    }

    Flickable {
        id: flickable
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: save_path_txt.top
        anchors.leftMargin: 20*physicalPlatformScale
        anchors.rightMargin: 20*physicalPlatformScale
        contentHeight: column.height
        contentWidth: column.width
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
            id: column
            width: flickable.width
            spacing: 4*physicalPlatformScale
            anchors.margins: 20*physicalPlatformScale

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Country")
                font.pixelSize: 15*fontsScale
                font.family: SApp.globalFontFamily
                color: "#333333"
            }

            Rectangle {
                color: "#88ffffff"
                anchors.left: parent.left
                anchors.right: parent.right
                height: ts_dialog.height/3

                ListView {
                    id: countries_list
                    anchors.fill: parent
                    anchors.margins: 10*physicalPlatformScale
                    clip: true
                    model: ListModel{}
                    delegate: Rectangle {
                        width: countries_list.width
                        height:  40*physicalPlatformScale
                        color: marea.pressed || currentCountry==index? "#3B97EC" : "#00000000"

                        Text{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 20*physicalPlatformScale
                            y: parent.height/2 - height/2
                            text: name
                            font.pixelSize: Devices.isMobile? 11*fontsScale : 12*fontsScale
                            font.family: SApp.globalFontFamily
                            color: marea.pressed? "#ffffff" : "#333333"
                        }

                        MouseArea{
                            id: marea
                            anchors.fill: parent
                            onClicked: {
                                currentCountry = index
                            }
                        }
                    }
                }

                ScrollBar {
                    scrollArea: countries_list; height: countries_list.height; width: 6*physicalPlatformScale
                    anchors.right: countries_list.right; anchors.top: countries_list.top; color: "#000000"
                }
            }

            Item { width: 20; height: 16*physicalPlatformScale }

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                text: qsTr("Language")
                font.family: SApp.globalFontFamily
                font.pixelSize: 15*fontsScale
                color: "#333333"
            }

            Rectangle {
                color: "#88ffffff"
                anchors.left: parent.left
                anchors.right: parent.right
                height: ts_dialog.height/3

                ListView {
                    id: languages_list
                    anchors.fill: parent
                    anchors.margins: 10*physicalPlatformScale
                    clip: true
                    model: ListModel{}
                    delegate: Rectangle {
                        width: languages_list.width
                        height:  40*physicalPlatformScale
                        color: lmarea.pressed || currentLanguage==index? "#3B97EC" : "#00000000"

                        Text{
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: 20*physicalPlatformScale
                            y: parent.height/2 - height/2
                            text: name
                            font.pixelSize: Devices.isMobile? 11*fontsScale : 12*fontsScale
                            font.family: SApp.globalFontFamily
                            color: lmarea.pressed? "#ffffff" : "#333333"
                        }

                        MouseArea{
                            id: lmarea
                            anchors.fill: parent
                            onClicked: {
                                currentLanguage = index
                            }
                        }
                    }
                }

                ScrollBar {
                    scrollArea: languages_list; height: languages_list.height; width: 6*physicalPlatformScale
                    anchors.right: languages_list.right; anchors.top: languages_list.top; color: "#000000"
                }
            }
        }
    }

    ScrollBar {
        scrollArea: flickable; height: flickable.height; width: 6*physicalPlatformScale
        anchors.left: flickable.right; anchors.top: flickable.top; color: "#000000"
    }

    Text {
        id: save_path_txt
        anchors.left: parent.left
        anchors.bottom: done_btn.top
        anchors.right: parent.right
        anchors.leftMargin: 20*physicalPlatformScale
        anchors.rightMargin: 20*physicalPlatformScale
        anchors.bottomMargin: 2*physicalPlatformScale
        font.pixelSize: 10*fontsScale
        font.family: SApp.globalFontFamily
        text: "Will save to: " + kaqaz.getTempPath() + ".ts" +
              "\nPlease send this file to contact@sialan.org after saved."
    }

    Button {
        id: done_btn
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20*physicalPlatformScale
        height: 42*physicalPlatformScale
        normalColor: "#4098bf"
        highlightColor: "#337fa2"
        text: qsTr("Lets Go")
        onClicked: ts_dialog.letsGo()
    }
}
