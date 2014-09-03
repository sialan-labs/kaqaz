import QtQuick 2.0

Item {
    id: time_domain
    width: 100
    height: 62

    property alias startTime: start_tm
    property alias endTime: end_tm

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 20*physicalPlatformScale
        spacing: 20*physicalPlatformScale

        DateTimeChooser {
            id: start_tm
            timeVisible: true
            dateVisible: false
            width: parent.width/2 - row.spacing/2
            height: parent.height
            color: "#D9D9D9"
            textsColor: "#111111"
            timeLabel: qsTr("Start Time")
        }

        DateTimeChooser {
            id: end_tm
            timeVisible: true
            dateVisible: false
            width: parent.width/2 - row.spacing/2
            height: parent.height
            color: "#D9D9D9"
            textsColor: "#111111"
            timeLabel: qsTr("End Time")
        }
    }
}
