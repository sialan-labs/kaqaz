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

PaperAbstractButton {
    id: pw_btn
    background: "files/weather/weather-unknown.png"

    property string paperWeather: paperItem? database.paperWeather(paperItem) : ""
    property variant weatherChooser

    onClicked: {
        if( !weatherChooser )
            weatherChooser = showBottomPanel(paper_weather_component,true)
    }

    onRefresh: {
        var icon_name = "weather-unknown"
        switch( paperWeather ) {
        case "01d":
            icon_name = "weather-clear";
            break;
        case "01n":
            icon_name = "weather-clear-night";
            break;
        case "02d":
            icon_name = "weather-few-clouds";
            break;
        case "02n":
            icon_name = "weather-few-clouds-night";
            break;
        case "03d":
            icon_name = "weather-clouds";
            break;
        case "03n":
            icon_name = "weather-clouds-night";
            break;
        case "04d":
            icon_name = "weather-overcast";
            break;
        case "04n":
            icon_name = "weather-overcast";
            break;
        case "09d":
            icon_name = "weather-showers";
            break;
        case "09n":
            icon_name = "weather-showers";
            break;
        case "10d":
            icon_name = "weather-showers-scattered";
            break;
        case "10n":
            icon_name = "weather-showers-scattered";
            break;
        case "11d":
            icon_name = "weather-storm";
            break;
        case "11n":
            icon_name = "weather-storm";
            break;
        case "13d":
            icon_name = "weather-snow";
            break;
        case "13n":
            icon_name = "weather-snow";
            break;
        case "50d":
            icon_name = "weather-fog";
            break;
        case "50n":
            icon_name = "weather-fog";
            break;
        }

        background = "files/weather/" + icon_name + ".png"
    }

    onPaperWeatherChanged: refresh()

    Component {
        id: paper_weather_component

        Column {
            width: 20

            Text {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10*physicalPlatformScale
                font.family: SApp.globalFontFamily
                font.pixelSize: 12*fontsScale
                color: "#333333"
                text: qsTr("Please select weather")
            }

            ListView {
                id: pw_list
                height: 92*physicalPlatformScale
                width: parent.width
                orientation: ListView.Horizontal
                model: ListModel{}
                delegate: Item {
                    width: height
                    height: pw_list.height

                    Image {
                        anchors.fill: parent
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                        sourceSize: Qt.size(width,height)
                        source: "files/weather/" + iconPath + ".png"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            paperObject.save()
                            database.setPaperWeather(paperItem,iconId)
                            pw_btn.refresh()
                            hideBottomPanel()
                        }
                    }
                }

                Component.onCompleted: {
                    pw_list.model.append( {"iconId": "01d", "iconPath": "weather-clear"} )
                    pw_list.model.append( {"iconId": "01n", "iconPath": "weather-clear-night"} )
                    pw_list.model.append( {"iconId": "02d", "iconPath": "weather-few-clouds"} )
                    pw_list.model.append( {"iconId": "02n", "iconPath": "weather-few-clouds-night"} )
                    pw_list.model.append( {"iconId": "03d", "iconPath": "weather-clouds"} )
                    pw_list.model.append( {"iconId": "03n", "iconPath": "weather-clouds-night"} )
                    pw_list.model.append( {"iconId": "04d", "iconPath": "weather-overcast"} )
                    pw_list.model.append( {"iconId": "09d", "iconPath": "weather-showers"} )
                    pw_list.model.append( {"iconId": "10d", "iconPath": "weather-showers-scattered"} )
                    pw_list.model.append( {"iconId": "11d", "iconPath": "weather-storm"} )
                    pw_list.model.append( {"iconId": "13d", "iconPath": "weather-snow"} )
                    pw_list.model.append( {"iconId": "50d", "iconPath": "weather-fog"} )
                    pw_list.model.append( {"iconId": ""   , "iconPath": "weather-unknown"} )
                }
            }
        }
    }
}
