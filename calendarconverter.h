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

#ifndef CALENDARCONVERTER_H
#define CALENDARCONVERTER_H

#include <QString>
#include <QDate>
#include <QDateTime>

class DateProperty
{
public:
    int day;
    int month;
    qint64 year;
    int day_of_week;
};

class CalendarConverterPrivate;
class CalendarConverter
{
public:
    CalendarConverter();
    ~CalendarConverter();

    enum CalendarTypes{
        Gregorian,
        Jalali,
        Hijri
    };

    void setCalendar( CalendarTypes t );
    CalendarTypes calendar() const;

    QString paperString(const QDateTime &d );
    QString historyString( const QDate & d );
    QString numberString( const QDate & d );

    DateProperty getDate( const QDate & d );
    QDate toDate( qint64 year, int month, int day );

    QString dayName( int d );
    QString monthName( int m );

    bool yearIsLeap( qint64 year );
    int daysOfMonth( qint64 year, int month );

private:
    qint64 fromDateGregorian( qint64 year , int month , int day );
    DateProperty toDateGregorian( qint64 days_from_julian_zero );
    bool isLeapGregorian( qint64 year );
    QString monthNamesGregorian(int m);
    QString dayNameGregorian( int d );

    qint64 fromDateJalali( qint64 year , int month , int day );
    DateProperty toDateJalali( qint64 days_from_julian_zero );
    bool isLeapJalali( qint64 year );
    QString monthNamesJalali(int m);
    QString dayNameJalali( int d );

    qint64 fromDateHijri( qint64 year , int month , int day );
    DateProperty toDateHijri( qint64 days_from_hijri_zero );
    qint64 leapsNumberHijri( qint64 year );
    int leapIndexHijri( qint64 year );
    QString monthNamesHijri(int m);
    QString dayNameHijri( int d );

private:
    CalendarConverterPrivate *p;
};

#endif // CALENDARCONVERTER_H
