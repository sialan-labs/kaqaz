import QtQuick 2.0

Button {
    id: dyn_paste_btn
    x: textItem? textItem.mapToItem(kaqaz_root,textRect.x,textRect.y).x - width/2 : 0
    y: textItem? textItem.mapToItem(kaqaz_root,textRect.x,textRect.y).y - height - 5*physicalPlatformScale : 0
    width: 60*physicalPlatformScale
    height: 30*physicalPlatformScale
    radius: 2*physicalPlatformScale
    normalColor: "#88333333"
    highlightColor: "#333333"
    textFont.bold: false
    textColor: "#ffffff"
    visible: textItem? true : false

    property variant textItem
    property rect textRect: textItem? textItem.cursorRectangle : Qt.rect(0,0,0,0)

    onClicked: if( textItem ) textItem.paste()

    Connections{
        target: kaqaz
        onLanguageChanged: initTranslations()
    }

    function initTranslations(){
        dyn_paste_btn.text = qsTr("Paste")
    }

    Component.onCompleted: initTranslations()
}
