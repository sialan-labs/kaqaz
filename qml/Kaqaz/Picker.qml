import QtQuick 2.2

Canvas {
    id: picker
    width: 100
    height: 62

//    Behavior on x {
//        NumberAnimation { easing.type: Easing.OutCubic; duration: 50 }
//    }
//    Behavior on y {
//        NumberAnimation { easing.type: Easing.OutCubic; duration: 50 }
//    }

    onPaint: {
        var ctx = picker.getContext("2d");
        ctx.save();

        ctx.strokeStyle = "#000000";
        ctx.fillStyle = "#333333"
        ctx.lineWidth = 1*physicalPlatformScale
        ctx.beginPath();

        ctx.moveTo(width/2,0)
        ctx.lineTo(width,width/2)
        ctx.lineTo(width,height)
        ctx.lineTo(0,height)
        ctx.lineTo(0,width/2)
        ctx.lineTo(width/2,0)

        ctx.stroke()
        ctx.fill()
    }
}
