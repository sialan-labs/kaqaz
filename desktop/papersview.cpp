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

#include "papersview.h"
#include "papersmodel.h"
#include "database.h"
#include "paperviewdelegate.h"

#include <QScrollBar>

class PapersViewPrivate
{
public:
    Database *db;
    PapersModel *model;
    PaperViewDelegate *delegate;
};

PapersView::PapersView(Database *db, QWidget *parent) :
    QListView(parent)
{
    p = new PapersViewPrivate;
    p->db = db;

    p->model = new PapersModel(p->db,this);
    p->delegate = new PaperViewDelegate;

    setModel(p->model);
    setItemDelegate(p->delegate);
    setVerticalScrollMode(QListView::ScrollPerPixel);
    setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);
    setStyleSheet("QListView{ background: #f3f3f3; border: 0px solid transparent }"
                  "QListView::item{ color: #333333; padding: 4px }"
                  "QListView::item:selected{ background: palette(highlight); color: #ffffff }"
                  "QScrollBar:vertical { border: 0px solid transparent; background: transparent; max-width: 5px; min-width: 5px; }"
                  "QScrollBar::handle:vertical { border: 0px solid transparent; background: #aaaaaa; width: 5px; min-width: 5px; min-height: 30px }"
                  "QScrollBar::handle:hover { background: palette(highlight); }"
                  "QScrollBar::add-line:vertical { border: 0px solid transparent; background: transparent; height: 0px; subcontrol-position: bottom; subcontrol-origin: margin; }"
                  "QScrollBar::sub-line:vertical { border: 0px solid transparent; background: transparent; height: 0px; subcontrol-position: top; subcontrol-origin: margin; }");

    connect( this, SIGNAL(clicked(QModelIndex)), SLOT(paper_selected(QModelIndex)) );
}

void PapersView::showPapers(const QList<int> &papers)
{
    p->model->setPapers(papers);
}

void PapersView::paper_selected(const QModelIndex &idx)
{
    const int pid = p->model->id(idx);
    emit paperSelected(pid);
}

PapersView::~PapersView()
{
    delete p;
}
