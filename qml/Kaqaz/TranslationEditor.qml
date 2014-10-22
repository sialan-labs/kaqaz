import QtQuick 2.0
import Kaqaz 1.0

Item {
    width: 100
    height: 62

    ListView {
        id: tr_view
        anchors.fill: parent
        model: TranslationModel {
            file: "/home/bardia/Projects/Kaqaz/translations_sources/lang-fa.ts"
        }

        delegate: Column {
            id: item
            width: tr_view.width
            spacing: 10*physicalPlatformScale

            Text {
                width: item.width
                text: originalText
            }

            Text {
                width: item.width
                text: translation
            }
        }
    }
}
