import QtQuick 2.0
import QtGraphicalEffects 1.0

FastBlur {
    width: source.width
    height: source.height
    radius: 32*physicalPlatformScale
    cached: true
}
