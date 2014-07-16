import QtQuick 2.2

Item {
    id: attach_menu
    width: 100
    height: opened? (kaqaz_root.width>minimumHeight? minimumHeight : kaqaz_root.width) : toggle_btn.height + 25*physicalPlatformScale

    property real minimumHeight: kaqaz_root.height - 50*physicalPlatformScale

    property bool opened: false
    property int paperItem
    property variant paper
    property variant attachments

    onPaperItemChanged: {
        if( paperItem == -1 )
        {
            attachments = 0
            attach_img.dynamicSource = "files/attachment.png"
            return
        }

        attachments = database.paperFiles(paperItem)
    }

    onAttachmentsChanged: {
        if( !attachments )
            return

        attach_img.dynamicSource = (attachments.length === 0)? "files/attachment.png" : "files/attachment_blue.png"
    }

    onOpenedChanged: {
        sidePanel = !opened
        activeText = 0
        if( opened )
            load_timer.restart()
        else {
            load_timer.stop()
            if( gallery_frame.item )
                gallery_frame.item.destroy()
        }
    }

    Behavior on height {
        NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
    }

    Rectangle {
        id: back_img
        anchors.fill: parent
        anchors.bottomMargin: -6*physicalPlatformScale - navigationBarHeight
        color: "#000000"
        opacity: attach_menu.opened? 0.9 : 0

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }
    }

    Timer{
        id: load_timer
        repeat: false
        interval: 500
        onTriggered: {
            var component = Qt.createComponent("AttachViewer.qml");
            var item = component.createObject(gallery_frame);
            item.paperItem = attach_menu.paperItem
            item.paper = attach_menu.paper

            gallery_frame.item = item
        }
    }

    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
        visible: attach_menu.opened
    }

    MouseArea {
        id: hide_area
        hoverEnabled: true
        anchors.bottom: attach_menu.top
        width: kaqaz_root.width
        height: kaqaz_root.height - attach_menu.height
        onClicked: attach_menu.opened = false
        visible: attach_menu.opened
    }

    Rectangle {
        id: shadow
        width: parent.width
        height: 5*physicalPlatformScale
        anchors.bottom: attach_menu.top
        opacity: attach_menu.opened? 1 : 0
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#00000000" }
            GradientStop { position: 1.0; color: "#66000000" }
        }

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }
    }

    Button{
        id: attach_btn
        anchors.verticalCenter: toggle_btn.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10*physicalPlatformScale
        width: 30*physicalPlatformScale
        normalColor: "#00000000"
        radius: 2*physicalPlatformScale
        visible: attach_menu.opened
        opacity: attach_menu.opened? 1 : 0
        icon: "files/add.png"
        border.width: 1*physicalPlatformScale
        border.color: "#ffffff"
        onClicked: {
            if( !kaqaz.isTouchDevice() ){
                var list = kaqaz.getOpenFileNames( qsTr("Select media files."), "Images (*.png *.jpg);;Musics (*.mp3 *.ogg);;Documents (*.pdf *.txt *.text)" )
                for( var i=0; i<list.length; i++ ){
                    var id = repository.insert( list[i] )
                    attach_menu.selected(id)
                }
            } else {
                var component = Qt.createComponent("AttachInsertDialog.qml");
                var item = component.createObject(main);
                item.selected.connect( attach_menu.selected )
                main.pushPreference(item)
            }
        }

        Behavior on opacity {
            NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }
    }

    Rectangle {
        id: toggle_btn
        y: 5*physicalPlatformScale
        anchors.horizontalCenter: attach_menu.horizontalCenter
        width: 40*physicalPlatformScale
        height: width
        radius: width/2
        color: press? "#3B97EC" : normalColor
        smooth: true
        border.width: 1*physicalPlatformScale
        border.color: "#ffffff"

        property bool press: false
        property color normalColor: attach_menu.opened? "#00000000" : "#cccccc"

        Behavior on normalColor {
            ColorAnimation { easing.type: Easing.OutCubic; duration: 250 }
        }

        Image {
            id: attach_img
            anchors.fill: parent
            anchors.margins: 10*physicalPlatformScale
            source: toggle_btn.press || attach_menu.opened? "files/attachment.png" : dynamicSource
            smooth: true

            property string dynamicSource: "files/attachment.png"
        }

        MouseArea {
            anchors.fill: parent
            onPressed: toggle_btn.press = true
            onReleased: toggle_btn.press = false
            onClicked: attach_menu.opened = !attach_menu.opened
        }
    }

    Item {
        id: gallery_frame
        x: 0
        y: toggle_btn.y + toggle_btn.height
        width: parent.width
        height: parent.height - (toggle_btn.y + toggle_btn.height)
        transformOrigin: Item.TopLeft

        property variant item

        property real root_x: 0
        property real root_y: 0
    }

    function selected( id ){
        if( paperItem == -1 )
            paper.save()

        var attachments = database.paperFiles(paperItem)
        var attach_res = new Array

        for( var i=0; i<attachments.length; i++ )
            attach_res[attach_res.length] = attachments[i]

        attach_res[attach_res.length] = id
        attach_menu.attachments = attach_res

        database.addFileToPaper(paperItem,id)

        if( gallery_frame.item ){
            gallery_frame.item.paperItem = -1
            gallery_frame.item.paperItem = paperItem
        }
    }

    function hide(){
        if( !opened )
            return false

        opened = false
        return true
    }
}
