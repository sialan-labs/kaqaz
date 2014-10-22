import QtQuick 2.0
import Kaqaz 1.0

Item {
    id: msw
    width: 100
    height: 62

    property rect viewPort
    property point view
    property int zoom
    property bool scaleHelper
    property bool crosshairs

    property variant item

    onViewChanged: if(item) item.view = view
    onZoomChanged: if(item) item.zoom = zoom
    onScaleHelperChanged: if(item) item.scaleHelper = scaleHelper
    onCrosshairsChanged: if(item) item.crosshairs = crosshairs

    Component.onCompleted: {
        if( kaqaz.mapMode == Kaqaz.GoogleMap ) {
            item = google_map_compoennt.createObject(msw)
        } else if( kaqaz.mapMode == Kaqaz.OpenStreetMap ) {
            item = os_map_component.createObject(msw)
        }
    }

    Component {
        id: google_map_compoennt
        GoogleMapView {
            anchors.fill: parent

            onViewPortChanged: msw.viewPort = viewPort
            onViewChanged: msw.view = view
            onZoomChanged: msw.zoom = zoom
            onScaleHelperChanged: msw.scaleHelper = scaleHelper
            onCrosshairsChanged: msw.crosshairs = crosshairs
        }
    }

    Component {
        id: os_map_component
        OSMapView {
            anchors.fill: parent

            onViewPortChanged: msw.viewPort = viewPort
            onViewChanged: msw.view = view
            onZoomChanged: msw.zoom = zoom
            onScaleHelperChanged: msw.scaleHelper = scaleHelper
            onCrosshairsChanged: msw.crosshairs = crosshairs
        }
    }
}
