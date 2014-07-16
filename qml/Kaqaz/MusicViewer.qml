import QtQuick 2.2
import QtMultimedia 5.0

Item {
    id: item
    anchors.fill: parent

    property string fileId: fid
    property string path: filePath

    property alias imgItem: img
    property alias paintedHeight: img.paintedHeight

    signal deleteRequest( variant item )

    Connections{
        target: audioItem
        onPlaying: playBtn.playStt = ( audioItem.source == "file://" + item.path )
        onStopped: playBtn.playStt = false
    }

    Image{
        id: img
        anchors.fill: parent
        anchors.margins: 30*physicalPlatformScale
        asynchronous: true
        sourceSize.width: img.width
        sourceSize.height: img.height
        fillMode: Image.PreserveAspectFit
        source: "files/audio_background.png"
    }

    Button {
        id: playBtn
        height: 128*physicalPlatformScale
        width: height
        radius: height/2
        normalColor: "#33ffffff"
        icon: playStt? "files/pause.png" : "files/play.png"
        iconHeight: 80*physicalPlatformScale
        anchors.horizontalCenter: item.horizontalCenter
        anchors.verticalCenter: item.verticalCenter
        onClicked: {
            if( audioItem.playbackState == Audio.PlayingState )
                audioItem.stop()
            else
            {
//                audioItem.activeBy = item
                audioItem.source = "file://" + item.path
                audioItem.play()
            }
        }

        property bool playStt: false
    }

    Component.onCompleted: {
        if( audioItem.source != "file://" + item.path )
            return

        playBtn.playStt = (audioItem.playbackState == Audio.PlayingState)
    }
}
