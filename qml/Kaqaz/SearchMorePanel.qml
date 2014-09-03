import QtQuick 2.0

Item {
    id: more_panel
    width: 100
    height: column.height + header_frame.height

    property bool startPage: true

    Item {
        id: header_frame
        height: 50*physicalPlatformScale
        width: parent.width

        Button {
            id: back_btn
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10*physicalPlatformScale
            height: 30*physicalPlatformScale
            width: 100*physicalPlatformScale
            color: "#ff5532"
            highlightColor: "#E34B2C"
            textColor: "#ffffff"
            text: qsTr("Back")
            visible: !startPage
            onClicked: {
                more_panel.startPage = true
                item_destroy_timer.restart()
            }
        }

        Button {
            id: done_btn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10*physicalPlatformScale
            height: 30*physicalPlatformScale
            width: 100*physicalPlatformScale
            color: "#4098bf"
            highlightColor: "#3B8DB1"
            textColor: "#ffffff"
            text: qsTr("Done")
            onClicked: {
                if( !startPage ) {
                    more_panel.startPage = true
                    item_destroy_timer.restart()
                } else {
                    hideBottomPanel()
                }
            }
        }
    }

    Column {
        id: column
        anchors.top: header_frame.bottom
        width: parent.width
        x: startPage? 0 : -width

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
            text: qsTr("Date Domain")
            onClicked: {
                showItem(date_domain_component)
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
            text: qsTr("Time Domain")
            onClicked: {
                showItem(time_domain_component)
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
            text: qsTr("Category")
            onClicked: {
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
            text: qsTr("Paper Type")
            onClicked: {
            }
        }
    }

    Item {
        id: pages_frame
        anchors.top: column.top
        anchors.left: column.right
        anchors.bottom: column.bottom
        width: parent.width

        property variant item

        onItemChanged: {
            if( item )
                item.anchors.fill = pages_frame
        }

        Timer {
            id: item_destroy_timer
            interval: 400
            onTriggered: if(pages_frame.item) pages_frame.item.destroy()
        }
    }

    Component {
        id: date_domain_component
        SearchDateDomain {
            id: date_domain_item
        }
    }

    Component {
        id: time_domain_component
        SearchTimeDomain {
            id: time_domain_item
        }
    }

    function showItem( component ) {
        pages_frame.item = component.createObject(pages_frame)
        startPage = false
    }
}
