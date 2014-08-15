
android {
    manifest.source = android-build
    manifest.target = .
    COPYFOLDERS = manifest
    include(qmake/copyData.pri)
    copyData()

    QT += androidextras
    SOURCES += \
        sialantools/sialanjavalayer.cpp

    HEADERS += \
        sialantools/sialanjavalayer.h
}

SOURCES += \
    sialantools/sialandevices.cpp \
    sialantools/sialanqtlogger.cpp \
    sialantools/sialantools.cpp

HEADERS += \
    sialantools/sialandevices.h \
    sialantools/sialanqtlogger.h \
    sialantools/sialantools.h

