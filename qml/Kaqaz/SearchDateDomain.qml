import QtQuick 2.0

Item {
    id: date_domain
    width: 100
    height: 62

    Row {
        id: row
        anchors.fill: parent
        anchors.margins: 20*physicalPlatformScale
        spacing: 20*physicalPlatformScale

        DateTimeChooser {
            id: start_dt
            timeVisible: false
            dateVisible: true
            width: parent.width/2 - row.spacing/2
            height: parent.height
            color: "#D9D9D9"
            textsColor: "#111111"
            dateLabel: qsTr("Start Date")
        }

        DateTimeChooser {
            id: end_dt
            timeVisible: false
            dateVisible: true
            width: parent.width/2 - row.spacing/2
            height: parent.height
            color: "#D9D9D9"
            textsColor: "#111111"
            dateLabel: qsTr("End Date")
        }
    }
}
