import QtQuick 2.0
import Kaqaz 1.0

Item {
    width: 100
    height: 62
    clip: true

    property alias viewPort: map_control.viewPort
    property alias view: map_control.view
    property alias zoom: map_control.zoom

    GoogleMapAdapter {
        id: osm_adapter
    }

    MapLayer {
        id: map_layer
        mapAdapter: osm_adapter.adapter
        layerName: "GoogleMap-Layer"
    }

    MapControl {
        id: map_control
        anchors.fill: parent
        anchors.margins: -4*physicalPlatformScale
        scaleHelper: false
        crosshairs: false
        visible: true
        Component.onCompleted: {
            var geo = positioning.position.coordinate
            addLayer(map_layer.layerObject)
            view = Qt.point(geo.longitude,geo.latitude)
            zoom = 15
        }
    }
}
