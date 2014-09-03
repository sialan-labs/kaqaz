import QtQuick 2.0
import Kaqaz 1.0

Item {
    id: todo_item
    height: txt.paintedHeight<check_frame.height? check_frame.height : txt.paintedHeight

    property alias alignment: txt.horizontalAlignment
    property color checkColor: "#888888"
    property alias text: txt.text
    property alias cursorPosition: txt.cursorPosition
    property alias checked: check_check.visible
    property alias checkable: check_frame.visible
    property alias textFocus: txt.focus
    property alias font: txt.font

    signal accepted(variant item)
    signal removed(variant item)
    signal removeNext(variant item)

    Item {
        id: check_frame
        anchors.verticalCenter: parent.verticalCenter
        height: 40*physicalPlatformScale
        width: height
        x: alignment==Text.AlignLeft? 0 : todo_item.width-width

        Rectangle {
            id: check
            anchors.fill: parent
            anchors.margins: 6*physicalPlatformScale
            radius: height/2
            border.color: checkColor
            border.width: 1*physicalPlatformScale
            color: "#00000000"

            Rectangle {
                id: check_check
                color: checkColor
                radius: height/2
                anchors.fill: parent
                anchors.margins: 3*physicalPlatformScale
                visible: false
            }
        }
    }

    TextEdit {
        id: txt
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        x: alignment==Text.AlignLeft && checkable? check_frame.width : 0
        width: checkable? todo_item.width - check_frame.width : todo_item.width
        verticalAlignment: TextInput.AlignVCenter
        wrapMode: TextEdit.WrapAtWordBoundaryOrAnywhere
        Keys.onPressed: {
            if( event.key == Qt.Key_Return || event.key == Qt.Key_Enter ) {
                if( event.modifiers == Qt.NoModifier ) {
                    todo_item.accepted(todo_item)
                    event.accepted = true
                }
            }
            else
            if( event.key == Qt.Key_Backspace ) {
                if( txt.cursorPosition == 0 ) {
                    todo_item.removed(todo_item)
                    event.accepted = true
                }
            }
            else
            if( event.key == Qt.Key_Delete ) {
                if( txt.cursorPosition == txt.text.length ) {
                    todo_item.removeNext(todo_item)
                    event.accepted = true
                }
            }
        }

        Component.onCompleted: highlighter.textDocument = txt.textDocument
        SearchHighlighter {
            id: highlighter
            searchKeyword: lastSearchKeyword
        }
    }

    function focusOn( x, y ){
        var item = todo_item.childAt(x,y)
        if( !item ) {
            txt.cursorPosition = txt.text.length
            txt.focus = true
            return
        }

        var pnt = todo_item.mapToItem(item,x,y)
        if( item == check_frame )
            checked = !checked
        else
        if( item == txt ) {
            txt.cursorPosition = txt.positionAt(pnt.x,pnt.y)
            txt.focus = true
        }
    }
}
