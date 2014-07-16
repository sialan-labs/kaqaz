import QtQuick 2.2

Item {
    property alias color : rectangle.color
    property alias shadowOpacity: shadow.opacity
    property alias radius: rectangle.radius
    property alias visibleShadow: shadow.visible
    property real shadowSize: 8

    BorderImage {
        id: shadow
        opacity: 0.6
        anchors.fill: rectangle
        anchors { leftMargin: -shadowSize; topMargin: -shadowSize; rightMargin: -shadowSize; bottomMargin: -shadowSize }
        border { left: 10; top: 10; right: 10; bottom: 10 }
        source: "files/shadow.png";
        smooth: true
    }

    Rectangle {
        id: rectangle;
        smooth: true
        anchors.fill: parent
        radius: 5
    }
}
