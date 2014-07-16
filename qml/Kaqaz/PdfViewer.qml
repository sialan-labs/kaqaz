import QtQuick 2.2

Item {
    id: item
    anchors.fill: parent

    property string fileId: fid
    property string path: filePath

    property alias imgItem: img
    property alias paintedHeight: img.paintedHeight

    signal deleteRequest( variant item )

    Image{
        id: img
        anchors.fill: parent
        anchors.margins: 30*physicalPlatformScale
        asynchronous: true
        sourceSize.width: img.width
        sourceSize.height: img.height
        fillMode: Image.PreserveAspectFit
        source: "files/pdf_background.png"
    }
}
