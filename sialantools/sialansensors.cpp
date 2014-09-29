/*
    Copyright (C) 2014 Sialan Labs
    http://labs.sialan.org

    This project is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This project is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#define EARTH_GRAVITY 9.80665

#include "sialansensors.h"

#include <QtMath>
#include <QDebug>
#include <QRotationSensor>
#include <QGyroscope>
#include <QAccelerometer>
#include <QTimerEvent>
#include <QMatrix4x4>
#include <QTransform>

class SialanSensorsResItem
{
public:
    qreal newX;
    qreal beta;
    qreal alpha;
    qreal g;
    qreal f;
};

class ProVector
{
public:
    ProVector() {
        x = 0;
        y = 0;
        z = 0;
    }

    qreal x;
    qreal y;
    qreal z;
};

class SialanSensorsPrivate
{
public:
    qreal alp;

    QAccelerometer *gravity;
    QAccelerometer *accelerometer;

    QRotationSensor *rotation;
    QGyroscope *gyroscope;

    ProVector pg_vector;
    ProVector pa_vector;

    ProVector g_vector;
    ProVector a_vector;

    ProVector rtt_vector;
    ProVector gyr_vector;

    int duration_timer;
    int duration;

    int activeSensors;

    qreal zeroX;
    qreal zeroY;
    qreal zeroZ;
};

SialanSensors::SialanSensors(QObject *parent) :
    QObject(parent)
{
    p = new SialanSensorsPrivate;
    p->alp = 0;
    p->duration_timer = 0;
    p->duration = 200;
    p->zeroX = 0;
    p->zeroY = 0;
    p->zeroZ = 0;
    p->activeSensors = RotationSensor | AccelerometerSensor | GravitySensor;

    p->gravity = new QAccelerometer(this);
    p->gravity->setAccelerationMode(QAccelerometer::Gravity);

    p->accelerometer = new QAccelerometer(this);

    p->rotation = new QRotationSensor(this);
    p->gyroscope = new QGyroscope(this);

    connect( p->gravity      , SIGNAL(readingChanged()), SLOT(grv_reading()) );
    connect( p->accelerometer, SIGNAL(readingChanged()), SLOT(acc_reading()) );
    connect( p->rotation     , SIGNAL(readingChanged()), SLOT(rtt_reading()) );
    connect( p->gyroscope    , SIGNAL(readingChanged()), SLOT(gyr_reading()) );
}

qreal SialanSensors::ax() const
{
    return p->a_vector.x;
}

qreal SialanSensors::ay() const
{
    return p->a_vector.y;
}

qreal SialanSensors::az() const
{
    return p->a_vector.z;
}

qreal SialanSensors::gx() const
{
    return p->g_vector.x;
}

qreal SialanSensors::gy() const
{
    return p->g_vector.y;
}

qreal SialanSensors::gz() const
{
    return p->g_vector.z;
}

qreal SialanSensors::angleX() const
{
    return p->rtt_vector.x-p->zeroX*180/M_PI;
}

qreal SialanSensors::angleY() const
{
    return p->rtt_vector.y-p->zeroY*180/M_PI;
}

qreal SialanSensors::angleZ() const
{
    return p->rtt_vector.z-p->zeroZ*180/M_PI;
}

qreal SialanSensors::zeroAngleX() const
{
    return p->zeroX*180/M_PI;
}

qreal SialanSensors::zeroAngleY() const
{
    return p->zeroY*180/M_PI;
}

qreal SialanSensors::zeroAngleZ() const
{
    return p->zeroZ*180/M_PI;
}

qreal SialanSensors::angleSpeedX() const
{
    return p->gyr_vector.x;
}

qreal SialanSensors::angleSpeedY() const
{
    return p->gyr_vector.y;
}

qreal SialanSensors::angleSpeedZ() const
{
    return p->gyr_vector.z;
}

void SialanSensors::setDuration(int ms)
{
    if( p->duration == ms )
        return;

    p->duration = ms;
    if( active() )
        start();

    emit durationChanged();
}

int SialanSensors::duration() const
{
    return p->duration;
}

void SialanSensors::setActive(bool stt)
{
    if( stt == active() )
        return;

    if( stt )
        start();
    else
        stop();
}

bool SialanSensors::active() const
{
    return p->duration_timer;
}

void SialanSensors::setActiveSensors(int t)
{
    if( p->activeSensors == t )
        return;

    p->activeSensors = t;
    if( !active() )
        return;

    if( t & RotationSensor )
    {
        p->rotation->setActive(true);
        p->rotation->start();
    }
    if( t & AccelerometerSensor )
    {
        p->accelerometer->setActive(true);
        p->accelerometer->start();
    }
    if( t & GravitySensor )
    {
        p->gravity->setActive(true);
        p->gravity->start();
    }
    if( t & GyroscopeSensor )
    {
        p->gyroscope->setActive(true);
        p->gyroscope->start();
    }

    emit activeSensorsChanged();
}

int SialanSensors::activeSensors() const
{
    return p->activeSensors;
}

void SialanSensors::start()
{
    if( p->duration_timer )
        killTimer( p->duration_timer );

    p->accelerometer->setActive(true);
    p->accelerometer->start();

    p->gravity->setActive(true);
    p->gravity->start();

    p->rotation->setActive(true);
    p->rotation->start();

    p->gyroscope->setActive(true);
    p->gyroscope->start();

    p->duration_timer = startTimer(p->duration);
    emit activeChanged();
}

void SialanSensors::stop()
{
    if( p->duration_timer )
        killTimer( p->duration_timer );

    p->accelerometer->setActive(false);
    p->accelerometer->stop();

    p->gravity->setActive(false);
    p->gravity->stop();

    p->duration_timer = 0;
    emit activeChanged();
}

void SialanSensors::zero()
{
    p->zeroX = p->rtt_vector.x*M_PI/180;
    p->zeroY = p->rtt_vector.y*M_PI/180;
    p->zeroZ = p->rtt_vector.z*M_PI/180;

    refresh();

    emit accChanged();
    emit grvChanged();
    emit angleChanged();
    emit angleSpeedChanged();
}

void SialanSensors::setZero(qreal xrad, qreal yrad)
{
    p->zeroX = xrad;
    p->zeroY = yrad;

    refresh();

    emit accChanged();
    emit grvChanged();
    emit angleChanged();
    emit angleSpeedChanged();
}

void SialanSensors::refresh()
{
    p->a_vector = rebase(p->pa_vector);
    p->g_vector = rebase(p->pg_vector);
}

ProVector SialanSensors::rebase(const ProVector &v)
{
    ProVector res;

    const qreal x = v.x;
    const qreal y = v.y;
    const qreal z = v.z;

    QTransform t;
    t.rotateRadians(p->zeroX,Qt::XAxis);
    t.rotateRadians(p->zeroY,Qt::YAxis);
    t.rotateRadians(p->zeroZ,Qt::ZAxis);

    QMatrix4x4 m(t);

    const QVector3D & v3d = m.map(QVector3D(x,y,z));

    res.x = v3d.x();
    res.y = v3d.y();
    res.z = v3d.z();

    return res;
}

SialanSensorsResItem SialanSensors::analizeItem(qreal x, qreal y, bool ambiguity)
{
    SialanSensorsResItem res;
    res.beta = 0;
    res.newX = 0;

    const qreal f = qPow(x*x+y*y,0.5);
    if( f == 0 )
        return res;

    const qreal al = p->alp + qAsin(y/f);
    const qreal g = EARTH_GRAVITY;

    const qreal bt_p = qAsin( f*qSin(al)/g );
    const qreal bt = ambiguity? M_PI-bt_p : bt_p;
    const qreal nx = f*qCos(al) - g*qCos(bt);

    res.beta = bt;
    res.newX = nx;
    res.f = f;
    res.g = g;
    res.alpha = al;

    return res;
}

void SialanSensors::acc_reading()
{
    if( !p->accelerometer->reading() )
        return;

    QAccelerometerReading *rd = p->accelerometer->reading();
    p->pa_vector.x = rd->x();
    p->pa_vector.y = rd->y();
    p->pa_vector.z = rd->z();
    refresh();
}

void SialanSensors::grv_reading()
{
    if( !p->gravity->reading() )
        return;

    QAccelerometerReading *rd = p->gravity->reading();
    p->pg_vector.x = rd->x();
    p->pg_vector.y = rd->y();
    p->pg_vector.z = rd->z();
    refresh();
}

void SialanSensors::rtt_reading()
{
    if( !p->gravity->reading() )
        return;

    QRotationReading *rd = p->rotation->reading();
    p->rtt_vector.x = rd->x();
    p->rtt_vector.y = rd->y();
    p->rtt_vector.z = rd->z();
    refresh();
}

void SialanSensors::gyr_reading()
{
    if( !p->gyroscope->reading() )
        return;

    QGyroscopeReading *rd = p->gyroscope->reading();
    p->gyr_vector.x = rd->x();
    p->gyr_vector.y = rd->y();
    p->gyr_vector.z = rd->z();
    refresh();
}

void SialanSensors::timerEvent(QTimerEvent *e)
{
    if( e->timerId() == p->duration_timer )
    {
        emit accChanged();
        emit grvChanged();
        emit angleChanged();
        emit angleSpeedChanged();
        emit updated();
    }
    else
        QObject::timerEvent(e);
}

SialanSensors::~SialanSensors()
{
    delete p;
}
