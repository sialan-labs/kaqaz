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
