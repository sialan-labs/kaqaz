/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

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

#ifndef KAQAZDESKTOP_H
#define KAQAZDESKTOP_H

#include <QWidget>

class MimeApps;
class SialanTools;
class SialanDevices;
class KaqazSync;
class Backuper;
class Repository;
class Database;
class Kaqaz;
class KaqazDesktopPrivate;
class KaqazDesktop : public QWidget
{
    Q_OBJECT
public:
    KaqazDesktop();
    ~KaqazDesktop();

    void setDatabase( Database *db );
    void setRepository( Repository *rep );
    void setBackuper( Backuper *bkpr );
    void setKaqazSync( KaqazSync *ksync );
    void setSialanDevices( SialanDevices *sdev );
    void setSialanTools( SialanTools *stools );
    void setMimeApps( MimeApps *mapp );

public slots:
    bool start();
    void refresh();
    void lock();

    void addGroup();
    void showConfigure();
    void showAbout();

private slots:
    void save_splitter();
    void syncStarted();
    void syncProgress( qreal val );
    void syncFinished();
    void refreshSync();

protected:
    void timerEvent(QTimerEvent *e);
    void resizeEvent(QResizeEvent *e);
    void paintEvent(QPaintEvent *e);

private:
    void init_toolbar();
    void init_mainWidget();

private:
    KaqazDesktopPrivate *p;
};

#endif // KAQAZDESKTOP_H
