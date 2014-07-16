import QtQuick 2.2

Item {
    id: add_group

    property int groupId
    property variant groupChooserItem

    signal accepted( string guid )

    onGroupIdChanged: {
        if( !groupId )
            return

        txt.text = database.groupName(groupId)
        color_list.currentColor = database.groupColor(groupId)
    }

    Rectangle{
        id: txt_frame
        anchors.left: add_group.left
        anchors.right: add_group.right
        anchors.top: add_group.top
        anchors.topMargin: 20*physicalPlatformScale
        anchors.leftMargin: 90*physicalPlatformScale
        anchors.rightMargin: 90*physicalPlatformScale
        height: 75*physicalPlatformScale
        radius: 3*physicalPlatformScale
        color: color_list.currentColor

        Text{
            id: placeholder_txt
            anchors.fill: txt
            color: "#cccccc"
            visible: (!txt.focus && txt.text == "")
            font: txt.font
            horizontalAlignment: txt.horizontalAlignment
        }

        TextInput{
            id: txt
            x: parent.width/2 - width/2
            y: parent.height/2 - height/2
            width: parent.width
            font.pointSize: 14*fontsScale
            font.bold: kaqaz.isWindows()? false : true
            font.family: globalFontFamily
            color: "white"
            horizontalAlignment: Text.AlignHCenter
            inputMethodHints: Qt.ImhNoPredictiveText
        }
    }

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    Button{
        id: ok_button
        anchors.left: add_group.left
        anchors.right: add_group.right
        anchors.bottom: add_group.bottom
        anchors.margins: 20*physicalPlatformScale
        height: 60*physicalPlatformScale
        onClicked: add_group.accept()
        fontSize: 12*fontsScale
        normalColor: "#66ffffff"
        textColor: "#333333"
    }

    ColorList{
        id: color_list
        anchors.top: txt_frame.bottom
        anchors.left: ok_button.left
        anchors.right: ok_button.right
        anchors.bottom: ok_button.top
        anchors.bottomMargin: 8*physicalPlatformScale
        anchors.topMargin: 20*physicalPlatformScale
    }

    function accept(){
        var gId = (groupId)? groupId : database.createGroup()
        database.setGroupName(gId, txt.text==""? placeholder_txt.text : txt.text )
        database.setGroupColor( gId, color_list.currentColor )

        if( groupChooserItem )
            groupChooserItem.group = gId

        add_group.accepted( gId )
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        ok_button.text = qsTr("Done")
        placeholder_txt.text = qsTr("New Label")
    }

    Component.onCompleted: initTranslations()
}
