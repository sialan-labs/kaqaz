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

#include "panelbox.h"
#include "categoriesmodel.h"
#include "datesmodel.h"
#include "kaqaz.h"
#include "database.h"

#include <QListView>

class PanelBoxPrivate
{
public:
    CategoriesModel *groups_model;
    DatesModel *dates_model;

    QListView *groups;
    QListView *dates;

    Kaqaz *kaqaz;
};

PanelBox::PanelBox(Kaqaz *kaqaz, QWidget *parent) :
    QToolBox(parent)
{
    p = new PanelBoxPrivate;
    p->kaqaz = kaqaz;
    p->groups_model = new CategoriesModel(Kaqaz::database(), this);
    p->dates_model = new DatesModel(p->kaqaz, Kaqaz::database(), this);

    p->dates = new QListView(this);
    p->dates->setModel(p->dates_model);
    p->dates->setVerticalScrollMode(QListView::ScrollPerPixel);
    p->dates->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

    p->groups = new QListView(this);
    p->groups->setModel(p->groups_model);
    p->groups->setVerticalScrollMode(QListView::ScrollPerPixel);
    p->groups->setHorizontalScrollBarPolicy(Qt::ScrollBarAlwaysOff);

    addItem( p->groups, tr("Labels") );
    addItem( p->dates , tr("Dates") );

    setStyleSheet("QToolBox{ background: #222222; border: 0px solid transparent; }"
                  "QToolBox::tab { background: #222222; color: #ffffff }"
                  "QToolBox::tab:selected { background: #222222; font: bold; color: white; border-top: 1px solid #333333 }"
                  "QListView{ background: #333333; border: 0px solid transparent }"
                  "QListView::item{ color: #ffffff }"
                  "QListView::item:selected{ background: palette(highlight) }"
                  "QScrollBar:vertical { border: 0px solid transparent; background: transparent; max-width: 5px; min-width: 5px; }"
                  "QScrollBar::handle:vertical { border: 0px solid transparent; background: #666666; width: 5px; min-width: 5px; min-height: 30px }"
                  "QScrollBar::handle:hover { background: palette(highlight); }"
                  "QScrollBar::add-line:vertical { border: 0px solid transparent; background: transparent; height: 0px; subcontrol-position: bottom; subcontrol-origin: margin; }"
                  "QScrollBar::sub-line:vertical { border: 0px solid transparent; background: transparent; height: 0px; subcontrol-position: top; subcontrol-origin: margin; }");

    connect( p->dates , SIGNAL(clicked(QModelIndex)), SLOT(date_selected(QModelIndex))  );
    connect( p->groups, SIGNAL(clicked(QModelIndex)), SLOT(group_selected(QModelIndex)) );
}

void PanelBox::date_selected(const QModelIndex &idx)
{
    const int days = p->dates_model->id(idx);
    emit showPaperRequest( p->kaqaz->database()->papersOf(p->kaqaz->convertDaysToDate(days)) );
}

void PanelBox::group_selected(const QModelIndex &idx)
{
    const int gid = p->groups_model->id(idx);
    emit showPaperRequest( p->kaqaz->database()->papersOf(gid) );
}

PanelBox::~PanelBox()
{
    delete p;
}
