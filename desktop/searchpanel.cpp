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

#include "searchpanel.h"
#include "kaqaz.h"
#include "database.h"
#include "datewidget.h"
#include "categoriesmodel.h"

#include <QLabel>
#include <QLineEdit>
#include <QComboBox>
#include <QLine>
#include <QCheckBox>
#include <QPaintEvent>
#include <QPainter>
#include <QVBoxLayout>
#include <QPushButton>
#include <QTimerEvent>

class SearchPanelPrivate
{
public:
    QVBoxLayout *layout;

    QLabel *keyword_label;
    QLineEdit *keyword_line;

    QLabel *date_label;
    DateWidget *date_from;
    DateWidget *date_to;
    QPushButton *date_btn;

    QLabel *time_label;
    DateWidget *time_from;
    DateWidget *time_to;
    QPushButton *time_btn;

    QLabel *group_label;
    QComboBox *group_combo;
    CategoriesModel *group_model;

    QLabel *type_label;
    QComboBox *type_combo;

    int search_timer;
};

SearchPanel::SearchPanel(QWidget *parent) :
    QWidget(parent)
{
    p = new SearchPanelPrivate;
    p->search_timer = 0;

    p->keyword_label = new QLabel();
    p->keyword_label->setText( "<font color=\"#ffffff\">" + tr("Keyword") + "</font>" );

    p->keyword_line = new QLineEdit();
    p->keyword_line->setPlaceholderText(tr("keyword"));

    p->date_label = new QLabel();
    p->date_label->setText( "<font color=\"#ffffff\">" + tr("Date Domain") + "</font>" );

    p->date_btn = new QPushButton();
    p->date_btn->setText( tr("Select Date") );

    p->time_label = new QLabel();
    p->time_label->setText( "<font color=\"#ffffff\">" + tr("Time Domain") + "</font>" );

    p->time_btn = new QPushButton();
    p->time_btn->setText( tr("Select Time") );

    p->group_label = new QLabel();
    p->group_label->setText( "<font color=\"#ffffff\">" + tr("Label") + "</font>" );

    p->group_model = new CategoriesModel(Kaqaz::database(),this);
    p->group_combo = new QComboBox();
    p->group_combo->setModel(p->group_model);

    p->type_label = new QLabel();
    p->type_label->setText( "<font color=\"#ffffff\">" + tr("Paper Type") + "</font>" );

    p->type_combo = new QComboBox();
    p->type_combo->addItem( tr("All Papers") );
    p->type_combo->addItem( tr("Normal Papers") );
    p->type_combo->addItem( tr("To-Do Papers") );
    p->type_combo->addItem( tr("Completed tasks") );
    p->type_combo->addItem( tr("Uncompleted tasks") );

    p->layout = new QVBoxLayout(this);
    p->layout->addSpacing(10);
    p->layout->addWidget(p->keyword_label);
    p->layout->addWidget(p->keyword_line);
    p->layout->addSpacing(30);
    p->layout->addWidget(p->date_label);
    p->layout->addWidget(p->date_btn);
    p->layout->addSpacing(10);
    p->layout->addWidget(p->time_label);
    p->layout->addWidget(p->time_btn);
    p->layout->addSpacing(10);
    p->layout->addWidget(p->group_label);
    p->layout->addWidget(p->group_combo);
    p->layout->addSpacing(10);
    p->layout->addWidget(p->type_label);
    p->layout->addWidget(p->type_combo);
    p->layout->addStretch();
    p->layout->setContentsMargins(4,4,4,4);
    p->layout->setSpacing(1);

    setStyleSheet( "QLineEdit{ background: #ffffff; border-radius: 3px; border: 1px solid #888888; color: palette(text); min-height: 24px }"
                   "QLineEdit:hover{ border-color: palette(highlight) }"
                   "QLineEdit:focus{ border-color: palette(highlight) }");

    connect( p->keyword_line, SIGNAL(textChanged(QString)), SLOT(keyword_changed()) );
}

void SearchPanel::refreshResult()
{
    const QString & kwd = p->keyword_line->text();
    if( kwd.isEmpty() )
    {
        emit founded( QList<int>() );
        return;
    }

    QList<int> result = Kaqaz::database()->search(kwd);
    for( int i=0; i<result.count()/2; i++ )
        result.swap( i, result.count()-i-1 );

    emit founded(result);
}

void SearchPanel::keyword_changed()
{
    if( p->search_timer )
        killTimer(p->search_timer);

    p->search_timer = startTimer(500);
}

void SearchPanel::paintEvent(QPaintEvent *e)
{
    QPainter painter(this);
    painter.fillRect(e->rect(),"#333333");
}

void SearchPanel::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->search_timer )
    {
        killTimer(p->search_timer);
        p->search_timer = 0;
        refreshResult();
    }

    QWidget::timerEvent(e);
}

SearchPanel::~SearchPanel()
{
    delete p;
}
