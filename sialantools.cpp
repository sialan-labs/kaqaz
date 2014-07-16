#include "sialantools.h"

#include <QMetaMethod>
#include <QMetaObject>

class SialanToolsPrivate
{
public:
};

SialanTools::SialanTools(QObject *parent) :
    QObject(parent)
{
    p = new SialanToolsPrivate;
}

QVariant SialanTools::call(QObject *obj, const QString &member, Qt::ConnectionType ctype, const QVariant &v0, const QVariant &v1, const QVariant &v2, const QVariant &v3, const QVariant &v4, const QVariant &v5, const QVariant &v6, const QVariant &v7, const QVariant &v8, const QVariant &v9)
{
    const QMetaObject *meta_obj = obj->metaObject();
    QMetaMethod meta_method;
    for( int i=0; i<meta_obj->methodCount(); i++ )
    {
        QMetaMethod mtd = meta_obj->method(i);
        if( mtd.name() == member )
            meta_method = mtd;
    }
    if( !meta_method.isValid() )
        return QVariant();

    QList<QByteArray> param_types = meta_method.parameterTypes();
    QList<QByteArray> param_names = meta_method.parameterNames();

    QString ret_type = meta_method.typeName();
    QList< QPair<QString,QString> > m_args;
    for( int i=0 ; i<param_types.count() ; i++ )
        m_args << QPair<QString,QString>( param_types.at(i) , param_names.at(i) );

    QVariantList vals;
        vals << v0 << v1 << v2 << v3 << v4 << v5 << v6 << v7 << v8 << v9;

    QVariantList tr_vals;

    QList< QPair<QString,const void*> > args;
    for( int i=0 ; i<vals.count() ; i++ )
    {
        if( i<m_args.count() )
        {
            QString type = m_args.at(i).first;

            if( type != vals.at(i).typeName() )
            {
                if( !vals[i].canConvert( QVariant::nameToType(type.toLatin1()) ) )
                    ;
                else
                    vals[i].convert( QVariant::nameToType(type.toLatin1()) );
            }

            args << QPair<QString,const void*>( type.toLatin1() , vals.at(i).data() );
            tr_vals << vals[i];
        }
        else
        {
            args << QPair<QString,const void*>( vals.at(i).typeName() , vals.at(i).data() );
        }
    }

    int type = QMetaType::type(ret_type.toLatin1());
    void *res = QMetaType::create( type );
    bool is_pointer = ret_type.contains('*');

    bool done;
    switch( static_cast<int>(ctype) )
    {
    case Qt::QueuedConnection:
        done = QMetaObject::invokeMethod( obj , member.toLatin1() , Qt::QueuedConnection ,
                                  QGenericArgument( args.at(0).first.toLatin1() , args.at(0).second ) ,
                                  QGenericArgument( args.at(1).first.toLatin1() , args.at(1).second ) ,
                                  QGenericArgument( args.at(2).first.toLatin1() , args.at(2).second ) ,
                                  QGenericArgument( args.at(3).first.toLatin1() , args.at(3).second ) ,
                                  QGenericArgument( args.at(4).first.toLatin1() , args.at(4).second ) ,
                                  QGenericArgument( args.at(5).first.toLatin1() , args.at(5).second ) ,
                                  QGenericArgument( args.at(6).first.toLatin1() , args.at(6).second ) ,
                                  QGenericArgument( args.at(7).first.toLatin1() , args.at(7).second ) ,
                                  QGenericArgument( args.at(8).first.toLatin1() , args.at(8).second ) ,
                                  QGenericArgument( args.at(9).first.toLatin1() , args.at(9).second ) );
        return QVariant();
        break;

    default:
        done = QMetaObject::invokeMethod( obj , member.toLatin1() , ctype, QGenericReturnArgument( ret_type.toLatin1() , (is_pointer)? &res : res ) ,
                                  QGenericArgument( args.at(0).first.toLatin1() , args.at(0).second ) ,
                                  QGenericArgument( args.at(1).first.toLatin1() , args.at(1).second ) ,
                                  QGenericArgument( args.at(2).first.toLatin1() , args.at(2).second ) ,
                                  QGenericArgument( args.at(3).first.toLatin1() , args.at(3).second ) ,
                                  QGenericArgument( args.at(4).first.toLatin1() , args.at(4).second ) ,
                                  QGenericArgument( args.at(5).first.toLatin1() , args.at(5).second ) ,
                                  QGenericArgument( args.at(6).first.toLatin1() , args.at(6).second ) ,
                                  QGenericArgument( args.at(7).first.toLatin1() , args.at(7).second ) ,
                                  QGenericArgument( args.at(8).first.toLatin1() , args.at(8).second ) ,
                                  QGenericArgument( args.at(9).first.toLatin1() , args.at(9).second ) );
        break;
    }

    Q_UNUSED(done)

    QVariant result;
    if( type == QMetaType::Void )
        result = QVariant();
    else
    if( is_pointer )
        result = QVariant( type , &res );
    else
        result = QVariant( type , res );

    if( type == QMetaType::type("QVariant") )
        return result.value<QVariant>();
    else
        return result;
}

SialanTools::~SialanTools()
{
    delete p;
}
