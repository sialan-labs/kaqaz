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

#include "paperfilesview.h"
#include "paperfilesmodel.h"
#include "kaqaz.h"
#include "database.h"

#include <QListView>
#include <QVBoxLayout>
#include <QPaintEvent>
#include <QPainter>
#include <QToolButton>
#include <QDesktopServices>
#include <QFileDialog>
#include <QMessageBox>
#include <QMenu>

class PaperFilesViewPrivate
{
public:
    QListView *view;
    QVBoxLayout *layout;
    QHBoxLayout *title_layout;

    QToolButton *close_btn;

    PaperFilesModel *model;

    int paperId;
};

PaperFilesView::PaperFilesView(QWidget *parent) :
    QWidget(parent)
{
    p = new PaperFilesViewPrivate;
    p->paperId = 0;

    p->model = new PaperFilesModel(Kaqaz::database(),this);
    p->view = new QListView();
    p->view->setModel(p->model);
    p->view->setContextMenuPolicy(Qt::CustomContextMenu);

    p->close_btn = new QToolButton();
    p->close_btn->setAutoRaise(true);
    p->close_btn->setIcon( QIcon(":/qml/Kaqaz/files/back_64.png") );
    p->close_btn->setFixedSize(24,24);

    p->title_layout = new QHBoxLayout();
    p->title_layout->addWidget(p->close_btn);
    p->title_layout->addStretch();
    p->title_layout->setContentsMargins(4,4,4,4);
    p->title_layout->setSpacing(1);

    p->layout = new QVBoxLayout(this);
    p->layout->addLayout(p->title_layout);
    p->layout->addWidget(p->view);
    p->layout->setContentsMargins(0,0,0,0);
    p->layout->setSpacing(1);

    setStyleSheet("QListView{ background: transparent; border: 0px solid transparent }"
                  "QListView::item{ color: #333333; padding: 4px }"
                  "QListView::item:selected{ background: palette(highlight); color: #ffffff }" );

    connect( p->view, SIGNAL(clicked(QModelIndex))              , SLOT(fileClicked(QModelIndex))       );
    connect( p->view, SIGNAL(doubleClicked(QModelIndex))        , SLOT(fileDoubleClicked(QModelIndex)) );
    connect( p->view, SIGNAL(customContextMenuRequested(QPoint)), SLOT(showFileMenu())                 );

    connect( p->close_btn, SIGNAL(clicked()), SLOT(hide()) );
}

void PaperFilesView::setPaper(int pid)
{
    p->model->setPaper(pid);
}

int PaperFilesView::paper() const
{
    return p->model->paper();
}

void PaperFilesView::fileClicked(const QModelIndex &idx)
{
    Q_UNUSED(idx)
}

void PaperFilesView::fileDoubleClicked(const QModelIndex &idx)
{
    const QString & path = p->model->pathOf(idx);
    const QString & cache = Kaqaz::instance()->cacheFile(path);
    QDesktopServices::openUrl(cache);
}

void PaperFilesView::showFileMenu()
{
    QModelIndex idx = p->view->indexAt( p->view->mapFromGlobal(QCursor::pos()) );
    const int row = idx.row();
    if( !idx.isValid() )
        return;

    QMenu menu;
    QAction *open = menu.addAction( QIcon::fromTheme("fileopen"), tr("Open File") );
    QAction *copy = menu.addAction( QIcon::fromTheme("edit-copy"), tr("Copy To") );
    QAction *dlte = menu.addAction( QIcon::fromTheme("edit-delete"), tr("Delete") );
    QAction *res  = menu.exec( QCursor::pos() );

    if( !res )
        return;

    const QString & fileId = p->model->id(row);
    const QString & filePath = p->model->pathOf(idx);
    if( res == open )
    {
        fileDoubleClicked(idx);
    }
    if( res == copy )
    {
        const QString & dest = QFileDialog::getExistingDirectory(Kaqaz::instance()->view());
        if( dest.isEmpty() )
            return;

        QFile::copy(filePath,dest+"/"+QFileInfo(filePath).fileName());
    }
    if( res == dlte )
    {
        Database *db = Kaqaz::database();
        int del = QMessageBox::warning(this, tr("Delete File"), tr("Do you realy want to delete selected file?"), QMessageBox::Yes|QMessageBox::No);
        if( del == QMessageBox::Yes )
            db->removeFileFromPaper(p->paperId, fileId);
    }
}

void PaperFilesView::paintEvent(QPaintEvent *e)
{
    QPainter painter(this);
    painter.fillRect(e->rect(), QColor(200,200,200,230));
}

PaperFilesView::~PaperFilesView()
{
    delete p;
}
