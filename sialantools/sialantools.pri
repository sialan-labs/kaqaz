
QT += qml quick

android {
    manifest.source = android-build
    manifest.target = .
    COPYFOLDERS += manifest
    include(qmake/copyData.pri)
    copyData()

    QT += androidextras
    SOURCES += \
        sialantools/sialanjavalayer.cpp

    HEADERS += \
        sialantools/sialanjavalayer.h
} else {
ios {
} else {
    QT += widgets

    HEADERS += \
        sialantools/sialanmimeapps.h \
        sialantools/qtsingleapplication/qtsinglecoreapplication.h \
        sialantools/qtsingleapplication/qtsingleapplication.h \
        sialantools/qtsingleapplication/qtlockedfile.h \
        sialantools/qtsingleapplication/qtlocalpeer.h

    SOURCES += \
        sialantools/sialanmimeapps.cpp \
        sialantools/qtsingleapplication/qtsinglecoreapplication.cpp \
        sialantools/qtsingleapplication/qtsingleapplication.cpp \
        sialantools/qtsingleapplication/qtlockedfile.cpp \
        sialantools/qtsingleapplication/qtlocalpeer.cpp

    win32: SOURCES += sialantools/qtsingleapplication/qtlockedfile_win.cpp
    unix:  SOURCES += sialantools/qtsingleapplication/qtlockedfile_unix.cpp
}
}

QML_IMPORT_PATH = \
    sialantools/qml/

SOURCES += \
    sialantools/sialandevices.cpp \
    sialantools/sialanqtlogger.cpp \
    sialantools/sialantools.cpp \
    sialantools/sialandesktoptools.cpp \
    sialantools/sialanlistobject.cpp \
    sialantools/sialanhashobject.cpp \
    sialantools/sialanquickview.cpp \
    sialantools/sialanapplication.cpp \
    sialantools/sialancalendarconvertercore.cpp \
    sialantools/sialancalendarconverter.cpp

HEADERS += \
    sialantools/sialandevices.h \
    sialantools/sialanqtlogger.h \
    sialantools/sialantools.h \
    sialantools/sialandesktoptools.h \
    sialantools/sialanlistobject.h \
    sialantools/sialanhashobject.h \
    sialantools/sialanquickview.h \
    sialantools/sialanapplication.h \
    sialantools/sialan_macros.h \
    sialantools/sialancalendarconvertercore.h \
    sialantools/sialancalendarconverter.h

OTHER_FILES += \
    sialantools/android-build/src/org/sialan/android/SialanActivity.java \
    sialantools/android-build/src/org/sialan/android/SialanApplication.java \
    sialantools/android-build/src/org/sialan/android/SialanJavaLayer.java

RESOURCES += \
    sialantools/sialanresource.qrc

