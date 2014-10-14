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

#include "sialantools/sialanapplication.h"

#define DATA_DB_CONNECTION "data_sqlite"

#define KAQAZ_VERSION "1.1.2"

#define DEMO_PAPERS_LIMIT 20

#define LANG_ON_STARTUP

#define HOME_PATH   SialanApplication::homePath()
#define BACKUP_PATH SialanApplication::backupsPath()
#define TEMP_PATH   SialanApplication::tempPath()
#define CAMERA_PATH SialanApplication::cameraPath()
#define LOG_PATH    SialanApplication::logPath()
#define CONFIG_PATH SialanApplication::confsPath()

#define DROPBOX_APP_KEY    "js992omoncolisd"
#define DROPBOX_APP_SECRET "csojevx79okw1dh"

#endif // KAQAZMACROS_H
