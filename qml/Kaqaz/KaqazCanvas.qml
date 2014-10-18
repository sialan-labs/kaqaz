import QtQuick 2.0
import SialanTools 1.0

Item {
    id: kcanvas
    width: 100
    height: 62

    signal done( string fileName )

    ListObject {
        id: list
    }

    Timer {
        id: update_timer
        interval: 50
        onTriggered: canvas.requestPaint()
    }

    PaperBackground {
        id: paper_back
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: tools.top
        anchors.bottomMargin: -10*physicalPlatformScale
    }

    Item {
        id: canvas_frame
        anchors.fill: paper_back
        anchors.margins: 20*physicalPlatformScale

        Canvas {
            id: canvas
            anchors.fill: parent
            renderStrategy: Canvas.Threaded

            property bool newLine: false
            property bool endLine: false
            property bool start: false

            property color strokeColor: "#333333"

            onPaint: {
                var ctx = canvas.getContext("2d");
                if( !start ) {
                    ctx.fillStyle = paper_back.color
                    ctx.fillRect(0,0,width,height)
                    start = true
                    return
                }
                if( list.isEmpty() && !endLine )
                    return

                ctx.strokeStyle = strokeColor
                ctx.lineWidth = 3*physicalPlatformScale

                if( endLine ) {
                    endLine = false
                    while( !list.isEmpty() )
                        list.takeFirst()

                    return
                }

                var item = list.takeFirst()
                if( newLine ) {
                    ctx.beginPath()
                    ctx.moveTo(item.x,item.y)
                    newLine = false
                }

                while( !list.isEmpty() ) {
                    item = list.takeFirst()
                    ctx.lineTo(item.x,item.y)
                }

                ctx.stroke()
            }

            Component.onCompleted: requestPaint()
        }

        MouseArea {
            anchors.fill: parent

            property int count: 0
            onMouseXChanged: {
                var item = {"x":mouseX,"y":mouseY}
                if( list.last() == item )
                    return

                list.append(item)
                if( !update_timer.running )
                    update_timer.start()
            }
            onMouseYChanged: {
                var item = {"x":mouseX,"y":mouseY}
                if( list.last() == item )
                    return

                list.append(item)
                if( !update_timer.running )
                    update_timer.start()
            }
            onPressed: {
                canvas.newLine = true
                canvas.endLine = false
            }
            onReleased: {
                update_timer.stop()
                canvas.endLine = true
                canvas.newLine = false
                canvas.requestPaint()
            }
        }
    }

    Row {
        id: tools
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 60*physicalPlatformScale
        spacing: 8*physicalPlatformScale
        anchors.leftMargin: 8*physicalPlatformScale
        anchors.rightMargin: 8*physicalPlatformScale

        Button {
            width: 80*physicalPlatformScale
            height: 40*physicalPlatformScale
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Done")
            icon: "files/done.png"
            normalColor: "#66ffffff"
            textColor: "#333333"
            onClicked: {
                var fileName = kaqaz.getTempPath() + ".png"
                canvas.save(fileName)

                kcanvas.done(fileName)

                kaqaz.removeFile(fileName)
                main.closeDialog()
            }
        }

        Component.onCompleted: {
            color_component.createObject( tools, {"color": "#333333"} )
            color_component.createObject( tools, {"color": "dodgerblue"} )
            color_component.createObject( tools, {"color": "gold"} )
            color_component.createObject( tools, {"color": "purple"} )
            color_component.createObject( tools, {"color": "darkgreen"} )
        }
    }

    Component {
        id: color_component
        Item {
            width: 48*physicalPlatformScale
            height: width
            anchors.verticalCenter: parent.verticalCenter

            property alias color: rectangle.color

            Rectangle{
                id: rectangle
                anchors.fill: parent
                radius: width/2
                border.color: canvas.strokeColor==color? "#aaaaaa" : "#ffffff"
                border.width: 3*physicalPlatformScale
            }

            MouseArea{
                id: mousearea
                anchors.fill: parent
                onClicked: {
                    canvas.strokeColor = rectangle.color
                }
            }
        }
    }
}
