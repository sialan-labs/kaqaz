import QtQuick 2.0
import QtGraphicalEffects 1.0

Rectangle {
    id: seletable_list
    width: 100
    height: 62

    property alias currentIndex: list.currentIndex
    property variant currentItem: list.currentItem? list.currentItem.itemName : 0
    property variant items: new Array
    property color textsColor
    property color splitersColor: "#66bbbbbb"
    property real itemsHeight: 40*physicalPlatformScale

    property variant nameMethodObject: seletable_list
    property string nameMethodFunction: "itemName"

    onItemsChanged: list.refresh()

    Rectangle {
        id: background
        anchors.fill: parent
        color: parent.color

        ListView {
            id: list
            anchors.fill: parent
            clip: true
            topMargin: (height-itemsHeight)/2
            bottomMargin: topMargin
            preferredHighlightBegin: list.height/2 - itemsHeight/2
            preferredHighlightEnd: list.height/2 + itemsHeight/2
            highlightRangeMode: ListView.StrictlyEnforceRange
            snapMode: ListView.SnapToItem
            model: ListModel{}
            delegate: Item {
                width: list.width
                height: itemsHeight

                property variant itemName: name

                Text {
                    id: txt
                    anchors.centerIn: parent
                    font.family: globalFontFamily
                    font.pixelSize: 11*fontsScale
                    text: tools.call(nameMethodObject,nameMethodFunction,Qt.DirectConnection,name)
                    color: textsColor
                }
            }

            function refresh() {
                model.clear()

                for( var i=0; i<items.length; i++ )
                    model.append({"index":i,"name":items[i]})

                list.focus = true
            }
        }
    }

    Rectangle {
        id: top_part
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height/2 - itemsHeight/2
        clip: true
        color: parent.color

        Desaturate {
            source: background
            width: background.width
            height: background.height
            anchors.top: parent.top
            transformOrigin: Item.Top
            scale: 0.8
            opacity: 0.7
        }
    }

    Rectangle {
        id: bottom_part
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height/2 - itemsHeight/2
        clip: true
        color: parent.color

        Desaturate {
            source: background
            width: background.width
            height: background.height
            anchors.bottom: parent.bottom
            transformOrigin: Item.Bottom
            scale: 0.8
            opacity: 0.7
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient{
            GradientStop { position: 0.00; color: seletable_list.color }
            GradientStop { position: 0.22; color: "#00000000" }
            GradientStop { position: 0.77; color: "#00000000" }
            GradientStop { position: 1.00; color: seletable_list.color }
        }
    }

    Rectangle {
        height: 1*physicalPlatformScale
        width: parent.width
        anchors.top: top_part.bottom
        color: splitersColor
    }

    Rectangle {
        height: 1*physicalPlatformScale
        width: parent.width
        anchors.bottom: bottom_part.top
        color: splitersColor
    }

    function positionViewAtIndex( index ) {
        list.positionViewAtIndex(index,ListView.Center)
    }

    function itemName( index ) {
        return index
    }
}
