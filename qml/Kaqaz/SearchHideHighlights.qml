import QtQuick 2.0

Item {
    width: 100
    height: hide_btn.height + 20*physicalPlatformScale + navigationBarHeight

    Button {
        id: hide_btn
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 10*physicalPlatformScale
        height: 30*physicalPlatformScale
        width: 125*physicalPlatformScale
        color: "#4098bf"
        highlightColor: "#3B8DB1"
        textColor: "#ffffff"
        text: qsTr("Hide Highlights")
        onClicked: {
            lastSearchKeyword = ""
        }
    }
}
