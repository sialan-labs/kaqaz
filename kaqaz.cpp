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

#define UNGROUPEDS_NODE "UNGROUPED"
#define TODAY_NODE      "TODAY"
#define GENERAL_NODE    "GENERAL"
#define ACTIVITY_NODE   "DEFAULT_ACTIVITY"

#include "kaqaz.h"
#include "papermanager.h"
#include "repository.h"
#include "kaqazsync.h"
#include "kaqazmacros.h"
#include "database.h"
#include "backuper.h"
#include "sialantools/sialanqtlogger.h"
#include "sialantools/sialantools.h"
#include "calendarconverter.h"
#include "resourcemanager.h"
#include "qtquick2applicationviewer/qtquick2applicationviewer.h"
#include "SimpleQtCryptor/simpleqtcryptor.h"
#include "sialantools/sialandevices.h"

#ifdef Q_OS_ANDROID
#include "sialantools/sialanjavalayer.h"
#endif

#ifdef DESKTOP_LINUX
#include "mimeapps.h"
#include "iconprovider.h"
#endif

#ifdef DESKTOP_DEVICE
#include <QFileDialog>
#endif

#include <QGuiApplication>
#include <QClipboard>
#include <QTranslator>
#include <QQmlEngine>
#include <QQmlContext>
#include <QtQml>
#include <QDir>
#include <QDebug>
#include <QColor>
#include <QUuid>
#include <QHash>
#include <QScreen>
#include <QMimeDatabase>
#include <QDateTime>
#include <QFileInfo>
#include <QTimerEvent>
#include <QHash>
#include <QPalette>
#include <QSettings>
#include <QUrl>
#include <QDesktopServices>
#include <QProcess>
#include <QCryptographicHash>
#include <QFileSystemWatcher>
#include <QStandardPaths>

QString translate_0 = "0";
QString translate_1 = "1";
QString translate_2 = "2";
QString translate_3 = "3";
QString translate_4 = "4";
QString translate_5 = "5";
QString translate_6 = "6";
QString translate_7 = "7";
QString translate_8 = "8";
QString translate_9 = "9";

QString translateNumbers( QString input )
{
    input.replace("0",translate_0);
    input.replace("1",translate_1);
    input.replace("2",translate_2);
    input.replace("3",translate_3);
    input.replace("4",translate_4);
    input.replace("5",translate_5);
    input.replace("6",translate_6);
    input.replace("7",translate_7);
    input.replace("8",translate_8);
    input.replace("9",translate_9);
    return input;
}

Database *kaqaz_database = 0;
QSettings *kaqaz_settings = 0;

class KaqazPrivate
{
public:
    QtQuick2ApplicationViewer *viewer;

    QString homePath;
    QString translationsPath;
    QString confPath;
    QString profilePath;

    int lock_timer;
    bool close_blocker;
    bool keyboard;

    bool demo_active_until_next;

    QTranslator *translator;
    KaqazSync *sync;

    QHash<QString,QVariant> languages;
    QHash<QString,QLocale> locales;
    QString language;

    CalendarConverter *calendar;
    Repository *repository;
    Backuper *backuper;

#ifdef DESKTOP_LINUX
    MimeApps *mimeApps;
#endif

    QFileSystemWatcher *filesystem;
    QMimeDatabase mime_db;

    SialanDevices *devices;
    SialanTools *tools;

#ifdef Q_OS_ANDROID
    SialanQtLogger *logger;
    SialanJavaLayer *java_layer;
#endif
};

