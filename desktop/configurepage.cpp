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

#include "configurepage.h"
#include "ui_configurepage.h"
#include "kaqaz.h"
#include "kaqazmacros.h"
#include "backuper.h"
#include "kaqazsync.h"
#include "database.h"
#include "sialantools/sialancalendarconverter.h"
#include "sialantools/sialantools.h"

#include <QSettings>
#include <QDir>
#include <QFileSystemModel>
#include <QCloseEvent>
#include <QInputDialog>
#include <QMessageBox>
#include <QFileDialog>
#include <QFile>
#include <QDebug>

class ConfigurePagePrivate
{
public:
    Ui::ConfigurePage *ui;
    QSettings *settings;
    Kaqaz *kqz;

    QFileSystemModel *backups_model;

    bool signal_blocker;
    bool backuper_started;
};

ConfigurePage::ConfigurePage(QWidget *parent) :
    QDialog(parent)
{
    p = new ConfigurePagePrivate;
    p->signal_blocker = false;
    p->kqz = Kaqaz::instance();
    p->settings = Kaqaz::settings();
    p->backuper_started = false;

    QDir().mkpath(BACKUP_PATH);

    p->backups_model = new QFileSystemModel(this);
    p->backups_model->setRootPath(BACKUP_PATH);
    p->backups_model->setFilter( QDir::Files );

    p->ui = new Ui::ConfigurePage;
    p->ui->setupUi(this);

#ifdef Q_OS_MAC
    p->ui->ui_combo->setCurrentIndex(0);
#else
    p->ui->ui_combo->setVisible(false);
    p->ui->ui_lbl->setVisible(false);
#endif

    p->ui->restore_list->setModel(p->backups_model);
    p->ui->restore_list->setRootIndex(p->backups_model->index(BACKUP_PATH));

    p->ui->backup_pbar->hide();

    Backuper *bkpr = p->kqz->backuper();
    connect( bkpr, SIGNAL(progress(int)), SLOT(backupProgress(int)) );
    connect( bkpr, SIGNAL(failed())     , SLOT(backupFailed())      );
    connect( bkpr, SIGNAL(success())    , SLOT(backupFinished())    );

    connect( p->kqz->kaqazSync(), SIGNAL(authorizeRequest()), SLOT(syncAuthorizeRequest()) );

    refresh();
}

void ConfigurePage::refresh()
{
    p->signal_blocker = true;

    p->ui->calendar_combo->clear();
    const QStringList & cals = p->kqz->calendarsID();
    const int current_calendar = p->kqz->calendar();
    foreach( const QString & calId, cals )
    {
        const int cid = calId.toInt();
        p->ui->calendar_combo->addItem( p->kqz->calendarConverter()->calendarName(cid), cid );
        if( cid == current_calendar )
            p->ui->calendar_combo->setCurrentIndex( p->ui->calendar_combo->count()-1 );
    }

    p->ui->language_combo->clear();
    const QStringList & langs = p->kqz->languages();
    const QString current_lang = p->kqz->currentLanguage();
    foreach( const QString & lang, langs )
    {
        p->ui->language_combo->addItem(lang);
        if( lang == current_lang )
            p->ui->language_combo->setCurrentIndex( p->ui->language_combo->count()-1 );
    }

    p->ui->titlefont_combo->setCurrentFont( p->kqz->titleFont() );
    p->ui->titlefont_spin->setValue( p->kqz->titleFont().pointSize() );

    p->ui->bodyfont_combo->setCurrentFont( p->kqz->bodyFont() );
    p->ui->bodyfont_spin->setValue( p->kqz->bodyFont().pointSize() );

    p->ui->dropbox_finish_wgt->setVisible( false );
    p->ui->dropbox_token_btn->setVisible( !p->kqz->kaqazSync()->tokenAvailable() );
    p->ui->dropbox_dc_btn->setVisible( p->kqz->kaqazSync()->tokenAvailable() );

    p->ui->security_cpass->setVisible( !p->kqz->database()->password().isEmpty() );

    p->signal_blocker = false;
}

void ConfigurePage::uiChanged(int row)
{
    Kaqaz::instance()->setDesktopTouchMode(row);
}

void ConfigurePage::calendarChanged(int id)
{
    if( p->signal_blocker )
        return;

    p->kqz->setCalendar( p->ui->calendar_combo->itemData(id).toInt() );
}

void ConfigurePage::languageChanged(int id)
{
    Q_UNUSED(id)
    if( p->signal_blocker )
        return;

    p->kqz->setCurrentLanguage( p->ui->language_combo->currentText() );
}

void ConfigurePage::titleFontChanged()
{
    if( p->signal_blocker )
        return;

    QFont fnt = p->ui->titlefont_combo->currentFont();
    fnt.setPointSize( p->ui->titlefont_spin->value() );

    p->kqz->setTitleFont(fnt);
}

void ConfigurePage::bodyFontChanged()
{
    if( p->signal_blocker )
        return;

    QFont fnt = p->ui->bodyfont_combo->currentFont();
    fnt.setPointSize( p->ui->bodyfont_spin->value() );

    p->kqz->setBodyFont(fnt);
}

