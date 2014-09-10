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
import QtPositioning 5.2

Rectangle {
    id: kaqaz_root
    width: devices.isTouchDevice? 0 : kaqaz.size.width
    height: devices.isTouchDevice? 0 : kaqaz.size.height

    property real fixedPortraitHeight: 0
    property real fixedLandscapeHeight: 0
    property real fixedHeight: devices.isDesktop? height : fixedPortraitHeight-statusBarHeight-navigationBarHeight// (devices.screen.primaryOrientation==Qt.PortraitOrientation? fixedPortraitHeight : fixedLandscapeHeight)-statusBarHeight-navigationBarHeight

    property alias physicalPlatformScale: main.physicalPlatformScale
    property alias fontsScale: main.fontsScale
    property alias platformScale: main.platformScale

    property bool portrait: devices.isDesktop? width<height : true//(devices.screen.primaryOrientation==Qt.PortraitOrientation)

    property string globalFontFamily: devices.isIOS? "Droid Kaqaz Sans" : kaqaz_normal_font.name
    property string globalMonoFontFamily: devices.isIOS? "Droid Sans Mono" : kaqaz_mono_font.name

    property int globalInputMethodHints: kaqaz.keyboardPredicative? Qt.ImhNoPredictiveText : Qt.ImhNone
    property real statusBarHeight: devices.transparentStatusBar? 24*physicalPlatformScale : 0
    property real navigationBarHeight: devices.transparentNavigationBar? 45*physicalPlatformScale : 0

    property bool rotated: true
    property alias touchToBack: main.touchToBack
    property alias darkBackground: main.darkBackground
    property alias backHandler: main.backHandler

    property real flickVelocity: devices.isDesktop? 2500 : 25000

    property variant subMessage
    property alias pointerDialog: point_dialog.visible

    property alias sidePanel: main.sidePanel
    property alias panelAnimDuration: main.panelAnimDuration
    property alias bottomPanel: bottom_panel

    property alias menuIsVisible: main.menuIsVisible
    property alias pasteButtonTextObj: paste_btn.textItem
    property alias syncProgressBar: sync_pbar

    property alias rollerVisible: roller_dialog.visible
    property alias position: positioning.position

    property alias audioItem: audio_item

    property bool passDone: false

    property int publicCounter: 0
    property string lastSearchKeyword

    signal accessChanged()

    onHeightChanged: {
        size_save_timer.restart()
        refreshSizes()
    }
    onWidthChanged: {
        size_save_timer.restart()
    }

    onLastSearchKeywordChanged: if(lastSearchKeyword.length==0) hideBottomPanel()

    function refreshSizes() {
        if( height == 0 )
            return;
        if( devices.isDesktop )
            return

        if( devices.screen.primaryOrientation==Qt.PortraitOrientation && height>width*4/3 ) fixedPortraitHeight = height
        if( devices.screen.primaryOrientation==Qt.LandscapeOrientation && fixedLandscapeHeight == 0 ) fixedLandscapeHeight = height
    }

    Connections {
        target: database
        onPaperChanged: {
            if( !kaqaz.demoHasTrial() )
                showSubMessage(Qt.createComponent("DemoLimited.qml"))
        }
    }

    Timer {
        id: size_save_timer
        interval: 300
        repeat: false
        onTriggered: kaqaz.size = Qt.size(width,height)
    }

    FontLoader{
        id: kaqaz_normal_font
        source: kaqaz.resourcePath + "/fonts/DroidKaqazSans.ttf"
    }

    FontLoader{
        id: kaqaz_mono_font
        source: kaqaz.resourcePath + "/fonts/DroidSansMono.ttf"
    }

    Item {
        id: main_frame
        anchors.fill: parent

        MainItem{
            id: main
            x: 0
            y: statusBarHeight
            width: parent.width
            height: parent.height - statusBarHeight - navigationBarHeight

            Behavior on y {
                NumberAnimation { easing.type: Easing.OutCubic; duration: 250 }
            }
        }
    }

    BottomPanel {
        id: bottom_panel
        z: 10
    }

    RollerDialog {
        id: roller_dialog
        anchors.fill: parent
        z: 10
    }

    PasteButton {
        id: paste_btn
    }

    Audio{
        id: audio_item

        property variant activeBy
        onActiveByChanged: if( !activeBy ) audio_item.stop()
    }

    PositionSource {
        id: positioning
        updateInterval: 10000
        active: kaqaz.positioning
    }

    PointingDialog{
        id: point_dialog
    }

    Tooltip{
        id: tooltip
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 32*physicalPlatformScale + navigationBarHeight
    }

    ProgressBar {
        id: sync_pbar
        height: 6*physicalPlatformScale
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "#aaffffff"
        radius: 0
        visible: false
        onVisibleChanged: percent = 0

        Connections {
            target: sync
            onSyncProgress: sync_pbar.percent = val*100
            onSyncStarted: {
                invisible_timer.stop()
                sync_pbar.visible = true
                sync_pbar.percent = 0
            }
            onSyncFinished: {
                invisible_timer.restart()
                sync_pbar.percent = 100
            }
        }

        Timer {
            id: invisible_timer
            interval: 2000
            repeat: false
            onTriggered: sync_pbar.visible = false
        }
    }

    function showTooltip( text ){
        tooltip.showText(text)
    }

    function showSubMessage( item_component ){
        var item = item_component.createObject(kaqaz_root);

        var component = Qt.createComponent("SubMessage.qml");
        var msg = component.createObject(kaqaz_root);
        msg.source = main_frame
        msg.item = item
        return item
    }

    function hideSubMessage(){
        if( !subMessage )
            return

        subMessage.hide()
    }

    function showHideHilightPanel() {
        showBottomPanel( Qt.createComponent("SearchHideHighlights.qml") )
    }

    function showBottomPanel( component ){
        hideBottomPanel()
        var item = component.createObject(bottom_panel);
        bottom_panel.item = item
        return item
    }

    function hideBottomPanel() {
        if( bottom_panel.item )
            bottom_panel.hide()
    }

    function newModernProgressBar(){
        var component = Qt.createComponent("ModernProgressBar.qml");
        var item = component.createObject(kaqaz_root);
        item.source = main_frame
        return item
    }

    function showPointDialog( item, x, y, width, height ){
        point_dialog.item = item
        point_dialog.pointingTo(x,y,width,height)
    }

    function hidePointDialog(){
        point_dialog.hide()
    }

    function showRollerDialog( y1, y2, item ){
        roller_dialog.show(y1,y2,item)
    }

    function showHistory(){
        main.showHistory()
    }

    function hideRollerDialog(){
        roller_dialog.hide()
    }

    function createPaper( parent ){
        var component = Qt.createComponent("PaperItem.qml");
        var paper = component.createObject(parent);
        return paper
    }

    function setCurrentGroup( id ){
        main.setCurrentGroup(id)
    }

    function getKaqaz(){
        return kaqaz
    }

    function refresh(){
        sync_pbar.visible = false
        main.refresh()
        sync.reload()
    }

    function clean(){
        main.clean()
    }

    function showHelper(){
        var component = Qt.createComponent("Helper.qml");
        var item = component.createObject(kaqaz_root);
        return item
    }

    function showSplash(){
        return showSubMessage(Qt.createComponent("StartSplash.qml"))
    }

    function search(){
        main.showSearch()
    }

    function prefrences(){
        main.showPrefrences()
    }

    function back(){
        main.pressBack()
    }

    function getPass( parent ){

        var blur_item
        if( devices.isDesktop ) {
            var blur_cmpt = Qt.createComponent("KaqazBlur.qml");
            blur_item = blur_cmpt.createObject(kaqaz_root);
            blur_item.source = main
        }

        var component = Qt.createComponent("GetPassDialog.qml");
        var item = component.createObject(kaqaz_root);
        item.backBlur = blur_item
        item.parentItem = parent

        if( blur_item )
            item.success.connect(blur_item.destroy)

        return item
    }

    function accessGranted(){
        passDone = true
        kaqaz_root.accessChanged()
    }

    function accessDenied(){
        passDone = false
        kaqaz_root.accessChanged()
    }

    function lock(){
        if( database.password().length === 0 )
            return

        accessDenied()
        getPass(kaqaz_root).success.connect(kaqaz_root.accessGranted)
    }

    function showMenu(){
        main.showMenu()
    }

    function incomingShare( title, message ) {
        main.incomingShare(title,message)
    }

    function incomingImage( path ) {
        main.incomingImage(path)
    }

    Component.onCompleted: {
        if( database.password().length !== 0 )
            kaqaz_root.lock()
        else
            passDone = true
        if( !kaqaz.isTutorialCompleted() )
            showSplash()
        else
        if( !kaqaz.demoHasTrial() )
            showSubMessage(Qt.createComponent("DemoLimited.qml"))

        main.initPapers()
    }
}