Kaqaz::Kaqaz(QObject *parent) :
    QObject(parent)
{
    p = new KaqazPrivate;
    p->demo_active_until_next = false;
    p->lock_timer = 0;
    p->keyboard = false;
    p->translator = new QTranslator(this);
    p->calendar = new CalendarConverter();
    p->backuper = new Backuper(this);
    p->devices = new SialanDevices(this);
    p->tools = new SialanTools(this);
#ifdef Q_OS_ANDROID
    p->logger = new SialanQtLogger(LOG_PATH,this);
    p->java_layer = SialanJavaLayer::instance();
#endif

#ifdef DESKTOP_LINUX
    p->mimeApps = new MimeApps(this);
    QIcon::setThemeName("FaenzaFlattr");
#endif
    QDir().mkpath(CAMERA_PATH);

    p->filesystem = new QFileSystemWatcher(this);
    p->filesystem->addPath(CAMERA_PATH);

    const QStringList & camera_entryes = QDir(CAMERA_PATH).entryList(QDir::Dirs | QDir::NoDotAndDotDot);
    foreach( const QString & d, camera_entryes )
        p->filesystem->addPath( QString(CAMERA_PATH) + "/" + d );

    QDir().mkpath(TEMP_PATH);
    cleanCache();

#ifdef Q_OS_ANDROID
    p->close_blocker = true;
#else
    p->close_blocker = false;
#endif

    p->homePath = HOME_PATH;
#ifdef Q_OS_ANDROID
    p->translationsPath = "assets:/files/translations";
    p->confPath = p->homePath + "/config.ini";
#else
#ifdef Q_OS_MAC
    p->translationsPath = QCoreApplication::applicationDirPath() + "/../Resources/files/translations/";
    p->confPath = p->homePath + "/config.ini";
#else
    p->translationsPath = QCoreApplication::applicationDirPath() + "/files/translations/";
    p->confPath = p->homePath + "/config.ini";
#endif
#endif

    if( !kaqaz_settings )
        kaqaz_settings = new QSettings( p->confPath, QSettings::IniFormat );

    p->profilePath = kaqaz_settings->value( "General/ProfilePath", p->homePath ).toString();

    QDir().mkpath(p->homePath);
    QDir().mkpath(profilePath());
    QDir().mkpath(repositoryPath());

    p->repository = new Repository(this);

    p->calendar->setCalendar( static_cast<CalendarConverter::CalendarTypes>(kaqaz_settings->value("General/Calendar",CalendarConverter::Gregorian).toInt()) );

    if( !kaqaz_database )
        kaqaz_database = new Database(profilePath() + "/database.sqlite");

    p->sync = new KaqazSync(kaqaz_database,this);

    init_languages();

    qmlRegisterType<PaperManager>("Kaqaz", 1,0, "PaperManager");

    p->viewer = new QtQuick2ApplicationViewer();
    p->viewer->installEventFilter(this);
    p->viewer->engine()->rootContext()->setContextProperty( "kaqaz", this );
    p->viewer->engine()->rootContext()->setContextProperty( "view", p->viewer );
    p->viewer->engine()->rootContext()->setContextProperty( "database", kaqaz_database );
    p->viewer->engine()->rootContext()->setContextProperty( "filesystem", p->filesystem );
    p->viewer->engine()->rootContext()->setContextProperty( "repository", p->repository );
    p->viewer->engine()->rootContext()->setContextProperty( "backuper", p->backuper );
    p->viewer->engine()->rootContext()->setContextProperty( "sync", p->sync );
    p->viewer->engine()->rootContext()->setContextProperty( "devices", p->devices );
    p->viewer->engine()->rootContext()->setContextProperty( "tools", p->tools );
#ifdef DESKTOP_LINUX
    p->viewer->engine()->rootContext()->setContextProperty( "mimeApps", p->mimeApps );
    p->viewer->engine()->addImageProvider( "icon", new IconProvider() );
#endif
    p->viewer->engine()->rootContext()->setContextProperty( "keyboard", QGuiApplication::inputMethod() );
    if( !QGuiApplication::screens().isEmpty() )
        p->viewer->engine()->rootContext()->setContextProperty( "screen", QGuiApplication::screens().first() );

    connect( kaqaz_database, SIGNAL(fileDeleted(QString)), p->repository, SLOT(deleteFile(QString)) );

    connect( p->devices, SIGNAL(incomingImage(QString)), SLOT(incomingImage(QString)) );
    connect( p->devices, SIGNAL(incomingShare(QString,QString)), SLOT(incomingShare(QString,QString)) );
    connect( p->devices, SIGNAL(selectImageResult(QString)), SLOT(selectImageResult(QString)) );
    connect( p->devices, SIGNAL(activityPaused()), SLOT(activityPaused()) );
    connect( p->devices, SIGNAL(activityResumed()), SLOT(activityResumed()) );
}

