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
import Kaqaz 1.0

PaperAbstractButton {
    id: ptype_btn
    background: "files/paperbuttons/paper-note.png"

    property int paperType: paperItem>0? database.paperType(paperItem) : Enums.Normal
    property variant dateChooser

    onClicked: {
        if( !dateChooser )
            dateChooser = showBottomPanel(paper_type_component,true)
    }

    onRefresh: {
        if( paperType == Enums.Normal )
            background = "files/paperbuttons/paper-note.png"
        else
        if( paperType == Enums.ToDo )
            background = "files/paperbuttons/paper-task.png"
    }

    onPaperTypeChanged: refresh()

    Component {
        id: paper_type_component
        Column {
            id: paper_types
            height: 100*physicalPlatformScale

            MenuButton {
                height: 50*physicalPlatformScale
                width: paper_types.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
                textFont.bold: false
                text: qsTr("Normal")
                onClicked: {
                    paperObject.save()
                    database.setPaperType(paperItem,Enums.Normal)
                    ptype_btn.refresh()
                    hideBottomPanel()
                }
            }

            MenuButton {
                height: 50*physicalPlatformScale
                width: paper_types.width
                normalColor: "#00000000"
                highlightColor: "#4098bf"
                textColor: press? "#ffffff" : "#4098bf"
                textFont.weight: Font.Normal
                textFont.pixelSize: Devices.isMobile? 11*fontsScale : 13*fontsScale
                textFont.bold: false
                text: qsTr("To-Do")
                onClicked: {
                    paperObject.save()
                    database.setPaperType(paperItem,Enums.ToDo)
                    ptype_btn.refresh()
                    hideBottomPanel()
                }
            }
        }
    }
}
