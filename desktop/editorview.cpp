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
#include "editorview.h"
#include "groupbutton.h"

#include <QTextEdit>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QLineEdit>
#include <QSplitter>
#include <QPainter>
#include <QPaintEvent>
#include <QCoreApplication>
#include <QTimerEvent>
#include <QLabel>
#include <QDebug>

static QImage *back_image = 0;
static QImage *papers_image = 0;

class EditorViewPrivate
{
public:
    QVBoxLayout *main_layout;
    QHBoxLayout *top_layout;

    QTextEdit *body;
    QLineEdit *title;
    GroupButton *group;
    QLabel *date;

    QFont title_font;
    QFont body_font;
    QFont group_font;
    QFont date_font;

    int paperId;
    int save_timer;
    bool signal_blocker;
};

EditorView::EditorView(QWidget *parent) :
    QWidget(parent)
{
    p = new EditorViewPrivate;
    p->save_timer = 0;
    p->paperId = 0;
    p->signal_blocker = false;

    if( !back_image )
        back_image = new QImage(":/qml/Kaqaz/files/background.jpg");
    if( !papers_image )
        papers_image = new QImage(":/qml/Kaqaz/files/paper.png");

    p->title_font.setFamily("Droid Kaqaz Sans");
    p->title_font.setPointSize(15);

    p->body_font.setFamily("Droid Kaqaz Sans");
    p->body_font.setPointSize(9);

    p->group_font.setFamily("Droid Kaqaz Sans");
    p->group_font.setPointSize(9);

    p->date_font.setFamily("Droid Kaqaz Sans");
    p->date_font.setPointSize(8);

    p->group = new GroupButton(this);
    p->group->move(25,12*(height()+20)/836);
    p->group->setFixedSize(110,30);
    p->group->setFont(p->group_font);

    p->title = new QLineEdit();
    p->title->setPlaceholderText( tr("Title") );
    p->title->setAlignment(Qt::AlignHCenter);
    p->title->setFont(p->title_font);
    p->title->setStyleSheet("QLineEdit{background: transparent; border: 0px solid translarent}");

    p->body = new QTextEdit();
    p->body->setPlaceholderText( tr("Text...") );
    p->body->setFont(p->body_font);
    p->body->setStyleSheet("QTextEdit{background: transparent; border: 0px solid translarent}");

    p->date = new QLabel(this);
    p->date->setFixedWidth(200);
    p->date->setFont(p->date_font);

    p->top_layout = new QHBoxLayout();
    p->top_layout->addSpacing(p->group->width());
    p->top_layout->addWidget(p->title);
    p->top_layout->addSpacing(p->group->width());
    p->top_layout->setContentsMargins(0,0,0,0);
    p->top_layout->setSpacing(0);

    p->main_layout = new QVBoxLayout(this);
    p->main_layout->addLayout(p->top_layout);
    p->main_layout->addWidget(p->body);
    p->main_layout->setContentsMargins(30,20,30,30);
    p->main_layout->setSpacing(0);

    setStyleSheet("QScrollBar:vertical { border: 0px solid transparent; background: transparent; max-width: 5px; min-width: 5px; }"
                  "QScrollBar::handle:vertical { border: 0px solid transparent; background: #aaaaaa; width: 5px; min-width: 5px; min-height: 30px }"
                  "QScrollBar::handle:hover { background: palette(highlight); }"
                  "QScrollBar::add-line:vertical { border: 0px solid transparent; background: transparent; height: 0px; subcontrol-position: bottom; subcontrol-origin: margin; }"
                  "QScrollBar::sub-line:vertical { border: 0px solid transparent; background: transparent; height: 0px; subcontrol-position: top; subcontrol-origin: margin; }" );

    connect( p->title, SIGNAL(textChanged(QString)), SLOT(delayedSave()) );
    connect( p->body , SIGNAL(textChanged())       , SLOT(delayedSave()) );
    connect( p->group, SIGNAL(groupSelected(int))  , SLOT(delayedSave()) );
}

void EditorView::setPaper(int pid)
{
    p->signal_blocker = true;

    p->paperId = pid;
    if( !p->paperId )
    {
        p->title->setText(QString());
        p->body->setText(QString());
        p->group->setGroup(0);
        p->date->setText(QString());
        p->signal_blocker = false;
        return;
    }

    Database *db = Kaqaz::database();
    p->title->setText( db->paperTitle(pid) );
    p->body->setText( db->paperText(pid) );
    p->group->setGroup( db->paperGroup(pid) );
    p->date->setText( "<font color=\"#888888\">" + db->paperCreatedDate(pid).toString() + "</font>" );

    p->signal_blocker = false;
}

void EditorView::save()
{
    Database *db = Kaqaz::database();
    if( p->paperId == 0 )
        p->paperId = db->createPaper();

    db->setPaper( p->paperId, p->title->text(), p->body->toPlainText(), p->group->group() );
}

void EditorView::delayedSave()
{
    if( p->signal_blocker )
        return;
    if( p->save_timer )
        killTimer(p->save_timer);

    p->save_timer = startTimer(1000);
}

void EditorView::paintEvent(QPaintEvent *e)
{
    const QRect & rct = e->rect();
    QRect sourceRect;
    sourceRect.setX( back_image->width()/2-rct.width()/2+rct.x() );
    sourceRect.setY( back_image->height()/2-rct.height()/2+rct.y() );
    sourceRect.setWidth(rct.width());
    sourceRect.setHeight(rct.height());

    QRect paperRect = papers_image->rect();
    paperRect.setX(10);
    paperRect.setY(10);
    paperRect.setWidth( paperRect.width()-20 );
    paperRect.setHeight( paperRect.height()-20 );

    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.drawImage( rct, *back_image, sourceRect );
    painter.drawImage( rect(), *papers_image, paperRect );
}

void EditorView::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->save_timer )
    {
        killTimer(p->save_timer);
        p->save_timer = 0;

        save();
    }

    QWidget::timerEvent(e);
}

void EditorView::resizeEvent(QResizeEvent *e)
{
    Q_UNUSED(e)
    p->group->move(25,12*(height()+20)/836);
    p->date->move(20, height()-15-p->date->height());
}

EditorView::~EditorView()
{
    delete p;
}
