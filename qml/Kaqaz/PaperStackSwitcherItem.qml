import QtQuick 2.2

Item{
    id: switcher_item
    x: 0
    y: 0
    width: parent.width
    height: parent.height

    property variant item

    onItemChanged: {
        if( !item )
            return

        item.parent = switcher_item
        item.x = 0
        item.y = 0
        item.width = width
        item.height = height
    }

    onWidthChanged: {
        if( !item )
            return

        item.width = width
    }

    onHeightChanged:  {
        if( !item )
            return

        item.height = height
    }
}
