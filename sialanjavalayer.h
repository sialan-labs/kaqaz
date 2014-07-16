#ifndef SIALANJAVALAYER_H
#define SIALANJAVALAYER_H

#include <QObject>

class SialanJavaLayerPrivate;
class SialanJavaLayer : public QObject
{
    Q_OBJECT
public:
    SialanJavaLayer( QObject *parent = 0 );
    ~SialanJavaLayer();

    bool sharePaper( const QString & title, const QString & msg );
    bool openFile( const QString & path, const QString & type );
    bool startCamera( const QString & output );
    bool getOpenPictures();

    bool transparentStatusBar();

    int densityDpi();
    int getSizeName();
    bool isTablet();
    qreal density();

signals:
    void incomingShare( const QString & title, const QString & msg );
    void incomingImage( const QString & path );
    void selectImageResult( const QString & path );
    void activityPaused();
    void activityStopped();
    void activityResumed();
    void activityStarted();
    void activityRestarted();

private slots:
    void load_buffer();

private:
    SialanJavaLayerPrivate *p;
};

#endif // SIALANJAVALAYER_H
