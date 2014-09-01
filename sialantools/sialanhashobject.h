#ifndef SIALANHASHOBJECT_H
#define SIALANHASHOBJECT_H

#include <QObject>
#include <QVariant>

class SialanHashObjectPrivate;
class SialanHashObject : public QObject
{
    Q_OBJECT
public:
    SialanHashObject(QObject *parent = 0);
    ~SialanHashObject();

    Q_INVOKABLE void insert(const QString & key, const QVariant & value );
    Q_INVOKABLE void insertMulti(const QString & key, const QVariant & value );
    Q_INVOKABLE void remove( const QString & key );
    Q_INVOKABLE void remove( const QString & key, const QVariant & value );

    Q_INVOKABLE QVariant key( const QVariant & value );
    Q_INVOKABLE QStringList keys( const QVariant & value );
    Q_INVOKABLE QStringList keys();
    Q_INVOKABLE QVariant value( const QString & key );
    Q_INVOKABLE QVariantList values( const QString & key );

    Q_INVOKABLE QVariant containt( const QString & key );
    Q_INVOKABLE QVariant containt( const QString & key, const QVariant & value );

    Q_INVOKABLE void clear();

    Q_INVOKABLE int count();

private:
    SialanHashObjectPrivate *p;
};

#endif // SIALANHASHOBJECT_H
