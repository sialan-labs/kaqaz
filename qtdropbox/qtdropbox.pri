QT += network xml

INCLUDEPATH += $$PWD

SOURCES += \
    $$PWD/qdropbox.cpp \
    $$PWD/qdropboxjson.cpp \
    $$PWD/qdropboxaccount.cpp \
    $$PWD/qdropboxfile.cpp \
    $$PWD/qdropboxfileinfo.cpp

HEADERS += \
    $$PWD/qtdropbox_global.h \
    $$PWD/qdropbox.h \
    $$PWD/qdropboxjson.h \
    $$PWD/qdropboxaccount.h \
    $$PWD/qdropboxfile.h \
    $$PWD/qtdropbox.h \
    $$PWD/qdropboxfileinfo.h

CONFIG += network
