#ifndef ICONPROVIDER_H
#define ICONPROVIDER_H

#include <QQuickImageProvider>
#include <QFileIconProvider>

class IconProvider : public QQuickImageProvider
{
public:
    IconProvider();
    ~IconProvider();

    QPixmap requestPixmap( const QString & id, QSize * size, const QSize & requestedSize );

private:
    QFileIconProvider provider;
};

#endif // ICONPROVIDER_H
