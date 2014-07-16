import QtQuick 2.2

Item {
    id: item
    width: img.width
    height: img.height
    anchors.centerIn: parent

    property string fileId: fid
    property string path: filePath

    property alias imgItem: img

    signal deleteRequest( variant item )

    Image{
        id: img
        anchors.centerIn: parent
        asynchronous: true
        width: smaller? sourceSize.width : (ratio>1? frameWidth : frameHeight*ratio)
        height: smaller? sourceSize.height : (ratio>1? frameWidth/ratio : frameHeight)
        fillMode: Image.PreserveAspectFit
        source: "file://" + path

        property real frameWidth: frameHeight
        property real frameHeight: item.parent.height
        property real ratio: sourceSize.width/sourceSize.height
        property bool smaller: (sourceSize.width<frameWidth && sourceSize.height<frameHeight)
    }
}
