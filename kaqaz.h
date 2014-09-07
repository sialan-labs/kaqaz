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

#ifndef KAQAZ_H
#define KAQAZ_H

#include <QObject>
#include <QDate>
#include <QStringList>
#include <QSettings>
#include <QScreen>

class KaqazSync;
class DateProperty;
class Database;
class KaqazPrivate;
class Backuper;
class Kaqaz : public QObject
{
    Q_PROPERTY( int     currentDays          READ currentDays         NOTIFY currentDaysChanged )
    Q_PROPERTY( bool    proBuild             READ proBuild            NOTIFY proBuildChanged )
    Q_PROPERTY( bool    groupsCount          READ groupsCount         WRITE setGroupsCount         NOTIFY groupsCountChanged)
    Q_PROPERTY( bool    allPaper             READ allPaper            WRITE setAllPaper            NOTIFY allPaperChanged)
    Q_PROPERTY( bool    keyboardPredicative  READ keyboardPredicative WRITE setKeyboardPredicative NOTIFY keyboardPredicativeChanged)
    Q_PROPERTY( bool    positioning          READ positioning         WRITE setPositioning         NOTIFY positioningChanged)
    Q_PROPERTY( QString resourcePath         READ resourcePath        NOTIFY resourcePathChanged)
    Q_PROPERTY( Qt::LayoutDirection  languageDirection  READ languageDirection NOTIFY languageDirectionChanged )

    Q_OBJECT
private:
    Kaqaz(QObject *parent = 0);
    ~Kaqaz();

public:
    static Kaqaz *instance();

#ifdef KAQAZ_DESKTOP
    QWidget *view();
#else
    QWindow *view();
#endif

    Backuper *backuper() const;
    KaqazSync *kaqazSync() const;

    Q_INVOKABLE bool demoHasTrial() const;
    Q_INVOKABLE void demoActiveTrial() const;
    Q_INVOKABLE bool proBuild() const;

    Q_INVOKABLE static QString version();
    Q_INVOKABLE static QString qtVersion();
    Q_INVOKABLE static QString aboutSialan();

    Q_INVOKABLE void deleteFileIfPossible( const QString & id );

    Q_INVOKABLE void removeFile( const QString & path );

    Q_INVOKABLE void setCalendar( int t );
    Q_INVOKABLE QStringList calendarsID() const;
    Q_INVOKABLE QString calendarName( int t );
    Q_INVOKABLE int calendar() const;

    Q_INVOKABLE static int currentDays();

    Q_INVOKABLE QString convertIntToStringDate(qint64 d );
    Q_INVOKABLE QString convertIntToFullStringDate(qint64 d );
    Q_INVOKABLE QString convertIntToNumStringDate(qint64 d );
    Q_INVOKABLE QString translateInt(qint64 d);
    Q_INVOKABLE QString convertIntToStringDate(qint64 d, const QString & format );
    Q_INVOKABLE QDate convertDateToGragorian( qint64 year, int month, int day );

    Q_INVOKABLE void close();
    Q_INVOKABLE void minimize();

    Q_INVOKABLE static Database *database();
    Q_INVOKABLE static QSettings *settings();
    Q_INVOKABLE static QScreen *screen();
    Q_INVOKABLE static QObject *screenObj();

    Q_INVOKABLE void refreshSettings();

    Q_INVOKABLE void setClipboard( const QString & text );
    Q_INVOKABLE QString clipboard() const;

    Q_INVOKABLE QStringList languages();
    Q_INVOKABLE void setCurrentLanguage( const QString & lang );
    Q_INVOKABLE QString currentLanguage() const;

    Q_INVOKABLE void shareToFile( const QString & subject, const QString & message, const QString & path );
    Q_INVOKABLE QString cacheFile( const QString & address );
    Q_INVOKABLE void cleanCache();
    Q_INVOKABLE QString getTempPath();
    Q_INVOKABLE QString getStaticTempPath();

