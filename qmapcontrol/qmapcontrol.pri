QT += network gui

HEADERS += qmapcontrol/curve.h \
           qmapcontrol/geometry.h \
           qmapcontrol/imagemanager.h \
           qmapcontrol/layer.h \
           qmapcontrol/layermanager.h \
           qmapcontrol/linestring.h \
           qmapcontrol/mapadapter.h \
           qmapcontrol/mapnetwork.h \
           qmapcontrol/point.h \
           qmapcontrol/tilemapadapter.h \
           qmapcontrol/wmsmapadapter.h \
           qmapcontrol/circlepoint.h \
           qmapcontrol/imagepoint.h \
           qmapcontrol/gps_position.h \
           qmapcontrol/osmmapadapter.h \
           qmapcontrol/maplayer.h \
           qmapcontrol/geometrylayer.h \
           qmapcontrol/yahoomapadapter.h \
           qmapcontrol/googlemapadapter.h \
           qmapcontrol/openaerialmapadapter.h \
           qmapcontrol/fixedimageoverlay.h \
           qmapcontrol/emptymapadapter.h \
           qmapcontrol/arrowpoint.h \
           qmapcontrol/qmapcontrol_global.h \
    $$PWD/qmlmapcontrol.h \
    $$PWD/abstractmapcontrol.h

SOURCES += qmapcontrol/curve.cpp \
           qmapcontrol/geometry.cpp \
           qmapcontrol/imagemanager.cpp \
           qmapcontrol/layer.cpp \
           qmapcontrol/layermanager.cpp \
           qmapcontrol/linestring.cpp \
           qmapcontrol/mapadapter.cpp \
           qmapcontrol/mapnetwork.cpp \
           qmapcontrol/point.cpp \
           qmapcontrol/tilemapadapter.cpp \
           qmapcontrol/wmsmapadapter.cpp \
           qmapcontrol/circlepoint.cpp \
           qmapcontrol/imagepoint.cpp \
           qmapcontrol/gps_position.cpp \
           qmapcontrol/osmmapadapter.cpp \
           qmapcontrol/maplayer.cpp \
           qmapcontrol/geometrylayer.cpp \
           qmapcontrol/yahoomapadapter.cpp \
           qmapcontrol/googlemapadapter.cpp \
           qmapcontrol/openaerialmapadapter.cpp \
           qmapcontrol/fixedimageoverlay.cpp \
           qmapcontrol/arrowpoint.cpp \
           qmapcontrol/emptymapadapter.cpp \
    $$PWD/qmlmapcontrol.cpp
