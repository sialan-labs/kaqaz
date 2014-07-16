import QtQuick 2.2

Item {
    id: security
    width: 100
    height: 62

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    Text{
        id: message
        y: parent.height/2- (message.height + pass_frame.height + pass_repeat_frame.height + buttons_frame.height )/2
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*physicalPlatformScale
        font.pointSize: 15*fontsScale
        font.family: globalFontFamily
        color: "#333333"
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        id: pass_frame
        color: "white"
        smooth: true
        radius: 3*physicalPlatformScale
        height: 40*physicalPlatformScale
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: message.bottom
        anchors.topMargin: 4*physicalPlatformScale
        anchors.leftMargin: 20*physicalPlatformScale
        anchors.rightMargin: 20*physicalPlatformScale

        TextInput{
            id: pass_placeholder
            color: "#bbbbbb"
            font.pointSize: pass.font.pointSize
            font.family: globalFontFamily
            y: pass.y
            anchors.left: pass.left
            anchors.right: pass.right
            anchors.margins: pass.anchors.margins
            visible: (!pass.focus && pass.text == "")
        }

        TextInput{
            id: pass
            color: "#333333"
            font.pointSize: 11*fontsScale
            font.family: globalFontFamily
            y: pass_frame.height/2-height/2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*physicalPlatformScale
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhDigitsOnly
            onAccepted: pass_repeat.focus = true
        }
    }

    Rectangle {
        id: pass_repeat_frame
        color: "white"
        smooth: true
        radius: 3*physicalPlatformScale
        height: 40*physicalPlatformScale
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: pass_frame.bottom
        anchors.topMargin: 4*physicalPlatformScale
        anchors.leftMargin: 20*physicalPlatformScale
        anchors.rightMargin: 20*physicalPlatformScale

        TextInput{
            id: pass_repeat_placeholder
            color: "#bbbbbb"
            font.pointSize: pass_repeat.font.pointSize
            font.family: globalFontFamily
            y: pass_repeat.y
            anchors.left: pass_repeat.left
            anchors.right: pass_repeat.right
            anchors.margins: pass_repeat.anchors.margins
            visible: (!pass_repeat.focus && pass_repeat.text == "")
        }

        TextInput{
            id: pass_repeat
            color: "#333333"
            font.pointSize: 11*fontsScale
            font.family: globalFontFamily
            y: pass_repeat_frame.height/2-height/2
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10*physicalPlatformScale
            echoMode: TextInput.Password
            inputMethodHints: Qt.ImhDigitsOnly
            onAccepted: kaqaz.hideKeyboard()
        }
    }

    Item{
        id: buttons_frame
        height: 40*physicalPlatformScale
        width: parent.width
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: pass_repeat_frame.bottom
        anchors.topMargin: 10*physicalPlatformScale

        Button{
            id: done_btn
            height: 40*physicalPlatformScale
            width: buttons_frame.width/2 - 30*physicalPlatformScale
            anchors.left: parent.left
            anchors.top: buttons_frame.top
            anchors.bottom: buttons_frame.bottom
            anchors.leftMargin: 20*physicalPlatformScale
            fontSize: 9*fontsScale
            normalColor: "#66ffffff"
            textColor: "#333333"
            visible: pass.text == pass_repeat.text
            onClicked: {
                database.setPassword( kaqaz.passToMd5(pass.text) )
                showTooltip( qsTr("Password changed") )
                kaqaz_root.refresh()
                popPreference()
            }
        }

        Button{
            id: cancel_btn
            height: 40*physicalPlatformScale
            width: done_btn.width
            anchors.left: done_btn.right
            anchors.top: buttons_frame.top
            anchors.bottom: buttons_frame.bottom
            anchors.leftMargin: 20*physicalPlatformScale
            fontSize: 9*fontsScale
            normalColor: "#66ffffff"
            textColor: "#333333"
            onClicked: popPreference()
        }
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        message.text = qsTr("You can set password from here for Kaqaz start up.")
        pass_placeholder.text = qsTr("New password")
        pass_repeat_placeholder.text = qsTr("Repeat password")
        done_btn.text = qsTr("Ok")
        cancel_btn.text = qsTr("Cancel")
        title.text = qsTr("Security")
    }

    Component.onCompleted: {
        if( database.password().length != 0 )
            getPass(security).allowBack = true

        initTranslations()
    }
}
