import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: pback
    width: 100
    height: 62

    property color color: paper_back_rect.color
    property real shadowSize: 15

    Item {
        id: shdw
        anchors.fill: parent
        anchors.margins: -5 - pback.shadowSize
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.margins: pback.shadowSize - shdw.anchors.margins
            radius: pback.shadowSize-5
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#000000" }
                GradientStop { position: 0.5; color: "#22000000" }
                GradientStop { position: 1.0; color: "#000000" }
            }
        }
    }

    FastBlur {
        anchors.fill: shdw
        anchors.leftMargin: 4
        anchors.topMargin: 4
        source: shdw
        radius: 28
    }

    Rectangle {
        id: paper_back_rect
        anchors.fill: parent
        anchors.margins: pback.shadowSize
        color: "#EDEDED"
    }
}
