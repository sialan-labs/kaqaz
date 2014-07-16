#ifndef SIALANTOOLS_H
#define SIALANTOOLS_H

#include <QObject>
#include <QVariant>

class SialanToolsPrivate;
class SialanTools : public QObject
{
    Q_OBJECT
public:
    SialanTools(QObject *parent = 0);
    ~SialanTools();

public slots:
    static QVariant call( QObject *obj, const QString & member, Qt::ConnectionType type,
                                                                const QVariant & v0 = QVariant(),
                                                                const QVariant & v1 = QVariant(),
                                                                const QVariant & v2 = QVariant(),
                                                                const QVariant & v3 = QVariant(),
                                                                const QVariant & v4 = QVariant(),
                                                                const QVariant & v5 = QVariant(),
                                                                const QVariant & v6 = QVariant(),
                                                                const QVariant & v7 = QVariant(),
                                                                const QVariant & v8 = QVariant(),
                                                                const QVariant & v9 = QVariant() );

private:
    SialanToolsPrivate *p;
};

#endif // SIALANTOOLS_H