void Kaqaz::init_languages()
{
    QDir dir(p->translationsPath);
    QStringList languages = dir.entryList( QDir::Files );
    if( !languages.contains("lang-en.qm") )
        languages.prepend("lang-en.qm");

    for( int i=0 ; i<languages.size() ; i++ )
     {
         QString locale_str = languages[i];
             locale_str.truncate( locale_str.lastIndexOf('.') );
             locale_str.remove( 0, locale_str.indexOf('-') + 1 );

         QLocale locale(locale_str);

         QString  lang = QLocale::languageToString(locale.language());
         QVariant data = p->translationsPath + "/" + languages[i];

         p->languages.insert( lang, data );
         p->locales.insert( lang , locale );

         if( lang == kaqaz_settings->value("General/Language","English").toString() )
             setCurrentLanguage( lang );
    }
}

void Kaqaz::start()
{
    p->viewer->setMainQmlFile(QStringLiteral("qml/Kaqaz/kaqaz.qml"));
    p->viewer->showExpanded();
}

void Kaqaz::incomingAppMessage(const QString &msg)
{
    if( msg == "show" )
    {
        p->viewer->show();
        p->viewer->requestActivate();
    }
}

void Kaqaz::incomingShare(const QString &title, const QString &msg)
{
    QVariant title_var = title;
    QVariant msg_var = msg;

    QMetaObject::invokeMethod( p->viewer->rootObject(), "incomingShare", Q_ARG(QVariant,title_var), Q_ARG(QVariant,msg_var) );
}

void Kaqaz::incomingImage(const QString &path)
{
    QVariant path_var = path;
    QMetaObject::invokeMethod( p->viewer->rootObject(), "incomingImage", Q_ARG(QVariant,path_var) );
}

void Kaqaz::selectImageResult(const QString &path)
{
    qDebug() << "selectImageResult" << path;
}

void Kaqaz::activityPaused()
{
    if( p->lock_timer )
        killTimer( p->lock_timer );

    p->lock_timer = startTimer( 30000 );
}

void Kaqaz::activityResumed()
{
    if( !p->lock_timer )
        return;

    killTimer( p->lock_timer );
    p->lock_timer = 0;
}

bool Kaqaz::demoHasTrial() const
{
#ifndef TRIAL_BUILD
    return true;
#endif

    if( p->demo_active_until_next )
        return true;
    if( DEMO_PAPERS_LIMIT >= database()->statePapersCount() )
        return true;

    return false;
}

void Kaqaz::demoActiveTrial() const
{
    p->demo_active_until_next = true;
}

bool Kaqaz::proBuild() const
{
#ifdef PRO_BUILD
    return true;
#else
    return false;
#endif
}

QString Kaqaz::version() const
{
    return KAQAZ_VERSION
#ifdef PRO_BUILD
            " pro";
#else
#ifdef TRIAL_BUILD
            " trial";
#else
            " free";
#endif
#endif
}

QString Kaqaz::qtVersion() const
{
    return qVersion();
}

QString Kaqaz::aboutSialan() const
{
    return tr("Sialan Labs is a not-for-profit research and software development team launched in February 2014 focusing on development of products, technologies and solutions in order to publish them as open-source projects accessible to all people in the universe. Currently, we are focusing on design and development of software applications and tools which have direct connection with end users.") + "\n\n" +
           tr("By enabling innovative projects and distributing software to millions of users globally, the lab is working to accelerate the growth of high-impact open source software projects and promote an open source culture of accessibility and increased productivity around the world. The lab partners with industry leaders and policy makers to bring open source technologies to new sectors, including education, health and government.");
}

