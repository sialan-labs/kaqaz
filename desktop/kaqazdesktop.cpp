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

#include "kaqazdesktop.h"
#include "kaqaz.h"
#include "database.h"
#include "repository.h"
#include "backuper.h"
#include "kaqazsync.h"
#include "panelbox.h"
#include "sialantools/sialandevices.h"
#include "sialantools/sialantools.h"
#include "mimeapps.h"
#include "papersview.h"
#include "editorview.h"

#include <QToolBar>
#include <QAction>
#include <QListView>
#include <QHBoxLayout>
#include <QFontDatabase>
#include <QApplication>
#include <QSplitter>
#include <QTimerEvent>

class KaqazDesktopPrivate
{
public:
    Kaqaz *kaqaz;

    QToolBar *toolbar;
    QAction *new_act;
    QAction *new_grp_act;
    QAction *find_act;

    Database *db;
    Repository *repository;
    Backuper *backuper;
    KaqazSync *sync;
    SialanDevices *devices;
    SialanTools *tools;
    MimeApps *mimeApps;

    PanelBox *panel;
    PapersView *papers_view;
    EditorView *editor;
    QSplitter *splitter;

    QFont font;

    int splitter_save_timer;
    int resize_save_timer;
};

KaqazDesktop::KaqazDesktop(Kaqaz *parent) :
    QMainWindow()
{
    p = new KaqazDesktopPrivate;
    p->splitter_save_timer = 0;
    p->resize_save_timer = 0;
    p->kaqaz = parent;

    QFontDatabase::addApplicationFont( p->kaqaz->resourcePath() + "/fonts/DroidKaqazSans.ttf" );

    p->font.setFamily("Droid Kaqaz Sans");
    p->font.setPointSize(9);

    resize( p->kaqaz->settings()->value("UserInterface/size",QSize(1024,600)).toSize() );

    init_toolbar();
    init_mainWidget();
}

void KaqazDesktop::init_toolbar()
{
    p->new_act = new QAction( QIcon::fromTheme("document-new"), tr("Add Paper"), this );
    p->new_grp_act = new QAction( QIcon::fromTheme("document-new"), tr("Add Label"), this );
    p->find_act = new QAction( QIcon::fromTheme("edit-find"), tr("Search"), this );

    p->toolbar = new QToolBar();
    p->toolbar->addAction(p->new_act);
    p->toolbar->addAction(p->new_grp_act);
    p->toolbar->addSeparator();
    p->toolbar->addAction(p->find_act);
    p->toolbar->setToolButtonStyle(Qt::ToolButtonTextBesideIcon);
    p->toolbar->setMovable(false);

    addToolBar( p->toolbar );
}

void KaqazDesktop::init_mainWidget()
{
    p->panel = new PanelBox(p->kaqaz,this);
    p->papers_view = new PapersView(Kaqaz::database(),this);
    p->editor = new EditorView(this);

    p->splitter = new QSplitter();
    p->splitter->addWidget(p->panel);
    p->splitter->addWidget(p->papers_view);
    p->splitter->addWidget(p->editor);
    p->splitter->setStyleSheet("QSplitter::handle{background: #f3f3f3}");
    p->splitter->setSizes( QList<int>()<< 213 << 273 << width()-486 );
    p->splitter->restoreState( p->kaqaz->settings()->value("UserInterface/splitter").toByteArray() );

    setCentralWidget(p->splitter);

    connect( p->splitter   , SIGNAL(splitterMoved(int,int))      , this          , SLOT(save_splitter())        );
    connect( p->panel      , SIGNAL(showPaperRequest(QList<int>)), p->papers_view, SLOT(showPapers(QList<int>)) );
    connect( p->papers_view, SIGNAL(paperSelected(int))          , p->editor     , SLOT(setPaper(int))          );
}

void KaqazDesktop::setDatabase(Database *db)
{
    p->db = db;
}

void KaqazDesktop::setRepository(Repository *rep)
{
    p->repository = rep;
}

void KaqazDesktop::setBackuper(Backuper *bkpr)
{
    p->backuper = bkpr;
}

void KaqazDesktop::setKaqazSync(KaqazSync *ksync)
{
    p->sync = ksync;
}

void KaqazDesktop::setSialanDevices(SialanDevices *sdev)
{
    p->devices = sdev;
}

void KaqazDesktop::setSialanTools(SialanTools *stools)
{
    p->tools = stools;
}

void KaqazDesktop::setMimeApps(MimeApps *mapp)
{
    p->mimeApps = mapp;
}

void KaqazDesktop::start()
{
    show();
}

void KaqazDesktop::refresh()
{

}

void KaqazDesktop::lock()
{

}

void KaqazDesktop::save_splitter()
{
    if( p->splitter_save_timer )
        killTimer(p->splitter_save_timer);

    p->splitter_save_timer = startTimer(500);
}

void KaqazDesktop::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->splitter_save_timer )
    {
        killTimer(p->splitter_save_timer);
        p->splitter_save_timer = 0;

        p->kaqaz->settings()->setValue("UserInterface/splitter", p->splitter->saveState() );
    }
    else
    if( e->timerId() == p->resize_save_timer )
    {
        killTimer(p->resize_save_timer);
        p->resize_save_timer = 0;

        p->kaqaz->settings()->setValue("UserInterface/size", size() );
    }

    QMainWindow::timerEvent(e);
}

void KaqazDesktop::resizeEvent(QResizeEvent *e)
{
    if( p->resize_save_timer )
        killTimer(p->resize_save_timer);

    p->resize_save_timer = startTimer(500);

    QMainWindow::resizeEvent(e);
}

KaqazDesktop::~KaqazDesktop()
{
    delete p;
}
