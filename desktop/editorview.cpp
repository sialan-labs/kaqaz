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

#define PAPER_TOP 23
#define PAPER_LFT 22
#define PAPER_RGT 31
#define PAPER_BTM 41
#define PAPER_WDT 600
#define PAPER_HGT 836
#define PAPER_BRD 15
#define PAPER_SNC 4

#include "editorview.h"
#include "kaqaz.h"
#include "database.h"
#include "editorview.h"
#include "groupbutton.h"
#include "kaqazsync.h"

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
#include <QLinearGradient>
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
    bool synced;
};

EditorView::EditorView(QWidget *parent) :
    QWidget(parent)
{
    p = new EditorViewPrivate;
    p->save_timer = 0;
    p->paperId = 0;
    p->signal_blocker = false;
    p->synced = true;

    if( !back_image )
        back_image = new QImage(":/qml/Kaqaz/files/background.jpg");
    if( !papers_image )
        papers_image = new QImage(":/qml/Kaqaz/files/paper.png");

    p->title_font = Kaqaz::instance()->titleFont();
    p->body_font = Kaqaz::instance()->bodyFont();

    p->group_font.setFamily("Droid Kaqaz Sans");
    p->group_font.setPointSize(9);

    p->date_font.setFamily("Droid Kaqaz Sans");
    p->date_font.setPointSize(8);

    p->group = new GroupButton(this);
    p->group->move(25,PAPER_BRD-1);
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

    connect( Kaqaz::instance(), SIGNAL(titleFontChanged())          , SLOT(titleFontChanged())           );
    connect( Kaqaz::instance(), SIGNAL(bodyFontChanged())           , SLOT(bodyFontChanged())            );
    connect( Kaqaz::database(), SIGNAL(revisionChanged(QString,int)), SLOT(revisionChanged(QString,int)) );
    connect( Kaqaz::database(), SIGNAL(paperChanged(int))           , SLOT(paperChanged(int))            );
}

int EditorView::paperId() const
{
    return p->paperId;
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
    p->date->setText( "<font color=\"#888888\">" + Kaqaz::instance()->convertDateTimeToString(db->paperCreatedDate(pid)) + "</font>" );
    p->synced = (db->revisionOf(db->paperUuid(pid))!=-1);

    p->signal_blocker = false;
    update();
}

void EditorView::save()
{
    Database *db = Kaqaz::database();
    if( p->paperId == 0 )
        p->paperId = db->createPaper();

    db->setSignalBlocker(true);
    db->setPaper( p->paperId, p->title->text(), p->body->toPlainText(), p->group->group() );
    db->setSignalBlocker(false);

    emit saved(p->paperId);
}

void EditorView::delayedSave()
{
    if( p->signal_blocker )
        return;
    if( p->save_timer )
        killTimer(p->save_timer);

    p->save_timer = startTimer(1000);
}

void EditorView::titleFontChanged()
{
    p->title_font = Kaqaz::instance()->titleFont();
    p->title->setFont(p->title_font);
}

void EditorView::bodyFontChanged()
{
    p->body_font = Kaqaz::instance()->bodyFont();
    p->body->setFont(p->body_font);
}

void EditorView::revisionChanged(const QString &iid, int revision)
{
    if( !p->paperId )
        return;

    const QString & uuid = Kaqaz::database()->paperUuid(p->paperId);
    if( uuid != iid )
        return;

    p->synced = (revision!=-1);
    update();
}

void EditorView::paperChanged(int id)
{
    if( p->paperId != id )
        return;

    setPaper(p->paperId);
}

