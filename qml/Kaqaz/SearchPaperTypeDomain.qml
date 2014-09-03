import QtQuick 2.0
import Kaqaz 1.0

Item {
    id: ptype_domain
    width: 100
    height: 62

    property int domain: Enums.AllPapers
    property string selectedText: "All Papers"

    Column {
        id: column
        anchors.fill: parent

        Behavior on x {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        MenuButton {
            height: 50*physicalPlatformScale
            width: column.width
            normalColor: "#00000000"
            highlightColor: "#4098bf"
            textColor: press? "#ffffff" : "#4098bf"
            textFont.weight: Font.Normal
            textFont.pixelSize: 13*fontsScale
            textFont.bold: false
            text: qsTr("Normal Papers")
            onClicked: {
                selectedText = text
                ptype_domain.domain = Enums.NormalPapers
            }
        }

        MenuButton {
            height: 50*physicalPlatformScale
            width: column.width
            normalColor: "#00000000"
            highlightColor: "#4098bf"
            textColor: press? "#ffffff" : "#4098bf"
            textFont.weight: Font.Normal
            textFont.pixelSize: 13*fontsScale
            textFont.bold: false
            text: qsTr("To-Do Papers")
            onClicked: {
                selectedText = text
                ptype_domain.domain = Enums.ToDoPapers
            }
        }

        MenuButton {
            height: 50*physicalPlatformScale
            width: column.width
            normalColor: "#00000000"
            highlightColor: "#4098bf"
            textColor: press? "#ffffff" : "#4098bf"
            textFont.weight: Font.Normal
            textFont.pixelSize: 13*fontsScale
            textFont.bold: false
            text: qsTr("Completed Tasks")
            onClicked: {
                selectedText = text
                ptype_domain.domain = Enums.CompletedTasks
            }
        }

        MenuButton {
            height: 50*physicalPlatformScale
            width: column.width
            normalColor: "#00000000"
            highlightColor: "#4098bf"
            textColor: press? "#ffffff" : "#4098bf"
            textFont.weight: Font.Normal
            textFont.pixelSize: 13*fontsScale
            textFont.bold: false
            text: qsTr("Uncompleted Tasks")
            onClicked: {
                selectedText = text
                ptype_domain.domain = Enums.UncompletedTasks
            }
        }
    }
}