    Q_INVOKABLE void setProfilePath( QString path );
    Q_INVOKABLE QString profilePath() const;
    Q_INVOKABLE QString repositoryPath() const;
    Q_INVOKABLE QString sdcardPath() const;
    static QString resourcePath();

    Q_INVOKABLE QString fromMSecSinceEpoch( qint64 t );
    Q_INVOKABLE QString convertDateTimeToString( const QDateTime & dt );
    Q_INVOKABLE int daysOfMonth( qint64 year, int month );
    Q_INVOKABLE QString monthName( int month );
    Q_INVOKABLE qint64 currentYear();
    Q_INVOKABLE int currentMonth();
    Q_INVOKABLE int currentDay();
    DateProperty convertDate( const QDate & date );

    Q_INVOKABLE static QString passToMd5( const QString & pass );

    Q_INVOKABLE QStringList findBackups();

    Q_INVOKABLE QString fileName( const QString & path );
    Q_INVOKABLE QString fileSuffix( const QString & path );
    Q_INVOKABLE QString readText( const QString & path );

    Q_INVOKABLE void setTutorialCompleted( bool stt );
    Q_INVOKABLE bool isTutorialCompleted() const;

    void setGroupsCount( bool stt );
    bool groupsCount() const;

    void setAllPaper( bool stt );
    bool allPaper() const;

    void setKeyboardPredicative( bool stt );
    bool keyboardPredicative() const;

    void setPositioning( bool stt );
    bool positioning() const;

    void setTitleFont( const QFont & fnt );
    QFont titleFont() const;

    void setBodyFont( const QFont & fnt );
    QFont bodyFont() const;

    Q_INVOKABLE static QStringList dirEntryFiles(const QString & path , const QStringList &filters);
    Q_INVOKABLE static QStringList findEntryFiles(const QString & path , const QStringList &filters);
    Q_INVOKABLE static QStringList dirEntryDirs(const QString & path);

    Q_INVOKABLE Qt::LayoutDirection languageDirection();

    Q_INVOKABLE void deleteItemDelay( QObject *o, int ms );

    Q_INVOKABLE QStringList getOpenFileNames( const QString & title, const QString & filter );

    Q_INVOKABLE QByteArray encrypt( const QByteArray & ar, const QString & password );
    Q_INVOKABLE QByteArray decrypt( const QByteArray & ar, const QString & password );

    Q_INVOKABLE qreal colorHue( const QColor & clr );
    Q_INVOKABLE qreal colorLightness( const QColor & clr );
    Q_INVOKABLE qreal colorSaturation( const QColor & clr );

    Q_INVOKABLE static QDate convertDaysToDate( int days );
    Q_INVOKABLE static int convertDateToDays( const QDate & date );

    Q_INVOKABLE void setProperty( QObject *obj, const QString & property, const QVariant & v );
    Q_INVOKABLE QVariant property( QObject *obj, const QString & property );

public slots:
    bool start();
    void incomingAppMessage( const QString & msg );

    void disconnectAllResources();
    void reconnectAllResources();

signals:
    void currentDaysChanged();
    void groupsCountChanged();
    void allPaperChanged();
    void keyboardPredicativeChanged();
    void positioningChanged();
    void resourcePathChanged();

    void titleFontChanged();
    void bodyFontChanged();

    void backRequest();
    void languageChanged();
    void languageDirectionChanged();
    void calendarChanged();

    void proBuildChanged();

private slots:
    void incomingShare( const QString & title, const QString & msg );
    void incomingImage( const QString & path );
    void selectImageResult( const QString & path );
    void activityPaused();
    void activityResumed();

protected:
    void timerEvent(QTimerEvent *e);
    bool eventFilter(QObject *o, QEvent *e);

private:
    void init_languages();

private:
    KaqazPrivate *p;
};

#endif // KAQAZ_H
