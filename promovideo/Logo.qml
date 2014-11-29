import QtQuick 2.0

Item {
    width: 130
    height: 130

    Image {
        id: kaqaz_img
        anchors.fill: parent
        source: "files/kaqaz-icon.png"
        sourceSize: Qt.size(width,height)
    }

    AnimatedImage {
        anchors.centerIn: kaqaz_img
        anchors.margins: -70
        source: "files/animated-aseman-icon.gif"
        playing: true
    }
}