void Kaqaz::deleteFileIfPossible(const QString &id)
{
    if( kaqaz_database->fileContaintOnDatabase(id) )
        return;

    const QString & path = p->repository->getPath(id);
    QFile::remove(path);
}

void Kaqaz::removeFile(const QString &path)
{
    QFile::remove(path);
}

void Kaqaz::setCalendar(int t)
{
    p->calendar->setCalendar( static_cast<CalendarConverter::CalendarTypes>(t) );
    kaqaz_settings->setValue( "General/Calendar", t );
    emit calendarChanged();
}

QStringList Kaqaz::calendarsID() const
{
    QStringList res;
    res << QString::number(CalendarConverter::Gregorian);
    res << QString::number(CalendarConverter::Jalali);
//    res << QString::number(CalendarConverter::Hijri);
    return res;
}

QString Kaqaz::calendarName(int t)
{
    switch( t )
    {
    case CalendarConverter::Gregorian:
        return tr("Gregorian");
        break;
    case CalendarConverter::Jalali:
        return tr("Jalali");
        break;
    case CalendarConverter::Hijri:
        return tr("Hijri");
        break;
    }

    return QString();
}

int Kaqaz::currentDays()
{
    return QDate(1,1,1).daysTo(QDate::currentDate());
}

QString Kaqaz::convertIntToStringDate(qint64 d)
{
    return convertIntToStringDate(d,"ddd MMM dd yy");
}

QString Kaqaz::convertIntToFullStringDate(qint64 d)
{
    return convertIntToStringDate(d,"ddd MMM dd yyyy");
}

QString Kaqaz::convertIntToNumStringDate(qint64 d)
{
    QDate date = QDate(1,1,1);
    date = date.addDays(d);
    return translateNumbers( p->calendar->numberString(date) );
}

QString Kaqaz::translateInt(qint64 d)
{
    return translateNumbers(QString::number(d));
}

QString Kaqaz::convertIntToStringDate(qint64 d, const QString &format)
{
    Q_UNUSED(format)
    QDate date = QDate(1,1,1);
    date = date.addDays(d);
    return translateNumbers( p->calendar->historyString(date) );
}

void Kaqaz::close()
{
    p->close_blocker = false;
    p->viewer->close();
}

void Kaqaz::minimize()
{
    p->viewer->showMinimized();
}

Database *Kaqaz::database()
{
    return kaqaz_database;
}

QSettings *Kaqaz::settings()
{
    return kaqaz_settings;
}

QScreen *Kaqaz::screen()
{
    const QList<QScreen*> & screens = QGuiApplication::screens();
    if( screens.isEmpty() )
        return 0;

    return screens.first();
}

QObject *Kaqaz::screenObj()
{
    return screen();
}

void Kaqaz::refreshSettings()
{
    if( kaqaz_settings )
        delete kaqaz_settings;

    kaqaz_settings = new QSettings( p->confPath, QSettings::IniFormat );
}

void Kaqaz::setClipboard(const QString &text)
{
    QGuiApplication::clipboard()->setText( text );
}

QString Kaqaz::clipboard() const
{
    return QGuiApplication::clipboard()->text();
}

QStringList Kaqaz::languages()
{
    QStringList res = p->languages.keys();
    res.sort();
    return res;
}

