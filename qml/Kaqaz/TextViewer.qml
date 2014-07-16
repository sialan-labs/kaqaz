import QtQuick 2.2

Item {
    id: item
    anchors.fill: parent

    property string fileId: fid
    property string path: filePath

    property alias imgItem: back
    property alias paintedHeight: back.height

    signal deleteRequest( variant item )

    onPathChanged: desc.text = kaqaz.readText(path)

    Rectangle{
        id: back
        anchors.fill: parent
        anchors.margins: 20*physicalPlatformScale
        color: "#ffffff"
        radius: 3*physicalPlatformScale

        Flickable {
             id: flick
             anchors.fill: back
             anchors.margins: 20*physicalPlatformScale

             flickableDirection: Flickable.VerticalFlick

             contentWidth: desc.paintedWidth
             contentHeight: desc.paintedHeight
             clip: true

             function ensureVisible(r)
             {
                 if (contentX >= r.x)
                     contentX = r.x;
                 else if (contentX+width <= r.x+r.width)
                     contentX = r.x+r.width-width;
                 if (contentY >= r.y)
                     contentY = r.y;
                 else if (contentY+height <= r.y+r.height)
                     contentY = r.y+r.height-height;
             }

             TextEdit {
                 id: desc
                 color: "#000000"
                 width: flick.width
                 height: flick.height
                 readOnly: true
                 selectByMouse: false
                 wrapMode: TextEdit.WordWrap
                 onCursorRectangleChanged: flick.ensureVisible(cursorRectangle)
             }
         }

        ScrollBar {
            scrollArea: flick; height: flick.height; width: 10
            anchors.right: back.right; anchors.top: flick.top; color: "#333333"
        }
    }
}
