# Add more folders to ship with the application, here
folder_01.source = qml/Kaqaz
folder_01.target = qml
folder_02.source = translations
folder_02.target = files
folder_03.source = database
folder_03.target = .
DEPLOYMENTFOLDERS = folder_01 folder_02 folder_03

QT += sql multimedia

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
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
} else {
    QT += widgets

    HEADERS += \
        mimeapps.h \
        iconprovider.h \
        qtsingleapplication/qtsinglecoreapplication.h \
        qtsingleapplication/qtsingleapplication.h \
        qtsingleapplication/qtlockedfile.h \
        qtsingleapplication/qtlocalpeer.h

    SOURCES += \
        mimeapps.cpp \
        iconprovider.cpp \
        qtsingleapplication/qtsinglecoreapplication.cpp \
        qtsingleapplication/qtsingleapplication.cpp \
        qtsingleapplication/qtlockedfile.cpp \
        qtsingleapplication/qtlocalpeer.cpp

    win32: SOURCES += qtsingleapplication/qtlockedfile_win.cpp
    unix:  SOURCES += qtsingleapplication/qtlockedfile_unix.cpp
}
}

win32 {
    QT += winextras
    RC_FILE = kaqaz.rc
}

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
# CONFIG += mobility
# MOBILITY +=

# The .cpp file which was generated for your project. Feel free to hack it.
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
    smartiodboxsingle.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
include(qtdropbox/qtdropbox.pri)
include(sialantools/sialantools.pri)
qtcAddDeployment()

OTHER_FILES += \
    android/QtApplication.java \
    android/QtActivity.java \
    android/AndroidManifest.xml \
    android/KaqazJavaLayer.java \
    qml/Kaqaz/GroupChooser.qml \
    qml/Kaqaz/PointingDialog.qml \
    qml/Kaqaz/kaqaz.qml \
    qml/Kaqaz/AttachMenu.qml \
    qml/Kaqaz/AttachViewer.qml \
    qml/Kaqaz/ImageViewer.qml \
    qml/Kaqaz/MainItem.qml \
    qml/Kaqaz/Button.qml \
    qml/Kaqaz/Security.qml \
    qml/Kaqaz/Calendar.qml \
    qml/Kaqaz/LanguageSelector.qml \
    qml/Kaqaz/Tooltip.qml \
    qml/Kaqaz/GetPassDialog.qml \
    qml/Kaqaz/GroupSelector.qml \
    qml/Kaqaz/SlideMenu.qml \
    qml/Kaqaz/Helper.qml \
    qml/Kaqaz/About.qml \
    qml/Kaqaz/History.qml \
    qml/Kaqaz/Synchronization.qml \
    qml/Kaqaz/RestoreWait.qml \
    qml/Kaqaz/BackupWait.qml \
    qml/Kaqaz/SearchPanel.qml \
    qml/Kaqaz/RestoreDialog.qml \
    qml/Kaqaz/GroupManager.qml \
    qml/Kaqaz/LabelEditPanel.qml \
    qml/Kaqaz/PaperLabel.qml \
    qml/Kaqaz/SideBarList.qml \
    qml/Kaqaz/MusicDialog.qml \
    qml/Kaqaz/GalleryDialog.qml \
    qml/Kaqaz/DocumentDialog.qml \
    qml/Kaqaz/CameraDialog.qml \
    qml/Kaqaz/PaperStackSwitcher.qml \
    qml/Kaqaz/PaperItem.qml \
    qml/Kaqaz/PaperManagerItem.qml \
    qml/Kaqaz/UncompatibleVersion.qml \
    qml/Kaqaz/TextViewer.qml \
    qml/Kaqaz/SideBar.qml \
    qml/Kaqaz/ShadowRectangle.qml \
    qml/Kaqaz/RollerDialog.qml \
    qml/Kaqaz/ProgressBar.qml \
    qml/Kaqaz/ProfileSettings.qml \
    qml/Kaqaz/PreferenceDialog.qml \
    qml/Kaqaz/Preference.qml \
    qml/Kaqaz/PickerHandler.qml \
    qml/Kaqaz/Picker.qml \
    qml/Kaqaz/PdfViewer.qml \
    qml/Kaqaz/PaperStackSwitcherItem.qml \
    qml/Kaqaz/MusicViewer.qml \
    qml/Kaqaz/ImageSizeSelector.qml \
    qml/Kaqaz/GraphicTimerPoint.qml \
    qml/Kaqaz/GraphicTimer.qml \
    qml/Kaqaz/DistanceCounter.qml \
    qml/Kaqaz/DataMoveWait.qml \
    qml/Kaqaz/CursorPicker.qml \
    qml/Kaqaz/ColorList.qml \
    qml/Kaqaz/CameraItem.qml \
    qml/Kaqaz/BackupRestore.qml \
    qml/Kaqaz/AttachInsertDialog.qml \
    qml/Kaqaz/AnimationItem.qml \
    qml/Kaqaz/AddGroupDialog.qml \
    qml/Kaqaz/AbstractListItem.qml \
    qml/Kaqaz/AbstractList.qml \
    android-build/src/org/sialan/android/SialanActivity.java \
    android-build/src/org/sialan/android/SialanApplication.java \
    android-build/src/org/sialan/android/SialanJavaLayer.java \
    android/res/drawable/icon.png \
    android/res/drawable/logo.png \
    android/res/drawable-hdpi/icon.png \
    android/res/drawable-ldpi/icon.png \
    android/res/drawable-mdpi/icon.png \
    iOS/Info.plist \
    database.mwb \
    database.sql \
    database/database.sqlite \
    qml/Kaqaz/ModernProgressBar.qml \
    qml/Kaqaz/PaperList.qml \
    qml/Kaqaz/SplashMessagePage.qml

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
    smartiodboxsingle.h

RESOURCES +=
