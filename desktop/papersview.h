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

#ifndef PAPERSVIEW_H
#define PAPERSVIEW_H

#include <QListView>

class Database;
class PapersViewPrivate;
class PapersView : public QListView
{
    Q_OBJECT
public:
    PapersView(Database *db, QWidget *parent = 0);
    ~PapersView();

public slots:
    void showPapers( const QList<int> & papers );

signals:
    void paperSelected( int pid );
    void paperOpened( int pid );

private slots:
    void paper_selected( const QModelIndex & idx );
    void paper_opened( const QModelIndex & idx );

private:
    PapersViewPrivate *p;
};

#endif // PAPERSVIEW_H