void EditorView::paintEvent(QPaintEvent *e)
{
    const QRect & rct = e->rect();
    QRect sourceRect;
    sourceRect.setX( back_image->width()/2-rct.width()/2+rct.x() );
    sourceRect.setY( back_image->height()/2-rct.height()/2+rct.y() );
    sourceRect.setWidth(rct.width());
    sourceRect.setHeight(rct.height());

    QPainter painter(this);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.drawImage( rct, *back_image, sourceRect );

    QRect tl_rct_src( 0, 0, PAPER_LFT, PAPER_TOP );
    QRect t_rct_src( PAPER_LFT, 0, PAPER_WDT-PAPER_LFT-PAPER_RGT, PAPER_TOP );
    QRect tr_rct_src( PAPER_WDT-PAPER_RGT, 0, PAPER_RGT, PAPER_TOP );
    QRect r_rct_src( PAPER_WDT-PAPER_RGT, PAPER_TOP, PAPER_RGT, PAPER_HGT-PAPER_TOP-PAPER_BTM );
    QRect br_rct_src( PAPER_WDT-PAPER_RGT, PAPER_HGT-PAPER_BTM, PAPER_RGT, PAPER_BTM );
    QRect b_rct_src( PAPER_LFT, PAPER_HGT-PAPER_BTM, PAPER_WDT-PAPER_LFT-PAPER_RGT, PAPER_BTM );
    QRect bl_rct_src( 0, PAPER_HGT-PAPER_BTM, PAPER_LFT, PAPER_BTM );
    QRect l_rct_src( 0, PAPER_TOP, PAPER_LFT, PAPER_HGT-PAPER_TOP-PAPER_BTM );

    QRect tl_rct_dst( 0, 0, PAPER_BRD, PAPER_BRD );
    QRect t_rct_dst( PAPER_BRD, 0, width()-2*PAPER_BRD, PAPER_BRD );
    QRect tr_rct_dst( width()-PAPER_BRD, 0, PAPER_BRD, PAPER_BRD );
    QRect r_rct_dst( width()-PAPER_BRD, PAPER_BRD, PAPER_BRD, height()-2*PAPER_BRD );
    QRect br_rct_dst( width()-PAPER_BRD, height()-PAPER_BRD, PAPER_BRD, PAPER_BRD );
    QRect b_rct_dst( PAPER_BRD, height()-PAPER_BRD, width()-2*PAPER_BRD, PAPER_BRD );
    QRect bl_rct_dst( 0, height()-PAPER_BRD, PAPER_BRD, PAPER_BRD );
    QRect l_rct_dst( 0, PAPER_BRD, PAPER_BRD, height()-2*PAPER_BRD );

    QRect paper_rect( PAPER_BRD, PAPER_BRD, width()-2*PAPER_BRD, height()-2*PAPER_BRD );
    QRect sync_rect( PAPER_BRD, height()-PAPER_BRD-PAPER_SNC, width()-2*PAPER_BRD, PAPER_SNC );

    painter.drawImage( tl_rct_dst, *papers_image, tl_rct_src );
    painter.drawImage( t_rct_dst , *papers_image, t_rct_src  );
    painter.drawImage( tr_rct_dst, *papers_image, tr_rct_src );
    painter.drawImage( r_rct_dst , *papers_image, r_rct_src  );
    painter.drawImage( br_rct_dst, *papers_image, br_rct_src );
    painter.drawImage( b_rct_dst , *papers_image, b_rct_src  );
    painter.drawImage( bl_rct_dst, *papers_image, bl_rct_src );
    painter.drawImage( l_rct_dst , *papers_image, l_rct_src  );

    painter.fillRect( paper_rect, "#EDEDED" );

    QLinearGradient gradient( QPoint(PAPER_BRD,height()-PAPER_BRD),
                              QPoint(width()-PAPER_BRD,height()-PAPER_BRD) );
    gradient.setColorAt(0.1, QColor(0,0,0,0));
    gradient.setColorAt(0.3, QColor(p->synced?"#50ab99":"#C51313"));
    gradient.setColorAt(0.7, QColor(p->synced?"#50ab99":"#C51313"));
    gradient.setColorAt(0.9, QColor(0,0,0,0));

    if( p->paperId && Kaqaz::instance()->kaqazSync()->tokenAvailable() )
        painter.fillRect( sync_rect, gradient );
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
    p->date->move(20, height()-PAPER_BRD-p->date->height());
}

EditorView::~EditorView()
{
    delete p;
}
