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
#include "searchhighlighter.h"
#include "sialantools/sialantools.h"
#include "resourcemanager.h"
#include "SimpleQtCryptor/simpleqtcryptor.h"
#include "sialantools/sialandevices.h"
#include "sialantools/sialanquickview.h"
#include "sialantools/sialancalendarconverter.h"

#ifdef Q_OS_ANDROID
#include "sialantools/sialanjavalayer.h"
#endif

#ifdef DESKTOP_LINUX
#include "iconprovider.h"
#endif

#ifdef DESKTOP_DEVICE
#include "desktop/kaqazdesktop.h"
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

Database *kaqaz_database = 0;
QSettings *kaqaz_settings = 0;

class KaqazPrivate
{
public:
#ifdef DESKTOP_DEVICE
    KaqazDesktop *viewer_classic;
#endif

    SialanQuickView *viewer;

    QString homePath;
    QString translationsPath;
    QString confPath;
    QString profilePath;

    int lock_timer;
    bool close_blocker;
    bool keyboard;
    bool fullscreen;

    bool demo_active_until_next;
    bool desktop_touch_mode;

    QTranslator *translator;
    KaqazSync *sync;

    QHash<QString,QVariant> languages;
    QHash<QString,QLocale> locales;
    QString language;

    Repository *repository;
    Backuper *backuper;

    QFileSystemWatcher *filesystem;
    QMimeDatabase mime_db;

    SialanDevices *devices;
    SialanTools *tools;
    SialanCalendarConverter *calendar;

#ifdef Q_OS_ANDROID
    SialanJavaLayer *java_layer;
#endif
};

QPointer<Kaqaz> kaqaz_obj;
Kaqaz::Kaqaz(QObject *parent) :
    QObject(parent)
{
    kaqaz_obj = this;

    p = new KaqazPrivate;
    p->demo_active_until_next = false;
    p->desktop_touch_mode = false;
    p->lock_timer = 0;
    p->keyboard = false;
    p->fullscreen = false;
    p->viewer = 0;
#ifdef DESKTOP_DEVICE
    p->viewer_classic = 0;
#endif
    p->translator = new QTranslator(this);
    p->backuper = new Backuper();
    p->devices = new SialanDevices(this);
    p->tools = new SialanTools(this);
#ifdef Q_OS_ANDROID
    p->java_layer = SialanJavaLayer::instance();
#endif

#ifdef DESKTOP_DEVICE
    QIcon::setThemeSearchPaths( QStringList() << resourcePathAbs() + "/files/icons/" );
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
    p->translationsPath = resourcePath().mid(7) + "/files/translations/";
    p->confPath = p->homePath + "/config.ini";
#endif

    if( !kaqaz_settings )
        kaqaz_settings = new QSettings( p->confPath, QSettings::IniFormat );

    p->profilePath = kaqaz_settings->value( "General/ProfilePath", p->homePath ).toString();
#ifdef Q_OS_MAC
    p->desktop_touch_mode = kaqaz_settings->value("UserInterface/type", false).toBool();
#endif

    QDir().mkpath(p->homePath);
    QDir().mkpath(profilePath());
    QDir().mkpath(repositoryPath());

    p->repository = new Repository(this);

    if( !kaqaz_database )
        kaqaz_database = new Database(profilePath() + "/database.sqlite");

    p->sync = new KaqazSync(kaqaz_database,this);

    init_languages();

    qmlRegisterType<PaperManager>("Kaqaz", 1,0, "PaperManager");
    qmlRegisterType<SearchHighlighter>("Kaqaz", 1,0, "SearchHighlighter");
    qmlRegisterType<Enums>("Kaqaz", 1,0, "Enums");
}

Kaqaz *Kaqaz::instance()
{
    if( !kaqaz_obj )
        kaqaz_obj = new Kaqaz( QCoreApplication::instance() );

    return kaqaz_obj;
}

QObject *Kaqaz::view()
{
    return p->viewer;
}

Backuper *Kaqaz::backuper() const
{
    return p->backuper;
}

KaqazSync *Kaqaz::kaqazSync() const
{
    return p->sync;
}

SialanCalendarConverter *Kaqaz::calendarConverter() const
{
    return p->calendar;
}

