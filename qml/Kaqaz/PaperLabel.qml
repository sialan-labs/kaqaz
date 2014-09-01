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
import Kaqaz 1.0

Item {
    id: paper_label

    property variant item
    property variant paperItem
    property int paperId: paperItem? paperItem.paperItem : -1

    property alias text: txt.text
    property alias font: txt.font
    property alias horizontalAlignment: txt.horizontalAlignment
    property alias paintedHeight: txt.paintedHeight
    property alias paintedWidth: txt.paintedWidth
    property alias textFocus: txt.focus
    property alias cursorRectangle: txt.cursorRectangle

    property alias pickersPressed: txt.press
    property alias selectedText: txt.selectedText
    property alias commitBlocker: txt.commitBlocker

    property alias selectionStart: txt.selectionStart
    property alias selectionEnd: txt.selectionEnd

    property alias cursorPosition: txt.cursorPosition
    property bool resizeOnFull: true

    property int paperType: Enums.Normal

    onPaperIdChanged: {
        if( paperId != -1 )
            paperType = database.paperType(paperId)
        else
            paperType = Enums.Normal
    }

    onItemChanged: {
        if( !item )
            return

        paper_label.text = item.text
    }

    onTextChanged: {
        if( to_do.visible )
            to_do.text = text
        if( !item )
            return

        item.text = paper_label.text
        item.html = paper_label.text
    }

    onWidthChanged: if(paper_label) paper_label.refreshEditPosition()
    onHeightChanged: if(paper_label) paper_label.refreshEditPosition()
    onXChanged: if(paper_label) paper_label.refreshEditPosition()
    onYChanged: if(paper_label) paper_label.refreshEditPosition()
    onVisibleChanged: if(paper_label) paper_label.refreshEditPosition()

    Connections {
        target: database
        onPaperChanged: {
            if( !paperItem )
                return
            if( paperItem.paperItem != id )
                return

            paperType = database.paperType(paperItem.paperItem)
        }
    }

    Item {
        anchors.fill: parent
    }

    TextEdit{
        id: placeholder_text
        anchors.fill: txt
        font: txt.font
        color: "#cccccc"
        visible: (!txt.focus && txt.text == "" && txt.visible)
    }

    TextAreaCore{
        id: txt
        anchors.fill: parent
        anchors.topMargin: 5*physicalPlatformScale
        font.pixelSize: devices.isLargeTablet? 10*fontsScale : 9*fontsScale
        font.family: globalFontFamily
        wrapMode: Text.Wrap
        smooth: true
        selectionColor: "#0d80ec"
        selectedTextColor: "#ffffff"
        inputMethodHints: globalInputMethodHints
        visible: paperType == Enums.Normal
        Component.onCompleted: highlighter.textDocument = txt.textDocument
    }

    PaperToDo {
        id: to_do
        anchors.fill: parent
        anchors.topMargin: 5*physicalPlatformScale
        visible: paperType == Enums.ToDo
        onTextChanged: if(visible) paper_label.text = text
        onVisibleChanged: if(visible) text = paper_label.text
    }

    SearchHighlighter {
        id: highlighter
        searchKeyword: lastSearchKeyword
    }

    Item{
        id: btn_box
        parent: paper
        width: portrait? edit_btn.width + menu_btn.width : edit_btn.width
        height: 30*physicalPlatformScale
        z: 20

        Button {
            id: menu_btn
            width: height
            anchors.top: parent.top
            anchors.bottom: btn_box.bottom
            anchors.right: parent.right
            icon: press? "files/menu_hover_64.png" : "files/menu_64.png"
            iconHeight: 32*physicalPlatformScale
            normalColor: "#00000000"
            highlightColor: "#00000000"
            opacity: press? 1 : 0.1
            visible: portrait
            onClicked: {
                showMenu()
                main.focus = true
                devices.hideKeyboard()
            }
        }

        Button{
            id: edit_btn
            width: height
            anchors.top: btn_box.top
            anchors.bottom: btn_box.bottom
            anchors.right: menu_btn.left
            anchors.rightMargin: 2*physicalPlatformScale
            icon: press? "files/edit_hover_64.png" : "files/edit_64.png"
            iconHeight: 32*physicalPlatformScale
            normalColor: "#00000000"
            highlightColor: "#00000000"
            opacity: press? 1 : 0.1
            onClicked: {
                main.focus = true
                paper_label.edit()
            }
        }
    }

    Button {
        id: listview_btn
        parent: paper
        height: 30*physicalPlatformScale
        width: height
        icon: press? "files/listview_hover.png" : "files/listview.png"
        iconHeight: 30*physicalPlatformScale
        normalColor: "#00000000"
        highlightColor: "#00000000"
        opacity: press? 1 : 0.2
        z: 20
        onClicked: main.showListView()
    }

    function positionToRectangle(pos) {
        return txt.positionToRectangle(pos)
    }

    function isPointOnPickers( x, y ) {
        return txt.isPointOnPickers(x,y)
    }

    function insertAtCurrent( str ){
        txt.insert( txt.cursorPosition, " " + str + " " )
    }

    function focusOn( x, y ){
        txt.focus = true
        txt.cursorPosition = txt.positionAt(x,y)
        showPicker()
    }

    function selectWord( x, y ){
        focusOn(x,y)
        txt.selectWord()
    }

    function edit(){
        main.closePanel()
        var msg = showSubMessage(Qt.createComponent("PaperEditDialog.qml"))
        msg.item = paper_label
        devices.hideKeyboard()
    }

    function commitFaders() {
        txt.commitFaders()
    }

    function refreshEditPosition(){
        btn_box.x = paper_label.mapToItem(paper,paper_label.width,0).x + 14*physicalPlatformScale -btn_box.width
        btn_box.y = 15+10*physicalPlatformScale
        listview_btn.x = btn_box.x + btn_box.width - listview_btn.width
        listview_btn.y = paper.mapToItem(paper,0,paper.height).y - listview_btn.height - 10*physicalPlatformScale - 15
    }

    function showPicker() {
        txt.showPicker()
    }

    function hidePicker() {
        txt.hidePicker()
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        placeholder_text.text = qsTr("New text")
    }

    Component.onCompleted: initTranslations()
}
