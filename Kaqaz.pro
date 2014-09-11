folder_01.source = files/fonts
folder_01.target = .
folder_02.source = files/translations
folder_02.target = files
folder_03.source = files/FaenzaFlattr
folder_03.target = files/icons/
DEPLOYMENTFOLDERS = folder_01 folder_02 folder_03

QT += sql multimedia positioning qml quick

contains(BUILD_TYPE,free) {
    DEFINES += FREE_BUILD
}
contains(BUILD_TYPE,trial) {
    DEFINES += FREE_BUILD
    DEFINES += TRIAL_BUILD
}

ios {
    QTPLUGIN += qsqlite
    QMAKE_INFO_PLIST = iOS/info.plist

    folder_03.source = iOS/icons
    folder_03.target = files
    folder_04.source = iOS/splash/Default-568h@2x.png
    folder_04.target = .
    DEPLOYMENTFOLDERS += folder_03 folder_04
} else {
android {
    contains(DEFINES,FREE_BUILD) {
        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android/free
    } else {
        ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android/pro
    }
} else {
    QT += widgets network

    HEADERS += \
        mimeapps.h \
        iconprovider.h \
        qtsingleapplication/qtsinglecoreapplication.h \
        qtsingleapplication/qtsingleapplication.h \
        qtsingleapplication/qtlockedfile.h \
        qtsingleapplication/qtlocalpeer.h \
        desktop/kaqazdesktop.h \
        desktop/categoriesmodel.h \
        desktop/panelbox.h \
        desktop/datesmodel.h \
        desktop/papersview.h \
        desktop/paperviewdelegate.h \
        desktop/papersmodel.h \
        desktop/editorview.h \
        desktop/editorviewmanager.h \
        desktop/searchpanel.h \
        desktop/groupbutton.h \
        desktop/addgroupdialog.h \
        desktop/paperconfigure.h \
        desktop/mapwidget.h \
        desktop/datewidget.h \
        desktop/configurepage.h \
        desktop/aboutdialog.h \
        desktop/simage.h \
        desktop/paperfilesview.h \
        desktop/paperfilesmodel.h \
        desktop/todopapers.h \
        desktop/scolor.h

    SOURCES += \
        mimeapps.cpp \
        iconprovider.cpp \
        qtsingleapplication/qtsinglecoreapplication.cpp \
        qtsingleapplication/qtsingleapplication.cpp \
        qtsingleapplication/qtlockedfile.cpp \
        qtsingleapplication/qtlocalpeer.cpp \
        desktop/kaqazdesktop.cpp \
        desktop/categoriesmodel.cpp \
        desktop/panelbox.cpp \
        desktop/datesmodel.cpp \
        desktop/papersview.cpp \
        desktop/paperviewdelegate.cpp \
        desktop/papersmodel.cpp \
        desktop/editorview.cpp \
        desktop/editorviewmanager.cpp \
        desktop/searchpanel.cpp \
        desktop/groupbutton.cpp \
        desktop/addgroupdialog.cpp \
        desktop/paperconfigure.cpp \
        desktop/mapwidget.cpp \
        desktop/datewidget.cpp \
        desktop/configurepage.cpp \
        desktop/aboutdialog.cpp \
        desktop/simage.cpp \
        desktop/paperfilesview.cpp \
        desktop/paperfilesmodel.cpp \
        desktop/todopapers.cpp \
        desktop/scolor.cpp

    FORMS += \
        desktop/paperconfigure.ui \
        desktop/configurepage.ui \
        desktop/aboutdialog.ui

    win32: SOURCES += qtsingleapplication/qtlockedfile_win.cpp
    unix:  SOURCES += qtsingleapplication/qtlockedfile_unix.cpp
}
}

win32 {
    QT += winextras
    RC_FILE = files/kaqaz.rc
}

SOURCES += main.cpp \
    kaqaz.cpp \
    papermanager.cpp \
    calendarconverter.cpp \
    repository.cpp \
    resourcemanager.cpp \
    kaqazsync.cpp \
    SimpleQtCryptor/simpleqtcryptor.cpp \
    backuper.cpp \
    database.cpp \
    kaqazdropbox.cpp \
    smartiodbox.cpp \
    smartiodboxsingle.cpp \
    searchhighlighter.cpp \
    databasedatatypes.cpp

HEADERS += \
    kaqaz.h \
    papermanager.h \
    calendarconverter.h \
    repository.h \
    resourcemanager.h \
    kaqazsync.h \
    SimpleQtCryptor/serpent_sbox.h \
    SimpleQtCryptor/simpleqtcryptor.h \
    backuper.h \
    kaqazmacros.h \
    database.h \
    databasedatatypes.h \
    kaqazdropbox.h \
    sialandeveloper_macros.h \
    smartiodbox.h \
    smartiodboxsingle.h \
    searchhighlighter.h

TRANSLATIONS += \
    files/translations/lang-en.qm \
    files/translations/lang-fa.qm

FONTS += \
    files/fonts/DroidKaqazSans.ttf \
    files/fonts/DroidSansMono.ttf

OTHER_FILES += \
    android/pro/AndroidManifest.xml \
    android/free/AndroidManifest.xml \
    android-build/src/org/sialan/android/SialanActivity.java \
    android-build/src/org/sialan/android/SialanApplication.java \
    android-build/src/org/sialan/android/SialanJavaLayer.java \
    iOS/Info.plist \
    files/database/database.sqlite

RESOURCES += \
    resource.qrc

include(qmake/qtcAddDeployment.pri)
include(qtdropbox/qtdropbox.pri)
include(sialantools/sialantools.pri)
qtcAddDeployment()

isEmpty(PREFIX) {
    PREFIX = /usr
}

android {
} else {
linux {
    target = $$TARGET
    target.path = $$PREFIX/bin
    translations.files = $$TRANSLATIONS
    translations.path = $$PREFIX/share/kaqaz/files/translations
    fonts.files = $$FONTS
    fonts.path = $$PREFIX/share/kaqaz/fonts/
    icons.files = files/icons/kaqaz.png
    icons.path = $$PREFIX/share/kaqaz/icons/
    faenza.files = files/FaenzaFlattr
    faenza.path = $$PREFIX/share/kaqaz/files/icons/
    desktopFile.files = files/shortcuts/Kaqaz.desktop
    desktopFile.path = $$PREFIX/share/applications
    desktopTouchFile.files = files/shortcuts/Kaqaz-touch.desktop
    desktopTouchFile.path = $$PREFIX/share/applications

    INSTALLS = target fonts translations icons desktopFile desktopTouchFile faenza
}
}
