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

#include "kaqazmacros.h"

#ifdef DESKTOP_DEVICE
#include <QApplication>
#include "qtsingleapplication/qtsingleapplication.h"
#else
#include <QtGui/QGuiApplication>
#endif

#include "kaqaz.h"

#include <QFile>
#include <QIcon>
#include "resourcemanager.h"

int main(int argc, char *argv[])
{
#ifdef DESKTOP_DEVICE
    QtSingleApplication app(argc, argv);
#else
    QGuiApplication app(argc, argv);
#endif
    app.setApplicationName("Kaqaz");
    app.setApplicationDisplayName("Kaqaz");
    app.setOrganizationDomain("org.sialan.kaqaz");
    app.setOrganizationName("Sialan");
    app.setWindowIcon(QIcon(app.applicationDirPath()+"/qml/Kaqaz/files/kaqaz.png"));

#ifdef DESKTOP_DEVICE
    if( app.isRunning() )
    {
        app.sendMessage("show");
        return 0;
    }
#endif

    Kaqaz *kaqaz = Kaqaz::instance();
    if( !kaqaz->start() )
        return 0;

#ifdef DESKTOP_DEVICE
    QObject::connect( &app, SIGNAL(messageReceived(QString)), kaqaz, SLOT(incomingAppMessage(QString)) );
#endif

    return app.exec();
}