void Kaqaz::setCurrentLanguage(const QString &lang)
{
    if( p->language == lang )
        return;

    QGuiApplication::removeTranslator(p->translator);
    p->translator->load(p->languages.value(lang).toString(),"languages");
    QGuiApplication::installTranslator(p->translator);
    p->language = lang;

    kaqaz_settings->setValue("General/Language",lang);

    translate_0 = Kaqaz::tr("0");
    translate_1 = Kaqaz::tr("1");
    translate_2 = Kaqaz::tr("2");
    translate_3 = Kaqaz::tr("3");
    translate_4 = Kaqaz::tr("4");
    translate_5 = Kaqaz::tr("5");
    translate_6 = Kaqaz::tr("6");
    translate_7 = Kaqaz::tr("7");
    translate_8 = Kaqaz::tr("8");
    translate_9 = Kaqaz::tr("9");

    emit languageChanged();
    emit languageDirectionChanged();
}

QString Kaqaz::currentLanguage() const
{
    return p->language;
}

void Kaqaz::shareToFile(const QString &subject, const QString &message, const QString &path)
{
    if( QFile::exists(path) )
        QFile::remove(path);

    QFile file(path);
    if( !file.open(QFile::WriteOnly) )
        return;

    QString output = subject + "\n=-=-=-=-=-=-\n\n" + message;

    file.write(output.toUtf8());
    file.close();
}

QString Kaqaz::cacheFile(const QString &address)
{
    QDir().mkpath(TEMP_PATH);
    QFileInfo file(address);
    QString dest = QString(TEMP_PATH) + "/kaqaz_open_tmp." + file.suffix().toLower();
    QFile::remove(dest);
    QFile::copy(address,dest);
    return dest;
}

void Kaqaz::cleanCache()
{
#ifdef Q_OS_ANDROID
    const QStringList & l = QDir(TEMP_PATH).entryList(QDir::Files);
    foreach( const QString & f, l )
        QFile::remove( QString(TEMP_PATH) + "/" + f );
#endif
}

QString Kaqaz::getTempPath()
{
    QDir().mkpath(TEMP_PATH);
    QString filePath = QString(TEMP_PATH) + "/kaqaz_temp_file_%1";

    int index = 0;
    while( QFile::exists(filePath.arg(index)) )
        index++;

    return filePath.arg(index);
}

QString Kaqaz::getStaticTempPath()
{
    static QString path = getTempPath();
    return path;
}

void Kaqaz::setProfilePath(QString path)
{
    if( path.isEmpty() )
        path = p->homePath;
    if( p->profilePath == path )
        return;

    const QString & old_db = profilePath() + "/database.sqlite";
    const QString & new_db = path + "/database.sqlite";
    const QString & old_rep  = repositoryPath();

    disconnectAllResources();

    p->profilePath = path;
    kaqaz_settings->setValue( "General/ProfilePath", path );

    QDir().mkpath(profilePath());
    QDir().mkpath(repositoryPath());


    QFile::copy( old_db, new_db );

    const QStringList & rep_files = QDir(old_rep).entryList(QDir::Files);
    foreach( const QString & f, rep_files )
    {
        QFile::copy( old_rep + "/" + f, repositoryPath() + "/" + f );
        QFile::remove( old_rep + "/" + f );
    }

    kaqaz_database->setPath( new_db );
    QFile::remove( old_db );

    reconnectAllResources();
}

QString Kaqaz::profilePath() const
{
    return p->profilePath;
}

QString Kaqaz::repositoryPath() const
{
    return profilePath() + "/repository";
}

QString Kaqaz::sdcardPath() const
{
    return "/sdcard/Android/data/org.sialan.kaqaz";
}

QString Kaqaz::fromMSecSinceEpoch(qint64 t)
{
    return convertDateTimeToString( QDateTime::fromMSecsSinceEpoch(t) );
}

QString Kaqaz::convertDateTimeToString(const QDateTime &dt)
{
    return translateNumbers( p->calendar->paperString(dt) );
}

int Kaqaz::daysOfMonth(qint64 y, int m)
{
    return p->calendar->daysOfMonth(y,m);
}

QString Kaqaz::monthName(int m)
{
    return p->calendar->monthName(m);
}

