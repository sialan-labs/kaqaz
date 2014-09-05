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

#include "editorview.h"
#include "kaqaz.h"
#include "database.h"

#include <QTextEdit>
#include <QVBoxLayout>
#include <QLineEdit>
#include <QSplitter>
#include <QPainter>
#include <QPaintEvent>
#include <QCoreApplication>

class EditorViewPrivate
{
public:
    QVBoxLayout *main_layout;
    QTextEdit *body;
    QLineEdit *title;

    QImage back_image;
    QImage papers_image;

    QFont title_font;
    QFont body_font;

    int paperId;
};

EditorView::EditorView(QWidget *parent) :
    QWidget(parent)
{
    p = new EditorViewPrivate;
    p->paperId = 0;
    p->back_image = QImage(":/qml/Kaqaz/files/background.jpg");
    p->papers_image = QImage(":/qml/Kaqaz/files/paper.png");

    p->title_font.setFamily("Droid Kaqaz Sans");
    p->title_font.setPointSize(15);

    p->body_font.setFamily("Droid Kaqaz Sans");
    p->body_font.setPointSize(9);

    p->title = new QLineEdit();
    p->title->setPlaceholderText( tr("Title") );
    p->title->setAlignment(Qt::AlignHCenter);
    p->title->setFont(p->title_font);
    p->title->setStyleSheet("QLineEdit{background: transparent; border: 0px solid translarent}");

    p->body = new QTextEdit();
    p->body->setPlaceholderText( tr("Text...") );
    p->body->setFont(p->body_font);
    p->body->setStyleSheet("QTextEdit{background: transparent; border: 0px solid translarent}");

    p->main_layout = new QVBoxLayout(this);
    p->main_layout->addWidget(p->title);
    p->main_layout->addWidget(p->body);
    p->main_layout->setContentsMargins(20,20,20,20);
    p->main_layout->setSpacing(0);
}

void EditorView::setPaper(int id)
{
    Database *db = Kaqaz::database();
    p->title->setText( db->paperTitle(id) );
    p->body->setText( db->paperText(id) );
}

void EditorView::paintEvent(QPaintEvent *e)
{
    const QRect & rct = e->rect();
    QRect sourceRect;
    sourceRect.setX( p->back_image.width()/2-rct.width()/2+rct.x() );
    sourceRect.setY( p->back_image.height()/2-rct.height()/2+rct.y() );
    sourceRect.setWidth(rct.width());
    sourceRect.setHeight(rct.height());

    QRect paperRect = p->papers_image.rect();
    paperRect.setX(10);
    paperRect.setY(10);
    paperRect.setWidth( paperRect.width()-20 );
    paperRect.setHeight( paperRect.height()-20 );

    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.drawImage( rct, p->back_image, sourceRect );
    painter.drawImage( rect(), p->papers_image, paperRect );
}

EditorView::~EditorView()
{
    delete p;
}