void ConfigurePage::makeBackup()
{
    const QString & pass = p->kqz->database()->password();
    if( !pass.isEmpty() )
    {
        const QString & input = QInputDialog::getText( this, tr("Password"), tr("Please enter password"), QLineEdit::Password );
        if( input.isEmpty() )
            return;

        if( pass != SialanTools::passToMd5(input) )
            return;
    }

    p->kqz->backuper()->makeBackup(pass);
}

void ConfigurePage::restoreSelected()
{
    const QModelIndex & idx = p->ui->restore_list->currentIndex();
    if( !idx.isValid() )
        return;

    const QString & path = p->backups_model->filePath(idx);
    int del = QMessageBox::warning(this, tr("Restore"), tr("Do you realy want to restore? all of your current data will be deleted."), QMessageBox::Yes|QMessageBox::No);
    if( del == QMessageBox::No )
        return;

    bool first_try = p->kqz->backuper()->restore(path);
    if( !first_try )
    {
        const QString & pass = QInputDialog::getText( this, tr("Password"), tr("Please enter password"), QLineEdit::Password );
        if( pass.isEmpty() )
            return;

        p->kqz->backuper()->restore( path, SialanTools::passToMd5(pass) );
    }
}

void ConfigurePage::deleteBackup()
{
    const QModelIndex & idx = p->ui->restore_list->currentIndex();
    if( !idx.isValid() )
        return;

    const QString & path = p->backups_model->filePath(idx);
    int del = QMessageBox::warning(this, tr("Delete Backup"), tr("Do you realy want to delete selected backup?"), QMessageBox::Yes|QMessageBox::No);
    if( del == QMessageBox::No )
        return;

    QFile::remove(path);
}

void ConfigurePage::copyBackup()
{
    const QModelIndex & idx = p->ui->restore_list->currentIndex();
    if( !idx.isValid() )
        return;

    const QString & path = p->backups_model->filePath(idx);
    const QString & dest = QFileDialog::getExistingDirectory(this);
    if( dest.isEmpty() )
        return;

    QFileInfo inf(path);
    QFile::copy( path, dest + "/" + inf.fileName() );
}

void ConfigurePage::backupProgress(int percent)
{
    p->backuper_started = true;
    p->ui->backuper_wgt->setDisabled(true);
    p->ui->backup_pbar->show();
    p->ui->backup_pbar->setValue(percent);
}

void ConfigurePage::backupFailed()
{
    p->backuper_started = false;
    p->ui->backuper_wgt->setDisabled(false);
    p->ui->backup_pbar->hide();
    p->ui->backup_pbar->setValue(0);
}

void ConfigurePage::backupFinished()
{
    p->backuper_started = false;
    p->ui->backuper_wgt->setDisabled(false);
    p->ui->backup_pbar->hide();
    p->ui->backup_pbar->setValue(0);
}

void ConfigurePage::getToken()
{
    KaqazSync *sync = p->kqz->kaqazSync();
    if( sync->tokenAvailable() )
        return;

    sync->start();
    p->ui->dropbox_token_btn->setDisabled(true);
    p->ui->dropbox_token_btn->setText( tr("Please Wait") );
}

void ConfigurePage::syncAuthorizeRequest()
{
    p->ui->dropbox_token_btn->setVisible(false);
    p->ui->dropbox_finish_wgt->setVisible(true);
}

void ConfigurePage::syncLoginFinished()
{
    KaqazSync *sync = p->kqz->kaqazSync();
    sync->authorizeDone();
    sync->refresh();
    refresh();
}

void ConfigurePage::syncDisconnect()
{
    KaqazSync *sync = p->kqz->kaqazSync();
    sync->stop();
}

void ConfigurePage::changePassword()
{
    Database *db = p->kqz->database();
    const QString & cpass = db->password();
    if( !cpass.isEmpty() )
    {
        const QString & dlg_cpass = p->ui->security_cpass->text();
        if( cpass != SialanTools::passToMd5(dlg_cpass) )
        {
            QMessageBox::critical(this, tr("Incorrect"), tr("Current password is incorrect!") );
            return;
        }
    }

    const QString & dlg_pass  = p->ui->security_pass->text();
    const QString & dlg_rpass = p->ui->security_pass_repeat->text();
    if( dlg_pass != dlg_rpass )
    {
        QMessageBox::critical(this, tr("Incorrect repeat"), tr("Password repeat is incorrect!") );
        return;
    }

    db->setPassword( SialanTools::passToMd5(dlg_pass) );

    p->ui->security_cpass->clear();
    p->ui->security_pass->clear();
    p->ui->security_pass_repeat->clear();

    QMessageBox::information(this, tr("Successfully"), tr("Password changed successfully :)"));

    refresh();
}

void ConfigurePage::closeEvent(QCloseEvent *e)
{
    if( p->backuper_started )
        e->ignore();
    else
        QDialog::closeEvent(e);
}

ConfigurePage::~ConfigurePage()
{
    delete p->ui;
    delete p;
}