qint64 Kaqaz::currentYear()
{
    return p->calendar->getDate(QDate::currentDate()).year;
}

int Kaqaz::currentMonth()
{
    return p->calendar->getDate(QDate::currentDate()).month;
}

int Kaqaz::currentDay()
{
    return p->calendar->getDate(QDate::currentDate()).day;
}

QString Kaqaz::passToMd5(const QString &pass)
{
    if( pass.isEmpty() )
        return QString();

    return QCryptographicHash::hash( pass.toUtf8(), QCryptographicHash::Md5 ).toHex();
}

QStringList Kaqaz::findBackups()
{
    QString path = BACKUP_PATH;

    QStringList files = QDir(path).entryList( QStringList() << "*.kqz", QDir::Files, QDir::Size );
    for( int i=0; i<files.count(); i++ )
        files[i] = path + "/" + files[i];

    return files;
}

void Kaqaz::disconnectAllResources()
{
    kaqaz_database->disconnect();
}

void Kaqaz::reconnectAllResources()
{
    kaqaz_database->connect();
    refreshSettings();
    QMetaObject::invokeMethod( p->viewer->rootObject(), "refresh" );
}

QString Kaqaz::fileName(const QString &path)
{
    return QFileInfo(path).baseName();
}

QString Kaqaz::fileSuffix(const QString &path)
{
    return QFileInfo(path).suffix().toLower();
}

QString Kaqaz::readText(const QString &path)
{
    QFile file(path);
    if( !file.open(QFile::ReadOnly) )
        return QString();

    QString res = QString::fromUtf8(file.readAll());
    return res;
}

void Kaqaz::setTutorialCompleted(bool stt)
{
    kaqaz_settings->setValue("General/Tutorial",stt);
}

bool Kaqaz::isTutorialCompleted() const
{
    return kaqaz_settings->value("General/Tutorial",false).toBool();
}

void Kaqaz::setGroupsCount(bool stt)
{
    kaqaz_settings->setValue("General/GroupsCount",stt);
    emit groupsCountChanged();
}

bool Kaqaz::groupsCount() const
{
    return kaqaz_settings->value("General/GroupsCount",true).toBool();
}

void Kaqaz::setAllPaper(bool stt)
{
    kaqaz_settings->setValue("General/AllPaper",stt);
    emit allPaperChanged();
}

bool Kaqaz::allPaper() const
{
    return kaqaz_settings->value("General/AllPaper",true).toBool();
}

void Kaqaz::setKeyboardPredicative(bool stt)
{
    kaqaz_settings->setValue("General/KeyboardPredicative",stt);
    emit keyboardPredicativeChanged();
}

bool Kaqaz::keyboardPredicative() const
{
    return kaqaz_settings->value("General/KeyboardPredicative",true).toBool();
}

void Kaqaz::setPositioning(bool stt)
{
    kaqaz_settings->setValue("General/positioning",stt);
    emit positioningChanged();
}

bool Kaqaz::positioning() const
{
    return kaqaz_settings->value("General/positioning",true).toBool();
}

QStringList Kaqaz::dirEntryFiles(const QString &path, const QStringList & filters)
{
    QStringList res = QDir(path).entryList( filters, QDir::Files, QDir::Time );
    for( int i=0; i<res.count(); i++ )
    {
        const QString & r = res[i];
        res[i] = path + "/" + r;
    }

    return res;
}

QMultiMap<quint64,QString> findEntryFiles_prev(const QString &path, const QStringList &filters)
{
    QMultiMap<quint64,QString> res_map;

    QStringList dirs = Kaqaz::dirEntryDirs( path );
    foreach( const QString & d, dirs )
    {
        const QMultiMap<quint64,QString> & r = findEntryFiles_prev( d, filters );
        res_map.unite(r);
    }

    QStringList files = Kaqaz::dirEntryFiles( path, filters );
    foreach( const QString & f, files )
    {
        res_map.insert( QFileInfo(f).created().toMSecsSinceEpoch(), f );
    }

    return res_map;
}

