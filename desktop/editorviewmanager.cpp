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

#include "editorviewmanager.h"
#include "editorview.h"
#include "kaqaz.h"
#include "database.h"

#include <QStackedWidget>
#include <QTabBar>
#include <QVBoxLayout>
#include <QResizeEvent>
#include <QHash>
#include <QDebug>

class EditorViewManagerPrivate
{
public:
    QTabBar *tabbar;
    QStackedWidget *stacked;
    QVBoxLayout *layout;

    EditorView *main_editor;

    QList<int> tabs;
};

EditorViewManager::EditorViewManager(QWidget *parent) :
    QWidget(parent)
{
    p = new EditorViewManagerPrivate;

    p->tabbar = new QTabBar(this);
    p->tabbar->setMovable(true);
    p->tabbar->setTabsClosable(true);
    p->tabbar->setUsesScrollButtons(true);
    p->tabbar->setFocusPolicy(Qt::NoFocus);
    p->tabbar->addTab( tr("Main Paper") );
    p->tabbar->tabButton(0, QTabBar::RightSide)->setDisabled(true);

    p->tabs << 0;

    p->main_editor = new EditorView();
    p->main_editor->installEventFilter(this);

    p->stacked = new QStackedWidget();
    p->stacked->addWidget(p->main_editor);

    p->layout = new QVBoxLayout(this);
    p->layout->addWidget(p->stacked);
    p->layout->setContentsMargins(0,0,0,0);
    p->layout->setSpacing(0);

    connect( p->tabbar, SIGNAL(tabMoved(int,int))     , this      , SLOT(tabMoved(int,int))    );
    connect( p->tabbar, SIGNAL(currentChanged(int))   , p->stacked, SLOT(setCurrentIndex(int)) );
    connect( p->tabbar, SIGNAL(tabCloseRequested(int)), this      , SLOT(close(int))           );
}

QTabBar *EditorViewManager::tabBar() const
{
    return p->tabbar;
}

void EditorViewManager::addPaper(int pid)
{
    p->main_editor->setPaper(0);
    if( pid && p->tabs.contains(pid) )
    {
        p->tabbar->setCurrentIndex( p->tabs.indexOf(pid) );
        return;
    }

    EditorView *editor = new EditorView();
    if( pid != 0 )
        editor->setPaper(pid);

    p->stacked->addWidget(editor);
    p->tabbar->addTab( pid? Kaqaz::database()->paperTitle(pid) : tr("New Paper") );
    p->tabbar->setCurrentIndex( p->tabbar->count()-1 );

    p->tabs << pid;
}

void EditorViewManager::setMainPaper(int pid)
{
    if( pid && p->tabs.contains(pid) )
    {
        p->tabbar->setCurrentIndex( p->tabs.indexOf(pid) );
        return;
    }

    p->main_editor->setPaper(pid);
    p->stacked->setCurrentWidget(p->main_editor);
    p->tabbar->setCurrentIndex( p->stacked->currentIndex() );
}

void EditorViewManager::tabMoved(int from, int to)
{
    p->tabs.move(from,to);

    QWidget *wgt = p->stacked->widget(from);
    p->stacked->removeWidget(wgt);
    p->stacked->insertWidget(to,wgt);
}

void EditorViewManager::close(int row)
{
    p->tabs.removeAt(row);
    p->tabbar->removeTab(row);
    p->stacked->removeWidget( p->stacked->widget(row) );
}

void EditorViewManager::resizeEvent(QResizeEvent *e)
{
    p->tabbar->setFixedWidth(e->size().width());
}

EditorViewManager::~EditorViewManager()
{
    delete p;
}
