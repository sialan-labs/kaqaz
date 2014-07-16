import QtQuick 2.0

Item {
    id: state_page

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10*physicalPlatformScale

        Text {
            id: papers_text
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 15*fontsScale
            font.family: globalFontFamily
            color: "#333333"
        }

        Text {
            id: group_text
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 15*fontsScale
            font.family: globalFontFamily
            color: "#333333"
        }

        Text {
            id: date_text
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: 15*fontsScale
            font.family: globalFontFamily
            color: "#333333"
        }
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text       = qsTr("States")
        papers_text.text = qsTr("You have %1 Papers").replace("%1",database.statePapersCount())
        group_text.text  = qsTr("that sorts in %1 Labels").replace("%1",database.stateGroupsCount())
        date_text.text   = qsTr("and wrote in %1 Days").replace("%1",database.stateDatesCount())
    }

    Component.onCompleted: {
        initTranslations()
    }
}
