import QtQuick 2.0
import SialanTools 1.0

Column {
    id: column
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: parent.right

    Text {
        width: main.width - 40*physicalPlatformScale
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 10*physicalPlatformScale
        font.family: SApp.globalFontFamily
        font.pixelSize: 9*fontsScale
        color: "#333333"
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        text: qsTr("Thank you for choosing Kaqaz.\nIf you are like this app, please rate us on Google play or Bazaar.\nThank you.")
    }

    Row {
        anchors.right: parent.right
        Button {
            textFont.family: SApp.globalFontFamily
            textFont.pixelSize: 10*fontsScale
            textColor: "#0d80ec"
            normalColor: "#00000000"
            highlightColor: "#660d80ec"
            text: qsTr("Cancel")
            onClicked: {
                BackHandler.back()
            }
        }

        Button {
            textFont.family: SApp.globalFontFamily
            textFont.pixelSize: 10*fontsScale
            textColor: "#0d80ec"
            normalColor: "#00000000"
            highlightColor: "#660d80ec"
            text: qsTr("OK")
            onClicked: {
                if(kaqaz.proBuild)
                    Qt.openUrlExternally("market://details?id=org.sialan.kaqaz")
                else
                    Qt.openUrlExternally("market://details?id=org.sialan.kaqaz.free")
                BackHandler.back()
            }
        }
    }
}
