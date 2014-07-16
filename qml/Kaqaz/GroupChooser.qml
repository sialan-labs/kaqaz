import QtQuick 2.2

Item {
    id: group_chooser
    width: gc_back.width
    height: gc_back.height
    smooth: true
    clip: true

    property alias radius: gc_back.radius
    property alias color: gc_back.color

    property bool signal_blocker: false

    property variant paperItem: parent
    property alias group: gc_back.group

    property bool press: false

    onGroupChanged: {
        if( !signal_blocker )
            group_chooser.groupSelected(group)
    }

    signal groupSelected( int id )

    Component.onCompleted: {
        signal_blocker = true
        group = 0
        signal_blocker = false
    }

    GroupChooserBack {
        id: gc_back
        press: mousearea.pressed
    }

    MouseArea{
        id: mousearea
        anchors.fill: group_chooser
        onClicked: {
            selectGroup()
            kaqaz.hideKeyboard()
        }
    }

    function selectGroup(){
        var component = Qt.createComponent("GroupSelector.qml");
        var paper = component.createObject(kaqaz_root);
        paper.selected.connect(group_chooser.finished)

        var point = mapToItem(kaqaz_root,width/2,height)
        var h = paper.realHeight()+50
        if( h > 5*kaqaz_root.height/9 )
            h = 5*kaqaz_root.height/9

        showPointDialog( paper, 0, point.y - 2, 240*physicalPlatformScale, h )
    }

    function finished( gid ){
        hidePointDialog()
        if( gid == -1 )
        {
            addNewGroup()
        }
        else
        {
            group_chooser.group = gid
            group_chooser.groupSelected(gid)
        }
    }

    function addNewGroup(){
        var component = Qt.createComponent("AddGroupDialog.qml");
        var add_group = component.createObject(main);
        add_group.groupChooserItem = group_chooser
        add_group.accepted.connect(group_chooser.finished)
        add_group.accepted.connect(main.closeDialog)
        main.showDialog(add_group)
    }

    Connections{
        target: kaqaz
        onLanguageChanged: {
            if( group )
                txt.text = database.groupName(group)
        }
    }
}
