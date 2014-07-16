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
