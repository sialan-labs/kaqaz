import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    width: txt.width
    height: txt.height

    property alias text: txt.text
    property alias font: txt.font
    property alias color: txt.color
    property alias horizontalAlignment: txt.horizontalAlignment
    property alias verticalAlignment: txt.verticalAlignment

    property alias glowX: mask.glowX
    property alias glowWidth: mask.glowWidth
    property alias glowColor: txt_glow.color

    Text {
        id: txt
    }

    Rectangle {
        id: txt_glow_frame
        anchors.fill: txt
        color: "#00000000"
        visible: false
        smooth: true

        Text {
            id: txt_glow
            anchors.fill: parent
            text: txt.text
            font: txt.font
            color: "#ffffff"
            horizontalAlignment: txt.horizontalAlignment
            verticalAlignment: txt.verticalAlignment
        }
    }

    Rectangle {
        id: mask_frame
        anchors.fill: txt
        color: "#00000000"
        visible: false
        smooth: true

        Rectangle {
            id: mask
            width: txt.height
            height: txt.width
            transformOrigin: Item.Center
            anchors.centerIn: parent
            rotation: -90

            property real glowX: -glowWidth
            property real glowWidth: 20

            property real gradX: mask.glowX/mask.height
            property real gradWidth: glowWidth/mask.height

            gradient: Gradient {
                GradientStop { position: mask.gradX; color: "#00000000" }
                GradientStop { position: mask.gradX+mask.gradWidth/2; color: "#000000" }
                GradientStop { position: mask.gradX+mask.gradWidth; color: "#00000000" }
            }
        }
    }

    ThresholdMask {
        anchors.fill: txt
        source: txt_glow_frame
        maskSource: mask_frame
        threshold: 0.4
        spread: 0.6
    }
}
