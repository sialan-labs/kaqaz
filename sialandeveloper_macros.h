#ifndef SIALANDEVELOPER_MACROS_H
#define SIALANDEVELOPER_MACROS_H

#include <QMetaMethod>

#define PRINT_EMITTED_SIGNAL \
    if( sender() ) \
    { \
        QObject *obj   = sender(); \
        int signal_idx = senderSignalIndex(); \
        QMetaMethod method = obj->metaObject()->method(signal_idx); \
        qDebug() << method.name(); \
    }

#endif // SIALANDEVELOPER_MACROS_H
