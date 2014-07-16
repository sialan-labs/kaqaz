#include "iconprovider.h"

#include <QHash>
#include <QIcon>
#include <QPainter>

QHash<QString,QPixmap> provider_pixmap_hash;

IconProvider::IconProvider() :
    QQuickImageProvider( QQuickImageProvider::Pixmap )
{
}

QPixmap IconProvider::requestPixmap( const QString & id, QSize *size, const QSize & requestedSize )
{
    int width  = 22;
    int height = 22;

    if (size)
        *size = QSize(width, height);

    QIcon icon;
    if( id.contains("/") )
        icon = QIcon(id);
    else
        icon = QIcon::fromTheme(id);

    QPixmap pixmap = icon.pixmap( requestedSize.width() > 0 ? requestedSize.width() : width,
                                                  requestedSize.height() > 0 ? requestedSize.height() : height );

    return pixmap;
}

IconProvider::~IconProvider()
{
}
