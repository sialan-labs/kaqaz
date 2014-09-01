#include "sialanlistobject.h"

#include <QVariantList>
#include <QDebug>

class SialanListObjectPrivate
{
public:
    QVariantList list;
};

SialanListObject::SialanListObject(QObject *parent) :
    QObject(parent)
{
    p = new SialanListObjectPrivate;
}

void SialanListObject::removeAll(const QVariant &v)
{
    p->list.removeAll( v );
    emit countChanged();
}

void SialanListObject::removeOne(const QVariant &v)
{
    p->list.removeOne( v );
    emit countChanged();
}

void SialanListObject::removeAt(int index)
{
    p->list.removeAt( index );
    emit countChanged();
}

QVariant SialanListObject::takeLast()
{
    if( p->list.isEmpty() )
        return QVariant();

    const QVariant & res = p->list.takeLast();
    emit countChanged();

    return res;
}

QVariant SialanListObject::takeFirst()
{
    if( p->list.isEmpty() )
        return QVariant();

    const QVariant & res = p->list.takeFirst();
    emit countChanged();

    return res;
}

QVariant SialanListObject::takeAt(int index)
{
    const QVariant & res = p->list.takeAt( index );
    emit countChanged();

    return res;
}

QVariant SialanListObject::last() const
{
    if( p->list.isEmpty() )
        return QVariant();

    return p->list.last();
}

QVariant SialanListObject::first() const
{
    if( p->list.isEmpty() )
        return QVariant();

    return p->list.first();
}

void SialanListObject::insert(int index, const QVariant &v)
{
    p->list.insert( index, v );
    emit countChanged();
}

void SialanListObject::append(const QVariant &v)
{
    p->list.append( v );
    emit countChanged();
}

void SialanListObject::prepend(const QVariant &v)
{
    p->list.prepend( v );
    emit countChanged();
}

int SialanListObject::count() const
{
    return p->list.count();
}

bool SialanListObject::isEmpty() const
{
    return p->list.isEmpty();
}

QVariant SialanListObject::at(int index) const
{
    return p->list.at(index);
}

int SialanListObject::indexOf(const QVariant &v) const
{
    return p->list.indexOf(v);
}

void SialanListObject::fromList(const QVariantList &list)
{
    p->list = list;
}

QVariantList SialanListObject::toList() const
{
    return p->list;
}

bool SialanListObject::contains(const QVariant &v) const
{
    return p->list.contains(v);
}

SialanListObject::~SialanListObject()
{
    delete p;
}
