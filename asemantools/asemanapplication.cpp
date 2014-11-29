/*
    Copyright (C) 2014 Aseman
    http://aseman.co

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "asemanapplication.h"
#include "asemantools.h"

#include <QDir>
#include <QFont>
#include <QSettings>

static QSettings *app_global_settings = 0;

class AsemanApplicationPrivate
{
public:
    QString globalFontFamily;
    QString globalMonoFontFamily;
};

AsemanApplication *aseman_app_obj = 0;
AsemanApplication::AsemanApplication(int &argc, char **argv) :
    INHERIT_QAPP (argc,argv)
{
    p = new AsemanApplicationPrivate;
    p->globalFontFamily = "Droid Kaqaz Sans";
    p->globalMonoFontFamily = "Droid Sans Mono";

    aseman_app_obj = this;
}

QString AsemanApplication::homePath()
{
    QString result;

#ifdef Q_OS_ANDROID
    result = QDir::homePath();
#else
#ifdef Q_OS_IOS
    result = QDir::homePath();
#else
#ifdef Q_OS_WIN
    result = QDir::homePath() + "/AppData/Local/" + QCoreApplication::organizationName().toLower() + "/" + QCoreApplication::applicationName().toLower();
#else
#ifdef Q_OS_UBUNTUTOUCH
    result = QDir::homePath() + "/.config/" + QCoreApplication::organizationDomain().toLower();
#else
    result = QDir::homePath() + "/.config/" + QCoreApplication::organizationName().toLower() + "/" + QCoreApplication::applicationName().toLower();
#endif
#endif
#endif
#endif

    static bool firstTime = false;
    if( !firstTime )
    {
        if( !QFileInfo::exists(result) )
        {
#ifdef Q_OS_WIN
            AsemanTools::copyDirectory( QDir::homePath() + "/AppData/Local/sialan/kaqaz", result );
#else
#ifdef Q_OS_UBUNTUTOUCH
            AsemanTools::copyDirectory( QDir::homePath() + "/.config/org.sialan.kaqaz", result );
#else
            AsemanTools::copyDirectory( QDir::homePath() + "/.config/sialan/kaqaz", result );
#endif
#endif
        }
        firstTime = true;
    }

    return result;
}

QString AsemanApplication::appPath()
{
    return QCoreApplication::applicationDirPath();
}

QString AsemanApplication::logPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationName() + "/" + QCoreApplication::applicationName() + "/log";
#else
    return homePath()+"/log";
#endif
}

QString AsemanApplication::confsPath()
{
    return homePath() + "/config.ini";
}

QString AsemanApplication::tempPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationName() + "/" + QCoreApplication::applicationName() + "/temp";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/tmp/";
#else
    return QDir::tempPath();
#endif
#endif
}

QString AsemanApplication::backupsPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/" + QCoreApplication::organizationName() + "/" + QCoreApplication::applicationName() + "/backups";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/backups/";
#else
    return homePath() + "/backups";
#endif
#endif
}

QString AsemanApplication::cameraPath()
{
#ifdef Q_OS_ANDROID
    return "/sdcard/DCIM";
#else
#ifdef Q_OS_IOS
    return QDir::homePath() + "/camera/";
#else
    return QDir::homePath() + "/Pictures/Camera";
#endif
#endif
}

AsemanApplication *AsemanApplication::instance()
{
    return aseman_app_obj;
}

void AsemanApplication::setGlobalFontFamily(const QString &fontFamily)
{
    if( p->globalFontFamily == fontFamily )
        return;

    p->globalFontFamily = fontFamily;
    emit globalFontFamilyChanged();
}

QString AsemanApplication::globalFontFamily() const
{
    return p->globalFontFamily;
}

void AsemanApplication::setGlobalMonoFontFamily(const QString &fontFamily)
{
    if( p->globalMonoFontFamily == fontFamily )
        return;

    p->globalMonoFontFamily = fontFamily;
    emit globalMonoFontFamilyChanged();
}

QString AsemanApplication::globalMonoFontFamily() const
{
    return p->globalMonoFontFamily;
}

QSettings *AsemanApplication::settings()
{
    if( !app_global_settings )
    {
        QDir().mkpath(AsemanApplication::homePath());
        app_global_settings = new QSettings( AsemanApplication::homePath() + "/config.ini", QSettings::IniFormat );
    }

    return app_global_settings;
}

void AsemanApplication::refreshTranslations()
{
    emit languageUpdated();
}

void AsemanApplication::back()
{
    emit backRequest();
}

void AsemanApplication::setSetting(const QString &key, const QVariant &value)
{
    settings()->setValue(key, value);
}

QVariant AsemanApplication::readSetting(const QString &key, const QVariant &defaultValue)
{
    return settings()->value(key, defaultValue);
}

AsemanApplication::~AsemanApplication()
{
    aseman_app_obj = 0;
    delete p;
}
