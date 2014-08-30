import QtQuick 2.0

Rectangle {
    width: 100
    height: 62

    property real longitude
    property real latitude

    Image {
        id: splash_map
        source: "files/map-loading.png"
        anchors.fill: parent
        sourceSize: Qt.size(width,height)
        visible: !master_map.visible
        fillMode: Image.PreserveAspectCrop

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            font.family: globalFontFamily
            font.pixelSize: 13*fontsScale
            text: !latitude || !longitude? qsTr("Unknown point") : qsTr("Loading Map...")
        }
    }

    Image {
        id: master_map
        anchors.fill: parent
        asynchronous: true
        visible: master_map.status == Image.Ready && (latitude || longitude)
        sourceSize: Qt.size(width,height)
        source: "http://maps.google.com/maps/api/staticmap?center=" + latitude + "," + longitude + "&zoom=15&size=" + Math.floor(width) + "x" + Math.floor(height) + "&sensor=false"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if( !longitude && !latitude )
                    Qt.openUrlExternally("http://maps.google.com")
                else
                    Qt.openUrlExternally("http://maps.google.com/maps?&daddr=" + latitude + "," + longitude)
            }
        }
    }

    Image {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.verticalCenter
        source: "files/map-pin.png"
        sourceSize: Qt.size(width,height)
        fillMode: Image.PreserveAspectFit
        width: 92*physicalPlatformScale
        height: 92*physicalPlatformScale
        visible: master_map.visible
        smooth: true
    }
}
