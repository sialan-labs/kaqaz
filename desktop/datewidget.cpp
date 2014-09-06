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

#include "datewidget.h"
#include "kaqaz.h"
#include "calendarconverter.h"

#include <QHBoxLayout>
#include <QVBoxLayout>
#include <QSpinBox>
#include <QLabel>

class DateWidgetPrivate
{
public:
    bool dateVisible;
    bool timeVisible;
    QDateTime dateTime;

    QSpinBox *year_spin;
    QSpinBox *month_spin;
    QSpinBox *day_spin;

    QSpinBox *hour_spin;
    QSpinBox *minute_spin;

    QLabel *date_label;
    QLabel *time_label;

    QHBoxLayout *main_layout;
    QVBoxLayout *date_layout;
    QVBoxLayout *time_layout;
    QHBoxLayout *date_items_layout;
    QHBoxLayout *time_items_layout;
};

DateWidget::DateWidget(QWidget *parent) :
    QWidget(parent)
{
    p = new DateWidgetPrivate;
    p->dateVisible = true;
    p->timeVisible = true;

    p->year_spin = new QSpinBox();
    p->month_spin = new QSpinBox();
    p->day_spin = new QSpinBox();

    p->hour_spin = new QSpinBox();
    p->minute_spin = new QSpinBox();

    p->date_label = new QLabel();
    p->date_label->setText( "<center><b>" + tr("Date") + "</b></center>" );

    p->time_label = new QLabel();
    p->time_label->setText( "<center><b>" + tr("Time") + "</b></center>" );

    p->date_items_layout = new QHBoxLayout();
    p->date_items_layout->addWidget(p->year_spin);
    p->date_items_layout->addWidget(p->month_spin);
    p->date_items_layout->addWidget(p->day_spin);
    p->date_items_layout->setContentsMargins(0,0,0,0);
    p->date_items_layout->setSpacing(1);

    p->time_items_layout = new QHBoxLayout();
    p->time_items_layout->addWidget(p->hour_spin);
    p->time_items_layout->addWidget(p->minute_spin);
    p->time_items_layout->setContentsMargins(0,0,0,0);
    p->time_items_layout->setSpacing(1);

    p->date_layout = new QVBoxLayout();
    p->date_layout->addWidget(p->date_label);
    p->date_layout->addLayout(p->date_items_layout);
    p->date_layout->setContentsMargins(0,0,0,0);
    p->date_layout->setSpacing(1);

    p->time_layout = new QVBoxLayout();
    p->time_layout->addWidget(p->time_label);
    p->time_layout->addLayout(p->time_items_layout);
    p->time_layout->setContentsMargins(0,0,0,0);
    p->time_layout->setSpacing(1);

    p->main_layout = new QHBoxLayout(this);
    p->main_layout->addLayout(p->date_layout);
    p->main_layout->addLayout(p->time_layout);
    p->main_layout->setContentsMargins(0,0,0,0);
    p->main_layout->setSpacing(15);

    setDateTime( QDateTime::currentDateTime() );

    connect( p->year_spin , SIGNAL(valueChanged(int)), SLOT(refresh_days()) );
    connect( p->month_spin, SIGNAL(valueChanged(int)), SLOT(refresh_days()) );
}

void DateWidget::setDateVisible(bool stt)
{
    p->dateVisible = stt;
    p->year_spin->setVisible(p->dateVisible);
    p->month_spin->setVisible(p->dateVisible);
    p->day_spin->setVisible(p->dateVisible);
    p->date_label->setVisible(p->dateVisible);
}

bool DateWidget::dateVisible() const
{
    return p->dateVisible;
}

void DateWidget::setTimeVisible(bool stt)
{
    p->timeVisible = stt;
    p->hour_spin->setVisible(p->timeVisible);
    p->minute_spin->setVisible(p->timeVisible);
    p->time_label->setVisible(p->timeVisible);
}

bool DateWidget::timeVisible() const
{
    return p->timeVisible;
}

QDateTime DateWidget::dateTime() const
{
    Kaqaz *kqz = Kaqaz::instance();
    const QDate & date = kqz->convertDateToGragorian( p->year_spin->value(), p->month_spin->value(),
                                                      p->day_spin->value() );

    const QTime & time = QTime( p->hour_spin->value(), p->minute_spin->value() );

    return QDateTime(date,time);
}

void DateWidget::setDateTime(const QDateTime &dt)
{
    Kaqaz *kqz = Kaqaz::instance();
    const DateProperty & pr = kqz->convertDate(dt.date());

    int year = kqz->currentYear();

    p->year_spin->setMinimum( year-100 );
    p->year_spin->setMaximum( year+100 );
    p->year_spin->setValue(pr.year);

    p->month_spin->setMinimum(1);
    p->month_spin->setMaximum(12);
    p->month_spin->setValue(pr.month);

    p->day_spin->setMinimum(1);
    p->day_spin->setValue(pr.day);

    p->hour_spin->setMinimum(0);
    p->hour_spin->setMaximum(23);
    p->hour_spin->setValue(dt.time().hour());

    p->minute_spin->setMinimum(0);
    p->minute_spin->setMaximum(59);
    p->minute_spin->setValue(dt.time().minute());
}

void DateWidget::refresh_days()
{
    Kaqaz *kqz = Kaqaz::instance();
    p->day_spin->setMaximum( kqz->daysOfMonth(p->year_spin->value(),p->month_spin->value()) );
}

DateWidget::~DateWidget()
{
    delete p;
}
