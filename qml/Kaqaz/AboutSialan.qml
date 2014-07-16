import QtQuick 2.0

Item {
    width: 100
    height: 62

    Item {
        anchors.fill: parent
        anchors.bottomMargin: -navigationBarHeight

        Rectangle {
            anchors.fill: parent
            anchors.topMargin: -statusBarHeight
            color: "#ccffffff"
        }

        Flickable {
            id: flickable
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: visit_btn.top
            flickableDirection: Flickable.VerticalFlick

            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 80*physicalPlatformScale
                    height: width
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(width,height)
                    smooth: true
                    source: "files/sialan.png"
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SIALAN LABS"
                    font.pointSize: 20*fontsScale
                    font.weight: Font.DemiBold
                    font.family: globalFontFamily
                    color: "#333333"
                }

                Item {
                    width: 10
                    height: 20*physicalPlatformScale
                }

                Text {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 20*physicalPlatformScale
                    text: kaqaz.aboutSialan()
                    font.pointSize: 9*fontsScale
                    font.family: globalFontFamily
                    wrapMode: Text.WordWrap
                    color: "#333333"
                }
            }
        }

        ScrollBar {
            scrollArea: flickable; height: flickable.height; width: 8
            anchors.right: flickable.right; anchors.top: flickable.top; color: "#888888"
        }

        Button {
            id: visit_btn
            anchors.left: parent.left
            anchors.bottom: nav_rect.top
            anchors.right: parent.right
            height: 42*physicalPlatformScale
            normalColor: "#4098bf"
            highlightColor: "#337fa2"
            text: qsTr("Check Sialan website")
            onClicked: Qt.openUrlExternally("http://labs.sialan.org/")
        }

        Rectangle {
            id: nav_rect
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            height: navigationBarHeight
            color: visit_btn.press? visit_btn.highlightColor : visit_btn.normalColor
        }

        Header {
            id: title
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
        }
    }
}
