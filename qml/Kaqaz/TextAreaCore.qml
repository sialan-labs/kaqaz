import QtQuick 2.0

TextEdit {
    id: core

    property alias press: cpicker.press
    property alias commitBlocker: cpicker.commitBlocker

    onTextChanged: {
        if( privates.last_text != text )
            cpicker.hide()

        privates.last_text = text
    }
    onFocusChanged: {
        if( !focus )
            cpicker.hide()
    }

    QtObject {
        id: privates
        property string last_text
    }

    MouseArea {
        anchors.fill: parent
        onPressed: {
            cpicker.show()
            if( core.selectionEnd == core.selectionStart )
                mouse.accepted = false
            else
                mouse.accepted = true
        }
        onReleased: {
            core.deselect()
            core.cursorPosition = core.positionAt(mouseX,mouseY)
        }
    }

    CursorPicker {
        id: cpicker
        anchors.fill: parent
        mainQml: kaqaz_root
        mainClass: kaqaz
        textItem: core
    }

    function isPointOnPickers( x, y ) {
        return cpicker.isPointOnPickers(x,y)
    }

    function commitFaders() {
        cpicker.commitFaders()
    }

    function showPicker() {
        cpicker.show()
    }

    function hidePicker() {
        cpicker.hide()
    }
}
