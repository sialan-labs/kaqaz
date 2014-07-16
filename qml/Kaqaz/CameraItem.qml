import QtQuick 2.2
import QtMultimedia 5.0

Rectangle {
    id: camera_item
    width: 100
    height: 62
    color: "#000000"
    anchors.fill: parent

    Header {
        id: title
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        light: true
    }

    Camera {
        id: camera

        imageProcessing.whiteBalanceMode: CameraImageProcessing.WhiteBalanceFlash

        exposure {
            exposureCompensation: -1.0
            exposureMode: Camera.ExposurePortrait
        }

        flash.mode: Camera.FlashRedEyeReduction

        imageCapture {
            onImageSaved: {
                camera_item.destroy()
            }
        }
    }

    VideoOutput {
        source: camera
        anchors.fill: parent
//        rotation: 90
        focus : visible
    }

    Button {
        id: captureBtn
        height: 100*physicalPlatformScale
        width: height
        radius: height/2
        normalColor: "#33ffffff"
        icon: "files/camera.png"
        iconHeight: 60*physicalPlatformScale
        anchors.horizontalCenter: camera_item.horizontalCenter
        anchors.bottom: camera_item.bottom
        anchors.bottomMargin: 20*physicalPlatformScale
        onClicked: camera.imageCapture.captureToLocation( kaqaz.cameraLocation() + "/test.jpg" )
    }
}