QStringList Kaqaz::findEntryFiles(const QString &path, const QStringList &filters)
{
    QStringList res;
    const QStringList & list = findEntryFiles_prev(path,filters).values();
    foreach( const QString & l, list )
        res.prepend(l);

    return res;
}

QStringList Kaqaz::dirEntryDirs(const QString &path)
{
    QStringList res = QDir(path).entryList( QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name );
    for( int i=0; i<res.count(); i++ )
    {
        const QString & r = res[i];
        res[i] = path + "/" + r;
    }

    return res;
}

Qt::LayoutDirection Kaqaz::languageDirection()
{
    return p->locales.value(currentLanguage()).textDirection();
}

void Kaqaz::deleteItemDelay(QObject *o, int ms)
{
    QTimer::singleShot( ms, o, SLOT(deleteLater()) );
}

QStringList Kaqaz::getOpenFileNames(const QString &title, const QString &filter)
{
#ifdef DESKTOP_DEVICE
    return QFileDialog::getOpenFileNames( 0, title, QString(), filter );
#else
    Q_UNUSED(title)
    Q_UNUSED(filter)
    return QStringList();
#endif
}

QByteArray Kaqaz::encrypt(const QByteArray &ar, const QString &password)
{
    QByteArray res;
    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(password));
    SimpleQtCryptor::Encryptor enc( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB, SimpleQtCryptor::NoChecksum );
    enc.encrypt( ar, res, true );
    return res;
}

QByteArray Kaqaz::decrypt(const QByteArray &ar, const QString &password)
{
    QByteArray res;
    QSharedPointer<SimpleQtCryptor::Key> gKey = QSharedPointer<SimpleQtCryptor::Key>(new SimpleQtCryptor::Key(password));
    SimpleQtCryptor::Decryptor dec( gKey, SimpleQtCryptor::SERPENT_32, SimpleQtCryptor::ModeCFB );
    dec.decrypt( ar, res, true );
    return res;
}

qreal Kaqaz::colorHue(const QColor &clr)
{
    return clr.hue()/255.0;
}

qreal Kaqaz::colorLightness(const QColor &clr)
{
    return 2*clr.lightness()/255.0 - 1;
}

qreal Kaqaz::colorSaturation(const QColor &clr)
{
    return clr.saturation()/255.0;
}

QDate Kaqaz::convertDaysToDate(int days)
{
    return QDate(1,1,1).addDays(days);
}

int Kaqaz::convertDateToDays(const QDate &date)
{
    return QDate(1,1,1).daysTo(date);
}

void Kaqaz::setProperty(QObject *obj, const QString &property, const QVariant &v)
{
    if( !obj || property.isEmpty() )
        return;

    obj->setProperty( property.toUtf8(), v );
}

QVariant Kaqaz::property(QObject *obj, const QString &property)
{
    if( !obj || property.isEmpty() )
        return QVariant();

    return obj->property(property.toUtf8());
}

void Kaqaz::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->lock_timer )
    {
        QMetaObject::invokeMethod( p->viewer->rootObject(), "lock" );
        killTimer( p->lock_timer );
        p->lock_timer = 0;
    }
}

bool Kaqaz::eventFilter(QObject *o, QEvent *e)
{
    if( o == p->viewer )
    {
        switch( static_cast<int>(e->type()) )
        {
        case QEvent::Close:
            if( p->close_blocker )
            {
                static_cast<QCloseEvent*>(e)->ignore();
                emit backRequest();
            }
            else
            {
                cleanCache();
                static_cast<QCloseEvent*>(e)->accept();
            }

            return false;
            break;
        }
    }

    return QObject::eventFilter(o,e);
}

Kaqaz::~Kaqaz()
{
    p->backuper->deleteLater();

    delete p->viewer;
    delete p->calendar;
    delete p;
}
