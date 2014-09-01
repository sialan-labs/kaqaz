#include "sialanhashobject.h"

#include <QList>
#include <QPair>
#include <QDebug>
#include <QDebug>

class SialanHashObjectPrivate
{
public:
    QMultiHash<QString,QVariant> hash;
};

SialanHashObject::SialanHashObject(QObject *parent) :
    QObject(parent)
{
    p = new SialanHashObjectPrivate;
}

void SialanHashObject::insert(const QString &key, const QVariant &value)
{
    p->hash.insert(key,value);
}

void SialanHashObject::insertMulti(const QString &key, const QVariant &value)
{
    p->hash.insertMulti(key,value);
}

void SialanHashObject::remove(const QString &key)
{
    p->hash.remove(key);
}

void SialanHashObject::remove(const QString &key, const QVariant &value)
{
    p->hash.remove(key,value);
}

QVariant SialanHashObject::key(const QVariant &value)
{
    return p->hash.key(value);
}

QStringList SialanHashObject::keys(const QVariant &value)
{
    return p->hash.keys(value);
}

QStringList SialanHashObject::keys()
{
    return p->hash.keys();
}

QVariant SialanHashObject::value(const QString &key)
{
    return p->hash.value(key);
}

QVariantList SialanHashObject::values(const QString &key)
{
    return p->hash.values(key);
}

QVariant SialanHashObject::containt(const QString &key)
{
    return p->hash.contains(key);
}

QVariant SialanHashObject::containt(const QString &key, const QVariant &value)
{
    return p->hash.contains(key,value);
}

void SialanHashObject::clear()
{
    p->hash.clear();
}

int SialanHashObject::count()
{
    return p->hash.count();
}

SialanHashObject::~SialanHashObject()
{
    delete p;
}
