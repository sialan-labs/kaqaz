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
    id: abs_list
    width: 100
    height: 62

    property real itemHeight: 36*physicalPlatformScale

    property variant items
    property string itemComponentFile: "AbstractListItem.qml"

    property bool invert: false

    Rectangle {
        id: highlighter
        color: "#333333"
        smooth: true
        radius: 3*physicalPlatformScale
        visible: false
        width: h_txt.paintedWidth + 16*physicalPlatformScale
        height: 40*physicalPlatformScale
        x: -width

        property alias text: h_txt.text

        Text {
            id: h_txt
            y: parent.height/2 - height/2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8*physicalPlatformScale
            font.pointSize: (physicalPlatformScale == 0)? 1 : 15*physicalPlatformScale
            font.family: globalFontFamily
            color: "#ffffff"
        }
    }

    function dynamicHeight(){
        return itemHeight*items.length
    }

    function createItem(){
        var component = Qt.createComponent(itemComponentFile);
        var item = component.createObject(abs_list);
        return item
    }

    function itemAt( y ){
        var index = Math.floor(invert? (abs_list.height-y)/itemHeight : y/itemHeight)
        if( index < 0 || index >= items.length )
            return 0

        return items[index]
    }

    function highlight( y ){
        var index = Math.floor(invert? (abs_list.height-y)/itemHeight : y/itemHeight)
        if( index < 0 || index >= items.length )
        {
            highlighter.visible = false
            return
        }

        var item = items[index]
        if( item.tooltip === "" )
        {
            highlighter.visible = false
            return
        }

        highlighter.visible = true
        highlighter.y = y - highlighter.height/2
        highlighter.text = item.tooltip
    }

    Component.onCompleted: {
        if( itemComponentFile != "AbstractListItem.qml" )
            return

        var ar = new Array
        for( var i=0; i<50; i++ )
        {
            var item = createItem()
            item.guid = "Item #" + i
            item.index = i

            ar[i] = item
        }
        items = ar
    }
}
