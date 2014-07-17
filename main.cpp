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
#else
#include <QtGui/QGuiApplication>
#endif

#include "kaqaz.h"

#include <QFile>
#include "resourcemanager.h"

int main(int argc, char *argv[])
{
#ifdef DESKTOP_DEVICE
    QApplication app(argc, argv);
#else
    QGuiApplication app(argc, argv);
#endif

    Kaqaz kaqaz;
    kaqaz.start();

    return app.exec();
}
