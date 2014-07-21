/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    Kaqaz is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Kaqaz is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef KAQAZMACROS_H
#define KAQAZMACROS_H

#include <QtGlobal>
#include <QDir>

#define DATA_DB_CONNECTION "data_sqlite"

#define KAQAZ_VERSION "1.0.1"

#define DEMO_PAPERS_LIMIT 20
//#define TRIAL_BUILD
#define LANG_ON_STARTUP

#define LINUX_DEFAULT_DPI 96

#ifdef Q_OS_ANDROID
#define HOME_PATH   QDir::homePath()
#define BACKUP_PATH "/sdcard/Sialan/Kaqaz/backups"
#define TEMP_PATH   "/sdcard/Sialan/Kaqaz/temp"
#define CAMERA_PATH "/sdcard/DCIM"
#define LOG_PATH    "/sdcard/Sialan/Kaqaz/log"
#else
#ifdef Q_OS_IOS
#define HOME_PATH   QDir::homePath()
#define BACKUP_PATH QString(QDir::homePath() + "/backups/")
#define TEMP_PATH   QString(QDir::homePath() + "/tmp/")
#define CAMERA_PATH QString(QDir::homePath() + "/camera/")
#else
#ifdef Q_OS_WIN
#define HOME_PATH   QString(QDir::homePath() + "/AppData/Local/sialan/kaqaz")
#else
#define HOME_PATH   QString(QDir::homePath() + "/.config/sialan/kaqaz")
#endif
#define LOG_PATH    QString(HOME_PATH+"/log")
#define BACKUP_PATH QDir::homePath()
#define TEMP_PATH   QDir::tempPath()
#define CAMERA_PATH QString(QDir::homePath() + "/Pictures/Camera")
#endif
#endif
#define CONFIG_PATH QString(HOME_PATH + "/config.ini")

#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(Q_OS_WINPHONE)
#define TOUCH_DEVICE
#else
#define DESKTOP_DEVICE
#ifdef Q_OS_LINUX
#define DESKTOP_LINUX
#endif
#endif

#define DROPBOX_APP_KEY    "js992omoncolisd"
#define DROPBOX_APP_SECRET "csojevx79okw1dh"

#endif // KAQAZMACROS_H
