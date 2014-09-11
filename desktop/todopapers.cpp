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

#include "todopapers.h"
#include "todopapersitem.h"

#include <QScrollArea>
#include <QHBoxLayout>

class ToDoPapersPrivate
{
public:
    QWidget *base_wgt;
    QHBoxLayout *base_layout;

    QScrollArea *area;
    QHBoxLayout *layout;

    QString text;
    QList<ToDoPapersItem*> items;
};

ToDoPapers::ToDoPapers(QWidget *parent) :
    QWidget(parent)
{
    p = new ToDoPapersPrivate;

    p->base_wgt = new QWidget();
    p->base_layout = new QHBoxLayout(p->base_wgt);
    p->base_layout->setContentsMargins(8,8,8,8);
    p->base_layout->setSpacing(4);

    p->area = new QScrollArea();
    p->area->setWidget(p->base_wgt);

    p->layout = new QHBoxLayout(this);
    p->layout->addWidget(p->area);
    p->layout->setContentsMargins(0,0,0,0);
    p->layout->setSpacing(1);

    setStyleSheet( "QScrollArea{border: 0px solid transparent; background: transparent}" );
}

void ToDoPapers::setText(const QString &text)
{
    if( p->text == text )
        return;

    p->text = text;
    emit textChanged();
}

QString ToDoPapers::text() const
{
    return p->text;
}

ToDoPapers::~ToDoPapers()
{
    delete p;
}
