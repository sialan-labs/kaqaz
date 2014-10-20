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
            smooth: true

            property bool newLine: false
            property bool endLine: false
            property bool start: false

            property color strokeColor: "black"
            property real strokeWidth: 1
            property int penMode: 0

            onPaint: {
                var ctx = canvas.getContext("2d");
                if( !start ) {
                    ctx.fillStyle = paper_back.color
                    ctx.fillRect(0,0,width,height)
                    start = true
                    return
                }

                ctx.strokeStyle = penMode==2? paper_back.color : strokeColor
                ctx.lineWidth = penMode==2? 20*physicalPlatformScale : strokeWidth*physicalPlatformScale

                while( !list.isEmpty() ) {
                    var item = list.takeFirst()
                    ctx.beginPath()
                    ctx.moveTo(item.x0,item.y0)
                    ctx.lineTo(item.x1,item.y1)
                    ctx.stroke()
                    newLine = false
                }
            }

            Component.onCompleted: requestPaint()
        }

        MultiPointTouchArea {
            id: tarea
            anchors.fill: parent
            minimumTouchPoints: 1
            maximumTouchPoints: 2
            touchPoints: [
                TouchPoint {
                    id: point1
                    onPressedChanged: if( !point2.pressed ) updatePos(-1,-1)
                },
                TouchPoint {
                    id: point2
                    onXChanged: tarea.calculateMagSize()
                    onYChanged: tarea.calculateMagSize()
                    onPressedChanged: updatePos(-1,-1)
                }
            ]

            function calculateMagSize() {
                if( !point1.pressed || !point2.pressed )
                    return

                var w = Math.pow( Math.pow(point1.x-point2.x,2)+Math.pow(point1.y-point2.y,2), 0.5 )
                var x = point1.x<point2.x? point1.x : point2.x
                var y = (point1.y<point2.y? point1.y : point2.y)

                mag.x = x - (w - Math.abs(point1.x-point2.x))/2
                mag.y = y - (w - Math.abs(point1.y-point2.y))/2
                mag.width = w
            }

            KaqazTouchPointHandler {
                id: handler1
                touchPoint: point1
                onPositionChanged: {
                    if( point2.pressed )
                        return

                    if( !mag.visible )
                        updatePos(x,y)

                    tarea.calculateMagSize()
                }
            }
        }

        KaqazCanvasMaginifier {
            id: mag
            source: canvas
            width: 0
            onPositionChanged: updatePos(mouseX,mouseY)
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

        Button {
            width: 40*physicalPlatformScale
            height: width
            anchors.verticalCenter: parent.verticalCenter
            icon: "files/pen-color.png"
            iconHeight: 24*physicalPlatformScale
            border.color: canvas.strokeColor
            border.width: 1*physicalPlatformScale
            normalColor: "#44ffffff"
            onClicked: {
                var pos = mapToItem(kaqaz_root,0,0)
                showPointDialog( color_component.createObject(tools), pos.x - width, pos.y, 250*physicalPlatformScale, 300*physicalPlatformScale )
            }
        }

        Button {
            width: 40*physicalPlatformScale
            height: width
            anchors.verticalCenter: parent.verticalCenter
            icon: "files/pen-width.png"
            iconHeight: 24*physicalPlatformScale
            normalColor: "#44ffffff"
            onClicked: {
                var pos = mapToItem(kaqaz_root,0,0)
                showPointDialog( pen_width_component.createObject(tools), pos.x - width, pos.y, 250*physicalPlatformScale, 300*physicalPlatformScale )
            }
        }

        Button {
            width: 40*physicalPlatformScale
            height: width
            anchors.verticalCenter: parent.verticalCenter
            normalColor: "#44ffffff"
            icon: "files/pen-mode.png"
            iconHeight: 24*physicalPlatformScale
            onClicked: {
                var pos = mapToItem(kaqaz_root,0,0)
                showPointDialog( pen_mode_component.createObject(tools), pos.x - width, pos.y, 250*physicalPlatformScale, 200*physicalPlatformScale )
            }
        }

        Button {
            width: 40*physicalPlatformScale
            height: width
            anchors.verticalCenter: parent.verticalCenter
            normalColor: "#44ffffff"
            icon: "files/pen-magnifier.png"
            iconHeight: 24*physicalPlatformScale
            onClicked: {
                var pos = mapToItem(kaqaz_root,0,0)
                showPointDialog( mag_level_component.createObject(tools), pos.x - width, pos.y, 250*physicalPlatformScale, 200*physicalPlatformScale )
            }
        }
    }

    Component {
        id: color_component
        KaqazCanvasColorList {
            selectedColor: canvas.strokeColor
            onSelectedColorChanged: canvas.strokeColor = selectedColor
        }
    }

    Component {
        id: pen_width_component
        KaqazCanvasPenWidth {
            selectedPen: canvas.strokeWidth
            onSelectedPenChanged: canvas.strokeWidth = selectedPen
        }
    }

    Component {
        id: pen_mode_component
        KaqazCanvasPenMode {
            selectedMode: canvas.penMode
            onSelectedModeChanged: canvas.penMode = selectedMode
        }
    }

    Component {
        id: mag_level_component
        KaqazCanvasMagnifierLevel {
            selectedLevel: mag.magScale
            onSelectedLevelChanged: mag.magScale = selectedLevel
        }
    }

    property real startX: -1
    property real startY: -1
    function updatePos( mX, mY ) {
        if( mX == -1 && mY == -1 ) {
            startX = -1
            startY = -1
            return
        }
        if( startX == -1 || startY == -1 ) {
            startX = mX
            startY = mY
        } else {
            list.append(  {"x0":startX,"y0":startY,"x1":mX,"y1":mY} )
            if( canvas.penMode != 1 ) {
                startX = mX
                startY = mY
            }

            canvas.requestPaint()
        }
    }
}
