/*
    Copyright (C) 2014 Aseman
    http://aseman.co

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

#include "asemanquickview.h"
#include "asemandesktoptools.h"
#include "asemanqtlogger.h"
#include "asemandevices.h"
#include "asemantools.h"
#include "asemanapplication.h"
#include "asemanhashobject.h"
#include "asemanlistobject.h"
#include "asemancalendarconverter.h"
#include "asemanimagecoloranalizor.h"
#include "asemanbackhandler.h"
#include "asemancountriesmodel.h"
#ifdef Q_OS_ANDROID
#include "asemanjavalayer.h"
#endif
#ifdef DESKTOP_LINUX
#include "asemanmimeapps.h"
#endif
#ifdef ASEMAN_SENSORS
#include "asemansensors.h"
#endif
#ifdef ASEMAN_NOTIFICATION
#include "asemannotification.h"
#endif

#include <QPointer>
#include <QSharedPointer>
#include <QtQml>
#include <QQmlEngine>
#include <QQmlContext>
#include <QQuickItem>

class AsemanQuickViewPrivate
{
public:
    int options;

    AsemanDesktopTools *desktop;
    AsemanDevices *devices;
    AsemanQtLogger *logger;
    AsemanTools *tools;
#ifdef Q_OS_ANDROID
    AsemanJavaLayer *java_layer;
#endif
    AsemanCalendarConverter *calendar;
    AsemanBackHandler *back_handler;

    QPointer<QQuickItem> root;
    QPointer<QQuickItem> focused_text;

    bool fullscreen;
    int layoutDirection;
};

AsemanQuickView::AsemanQuickView(int options, QWindow *parent) :
    QQuickView(parent)
{
    p = new AsemanQuickViewPrivate;
    p->options = options;
    p->desktop = 0;
    p->devices = 0;
    p->logger = 0;
    p->tools = 0;
#ifdef Q_OS_ANDROID
    p->java_layer = 0;
#endif
    p->calendar = 0;
    p->back_handler = 0;
    p->fullscreen = false;
    p->layoutDirection = Qt::LeftToRight;

    engine()->rootContext()->setContextProperty( "SApp", AsemanApplication::instance() );
    engine()->rootContext()->setContextProperty( "View", this );

    qmlRegisterType<AsemanHashObject>("AsemanTools", 1,0, "HashObject");
    qmlRegisterType<AsemanListObject>("AsemanTools", 1,0, "ListObject");
    qmlRegisterType<AsemanImageColorAnalizor>("AsemanTools", 1,0, "ImageColorAnalizor");
    qmlRegisterType<AsemanCountriesModel>("AsemanTools", 1,0, "CountriesModel");
#ifdef DESKTOP_LINUX
    qmlRegisterType<AsemanMimeApps>("AsemanTools", 1,0, "MimeApps");
#endif
#ifdef ASEMAN_SENSORS
    qmlRegisterType<AsemanSensors>("AsemanTools", 1,0, "AsemanSensors");
#endif
#ifdef ASEMAN_NOTIFICATION
    qmlRegisterType<AsemanNotification>("AsemanTools", 1,0, "Notification");
#endif

    setResizeMode(QQuickView::SizeRootObjectToView);
    init_options();

    engine()->setImportPathList( QStringList()<< engine()->importPathList() << "qrc:///asemantools/qml" );

    engine()->rootContext()->setContextProperty("flickVelocity",
#ifdef DESKTOP_DEVICE
                                                2500
#else
                                                25000
#endif
                                                );
}

AsemanDesktopTools *AsemanQuickView::desktopTools() const
{
    return p->desktop;
}

AsemanDevices *AsemanQuickView::devices() const
{
    return p->devices;
}

AsemanQtLogger *AsemanQuickView::qtLogger() const
{
    return p->logger;
}

AsemanTools *AsemanQuickView::tools() const
{
    return p->tools;
}

#ifdef Q_OS_ANDROID
AsemanJavaLayer *AsemanQuickView::javaLayer() const
{
    return p->java_layer;
}
#endif

AsemanCalendarConverter *AsemanQuickView::calendar() const
{
    return p->calendar;
}

AsemanBackHandler *AsemanQuickView::backHandler() const
{
    return p->back_handler;
}

void AsemanQuickView::setFullscreen(bool stt)
{
    if( p->fullscreen == stt )
        return;

    p->fullscreen = stt;

    if( p->fullscreen )
        showFullScreen();
    else
        showNormal();

    emit fullscreenChanged();
    emit navigationBarHeightChanged();
    emit statusBarHeightChanged();
}

bool AsemanQuickView::fullscreen() const
{
    return p->fullscreen;
}

qreal AsemanQuickView::statusBarHeight() const
{
    if( !p->devices )
        return 0;

    return p->devices->transparentStatusBar() && !fullscreen()? 20*p->devices->density() : 0;
}

qreal AsemanQuickView::navigationBarHeight() const
{
    if( !p->devices )
        return 0;

    return p->devices->transparentNavigationBar() && !fullscreen()? 45*p->devices->density() : 0;
}

void AsemanQuickView::setRoot(QQuickItem *root)
{
    if( p->root == root )
        return;

    p->root = root;
    emit rootChanged();
}

QQuickItem *AsemanQuickView::root() const
{
    if( p->root )
        return p->root;

    return rootObject();
}

void AsemanQuickView::setFocusedText(QQuickItem *item)
{
    if( p->focused_text == item )
        return;
    if( p->focused_text )
        disconnect( p->focused_text, SIGNAL(destroyed()), this, SIGNAL(focusedTextChanged()) );

    p->focused_text = item;
    if( item )
    {
        connect( item, SIGNAL(destroyed()), this, SIGNAL(focusedTextChanged()) );
        if( p->devices )
            p->devices->showKeyboard();
    }
    else
    {
        if( p->devices )
            p->devices->hideKeyboard();
    }

    emit focusedTextChanged();
}

QQuickItem *AsemanQuickView::focusedText() const
{
    return p->focused_text;
}

int AsemanQuickView::layoutDirection() const
{
    return p->layoutDirection;
}

void AsemanQuickView::setLayoutDirection(int l)
{
    if( l == p->layoutDirection )
        return;

    p->layoutDirection = l;
    emit layoutDirectionChanged();
}

void AsemanQuickView::discardFocusedText()
{
    setFocusedText(0);
}

void AsemanQuickView::init_options()
{
    if( p->options & DesktopTools && !p->desktop )
    {
        p->desktop = new AsemanDesktopTools(this);
        engine()->rootContext()->setContextProperty( "Desktop", p->desktop );
    }
    if( p->options & Devices && !p->devices )
    {
        p->devices = new AsemanDevices(this);
        engine()->rootContext()->setContextProperty( "Devices", p->devices );

        engine()->rootContext()->setContextProperty( "physicalPlatformScale", p->devices->density());
        engine()->rootContext()->setContextProperty( "fontsScale", p->devices->fontDensity());
    }
    if( p->options & QtLogger && !p->logger )
    {
        p->logger = new AsemanQtLogger(AsemanApplication::logPath(),this);
        engine()->rootContext()->setContextProperty( "Logger", p->logger );
    }
    if( p->options & Tools && !p->tools )
    {
        p->tools = new AsemanTools(this);
        engine()->rootContext()->setContextProperty( "Tools", p->tools );
    }
#ifdef Q_OS_ANDROID
    if( p->options & JavaLayer && !p->java_layer )
    {
        p->java_layer = AsemanJavaLayer::instance();
        engine()->rootContext()->setContextProperty( "JavaLayer", p->java_layer );
    }
#endif
    if( p->options & Calendar && !p->calendar )
    {
        p->calendar = new AsemanCalendarConverter(this);
        engine()->rootContext()->setContextProperty( "CalendarConv", p->calendar );
    }
    if( p->options & BackHandler && !p->back_handler )
    {
        p->back_handler = new AsemanBackHandler(this);
        engine()->rootContext()->setContextProperty( "BackHandler", p->back_handler );
    }
}

AsemanQuickView::~AsemanQuickView()
{
    delete p;
}