Repository *Kaqaz::repository() const
{
    return p->repository;
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

bool Kaqaz::start()
{
    if( p->viewer )
        return true;

#ifdef DESKTOP_DEVICE
    if( !p->desktop_touch_mode )
    {
        p->calendar = new SialanCalendarConverter(this);

        p->viewer_classic = new KaqazDesktop();
        p->viewer_classic->setDatabase(kaqaz_database);
        p->viewer_classic->setRepository(p->repository);
        p->viewer_classic->setBackuper(p->backuper);
        p->viewer_classic->setKaqazSync(p->sync);
        p->viewer_classic->setSialanDevices(p->devices);
        p->viewer_classic->setSialanTools(p->tools);
    }
    else
#endif
    {
        p->viewer = new SialanQuickView(
#ifdef DESKTOP_DEVICE
                            SialanQuickView::AllExceptLogger
#else
                            SialanQuickView::AllComponents
#endif
                    );
        p->viewer->installEventFilter(this);
        p->viewer->engine()->rootContext()->setContextProperty( "kaqaz", this );
        p->viewer->engine()->rootContext()->setContextProperty( "database", kaqaz_database );
        p->viewer->engine()->rootContext()->setContextProperty( "filesystem", p->filesystem );
        p->viewer->engine()->rootContext()->setContextProperty( "repository", p->repository );
        p->viewer->engine()->rootContext()->setContextProperty( "backuper", p->backuper );
        p->viewer->engine()->rootContext()->setContextProperty( "sync", p->sync );
#ifdef DESKTOP_LINUX
        p->viewer->engine()->addImageProvider( "icon", new IconProvider() );
#endif
        p->viewer->engine()->rootContext()->setContextProperty( "keyboard", QGuiApplication::inputMethod() );
        if( !QGuiApplication::screens().isEmpty() )
            p->viewer->engine()->rootContext()->setContextProperty( "screen", QGuiApplication::screens().first() );

        connect(p->viewer->engine(), SIGNAL(quit()), SLOT(close()));

        p->calendar = p->viewer->calendar();
    }

    p->calendar->setCalendar( static_cast<SialanCalendarConverterCore::CalendarTypes>(kaqaz_settings->value("General/Calendar",SialanCalendarConverterCore::Gregorian).toInt()) );

    connect( kaqaz_database, SIGNAL(fileDeleted(QString)), p->repository, SLOT(deleteFile(QString)) );

    connect( p->devices, SIGNAL(incomingImage(QString)), SLOT(incomingImage(QString)) );
    connect( p->devices, SIGNAL(incomingShare(QString,QString)), SLOT(incomingShare(QString,QString)) );
    connect( p->devices, SIGNAL(selectImageResult(QString)), SLOT(selectImageResult(QString)) );
    connect( p->devices, SIGNAL(activityPaused()), SLOT(activityPaused()) );
    connect( p->devices, SIGNAL(activityResumed()), SLOT(activityResumed()) );

    bool res = false;
#ifdef DESKTOP_DEVICE
    if( !p->desktop_touch_mode )
    {
        res = p->viewer_classic->start();
    }
    else
#endif
    {
        p->viewer->setSource(QStringLiteral("qrc:///qml/Kaqaz/kaqaz.qml"));
        p->viewer->show();
        res = true;
    }

#ifndef DESKTOP_DEVICE
    setFullscreen( kaqaz_settings->value("UserInterface/fullscreen", false).toBool() );
#endif

    return res;
}

void Kaqaz::incomingAppMessage(const QString &msg)
{
    if( msg == "show" )
    {
#ifdef DESKTOP_DEVICE
        if( !p->desktop_touch_mode )
        {
            p->viewer_classic->show();
            p->viewer_classic->activateWindow();
        }
        else
#endif
        {
            p->viewer->show();
            p->viewer->requestActivate();
        }
    }
}

void Kaqaz::incomingShare(const QString &title, const QString &msg)
{
    if( !p->desktop_touch_mode )
        return;

    QVariant title_var = title;
    QVariant msg_var = msg;

    QMetaObject::invokeMethod( p->viewer->rootObject(), "incomingShare", Q_ARG(QVariant,title_var), Q_ARG(QVariant,msg_var) );
}

void Kaqaz::incomingImage(const QString &path)
{
    if( !p->desktop_touch_mode )
        return;

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
#ifdef FREE_BUILD
    return false;
#else
    return true;
#endif
}

QString Kaqaz::version()
{
    return KAQAZ_VERSION
#ifndef FREE_BUILD
            " pro"
#else
#ifdef TRIAL_BUILD
            " trial"
#else
            " free"
#endif
#endif
            ;
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
    p->calendar->setCalendar( static_cast<SialanCalendarConverterCore::CalendarTypes>(t) );
    kaqaz_settings->setValue( "General/Calendar", t );
    emit calendarChanged();
}

QStringList Kaqaz::calendarsID() const
{
    return p->calendar->calendarsID();
}

int Kaqaz::calendar() const
{
    return kaqaz_settings->value("General/Calendar",0).toInt();
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

QString Kaqaz::resourcePathAbs()
{
#ifdef Q_OS_ANDROID
    return "assets:";
#else
    static QString *resourcePath = 0;
    if( !resourcePath )
    {
#ifdef Q_OS_MAC
        QFileInfo inf(QCoreApplication::applicationDirPath() + "/../Resources");
        resourcePath = new QString(inf.filePath());
#else
        QFileInfo inf(QCoreApplication::applicationDirPath()+"/../share/kaqaz");
        if( inf.exists() )
            resourcePath = new QString(inf.filePath());
        else
            resourcePath = new QString(QCoreApplication::applicationDirPath());
#endif
    }
    return *resourcePath + "/";
#endif
}

QString Kaqaz::resourcePath()
{
#ifdef Q_OS_ANDROID
    return resourcePathAbs();
#else
#ifdef Q_OS_WIN
    return "file:///" + resourcePathAbs();
#else
    return "file://" + resourcePathAbs();
#endif
#endif
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
#ifdef DESKTOP_DEVICE
    if( !p->desktop_touch_mode )
        p->viewer_classic->refresh();
    else
#endif
        QMetaObject::invokeMethod( p->viewer->rootObject(), "refresh" );
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

void Kaqaz::setTitleFont(const QFont &fnt)
{
    kaqaz_settings->setValue("General/titleFont", fnt);
    emit titleFontChanged();
}

QFont Kaqaz::titleFont() const
{
    QFont font;
    font.setFamily("Droid Kaqaz Sans");
    font.setPointSize(15);

    return kaqaz_settings->value("General/titleFont",font).value<QFont>();
}

void Kaqaz::setBodyFont(const QFont &fnt)
{
    kaqaz_settings->setValue("General/bodyFont", fnt);
    emit bodyFontChanged();
}

QFont Kaqaz::bodyFont() const
{
    QFont font;
    font.setFamily("Droid Kaqaz Sans");
    font.setPointSize(10);

    return kaqaz_settings->value("General/bodyFont",font).value<QFont>();
}

void Kaqaz::setSize(const QSize &size)
{
    if( p->fullscreen )
        return;

#ifdef DESKTOP_DEVICE
    if( !p->desktop_touch_mode )
        kaqaz_settings->setValue("UserInterface/sizeClassic", size);
    else
        kaqaz_settings->setValue("UserInterface/size", size);
#else
    Q_UNUSED(size)
#endif
}

QSize Kaqaz::size() const
{
#ifdef DESKTOP_DEVICE
    if( !p->desktop_touch_mode )
        return kaqaz_settings->value("UserInterface/sizeClassic", QSize(1024,640)).value<QSize>();
    else
        return kaqaz_settings->value("UserInterface/size",QSize(1024*p->devices->density(),600*p->devices->density())).value<QSize>();
#else
    return QSize(0,0);
#endif
}

void Kaqaz::setDesktopTouchMode(bool stt)
{
    if( p->desktop_touch_mode == stt )
        return;

    p->desktop_touch_mode = stt;

#ifdef Q_OS_MAC
    kaqaz_settings->setValue("UserInterface/type", p->desktop_touch_mode);
#endif

    emit desktopTouchModeChanged();
}

bool Kaqaz::desktopTouchMode() const
{
    return p->desktop_touch_mode;
}

void Kaqaz::setFullscreen(bool stt)
{
    if( p->fullscreen == stt )
        return;

    p->fullscreen = stt;

#ifndef DESKTOP_DEVICE
    kaqaz_settings->setValue("UserInterface/fullscreen", p->fullscreen);
#endif

    if( p->fullscreen )
    {
#ifdef DESKTOP_DEVICE
        if( !p->desktop_touch_mode )
            p->viewer_classic->showFullScreen();
        else
#endif
            p->viewer->setFullscreen(true);
    }
    else
    {
#ifdef DESKTOP_DEVICE
        if( !p->desktop_touch_mode )
            p->viewer_classic->showNormal();
        else
#endif
            p->viewer->setFullscreen(false);
    }

    emit fullscreenChanged();
}

bool Kaqaz::fullscreen() const
{
    return p->fullscreen;
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

void Kaqaz::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->lock_timer )
    {
#ifdef DESKTOP_DEVICE
        if( !p->desktop_touch_mode )
            p->viewer_classic->lock();
        else
#endif
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

//    delete p->viewer;
    delete p->calendar;
    delete p;
}
