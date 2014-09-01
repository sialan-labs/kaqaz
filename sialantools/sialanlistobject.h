#ifndef SIALANLISTOBJECT_H
#define SIALANLISTOBJECT_H

#include <QObject>
#include <QVariant>

class SialanListObjectPrivate;
class SialanListObject : public QObject
{
    Q_PROPERTY(int count READ count NOTIFY countChanged)

    Q_OBJECT
public:
    SialanListObject(QObject *parent = 0);
    ~SialanListObject();

    Q_INVOKABLE void removeAll( const QVariant & v );
    Q_INVOKABLE void removeOne( const QVariant & v );
    Q_INVOKABLE void removeAt( int index );
    Q_INVOKABLE QVariant takeLast();
    Q_INVOKABLE QVariant takeFirst();
    Q_INVOKABLE QVariant takeAt( int index );

    Q_INVOKABLE QVariant last() const;
    Q_INVOKABLE QVariant first() const;

    Q_INVOKABLE void insert( int index, const QVariant & v );
    Q_INVOKABLE void append( const QVariant & v );
    Q_INVOKABLE void prepend( const QVariant & v );

    Q_INVOKABLE int count() const;
    Q_INVOKABLE bool isEmpty() const;

    Q_INVOKABLE QVariant at( int index ) const;
    Q_INVOKABLE int indexOf( const QVariant & v ) const;

    Q_INVOKABLE void fromList( const QVariantList & list );
    Q_INVOKABLE QVariantList toList() const;

    Q_INVOKABLE bool contains( const QVariant & v ) const;

signals:
    void countChanged();

private:
    SialanListObjectPrivate *p;
};

#endif // SIALANLISTOBJECT_H
