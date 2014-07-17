/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

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
