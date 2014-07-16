import QtQuick 2.2

Item {
    id: music_dialog
    width: 100
    height: 62

    signal selected( string repID )

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        light: true
    }

    ListView {
        id: preference_list
        anchors.top: title.bottom
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 20*physicalPlatformScale
        highlightMoveDuration: 250
        clip: true
        maximumFlickVelocity: flickVelocity

        property int dept: -1
        property string path

        model: ListModel {}
        delegate: Rectangle {
            id: item
            width: preference_list.width
            height: 80*physicalPlatformScale
            color: press? "#3B97EC" : "#00000000"

            property string text: name
            property string path: adrs
            property bool directory: isDir
            property bool press: false

            onPressChanged: hideRollerDialog()

            Connections{
                target: preference_list
                onMovementStarted: press = false
                onFlickStarted: press = false
            }

            Image{
                id: img
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 10*physicalPlatformScale
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                width: height*4/3
                sourceSize.width: width
                sourceSize.height: height
                source: item.directory? "files/folder.png" : "files/audio.png"
            }

            Text{
                id: txt
                anchors.left: img.right
                anchors.right: parent.right
                anchors.margins: 30*physicalPlatformScale
                y: parent.height/2 - height/2
                text: parent.text.length == 0? qsTr("Back") : parent.text
                font.pointSize: 12*fontsScale
                font.family: globalFontFamily
                color: "#ffffff"
                clip: true
            }

            MouseArea{
                anchors.fill: parent
                onPressed: item.press = true
                onReleased: item.press = false
                onClicked: {
                    if( item.directory )
                        music_dialog.open(item.path)
                    else {
                        var id = repository.copyAudioToRepository( item.path )
                        music_dialog.selected(id)

                        backHandler = 0
                        main.popPreference()
                        main.popPreference()
                        darkBackground = false
                    }
                }
            }
        }

        focus: true
        highlight: Rectangle { color: "#3B97EC"; radius: 3; smooth: true }
        currentIndex: -1

        onCurrentItemChanged: {
            if( !currentItem )
                return
        }

        Component.onCompleted: {

            refresh( kaqaz.musicsLocation() )
        }

        function refresh( path ){
            model.clear()
            preference_list.path = path

            var dirs = kaqaz.dirEntryDirs(path)
            for( var i=0; i<dirs.length ; i++ )
                model.append({"name": kaqaz.fileName(dirs[i]), "adrs": dirs[i], "isDir": true})

            var files = kaqaz.dirEntryFiles(path,["*.mp3","*.ogg","*.MP3","*.ogg","*.wav","*.WAV"])
            for( var i=0; i<files.length ; i++ )
                model.append({"name": kaqaz.fileName(files[i]), "adrs": files[i], "isDir": false})

            focus = true
        }
    }

    ScrollBar {
        scrollArea: preference_list; height: preference_list.height; width: 8
        anchors.right: preference_list.right; anchors.top: preference_list.top;color: "#ffffff"
    }

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        title.text = qsTr("Music")
    }

    function open( path ){
        preference_list.refresh(path)
        preference_list.dept++
    }

    function back(){
        if( preference_list.dept < 0 )
        {
            backHandler = 0
            return false
        }

        preference_list.refresh(preference_list.path+"/..")
        preference_list.dept--

        return true
    }

    Component.onCompleted: {
        initTranslations()
        backHandler = music_dialog
    }
}
