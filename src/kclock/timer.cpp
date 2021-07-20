/*
 * Copyright 2020 Han Young <hanyoung@protonmail.com>
 * Copyright 2020 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "timer.h"

#include <QTimer>

/* ~ Timer ~ */
Timer::Timer()
{
}
Timer::Timer(QString uuid, bool justCreated)
    : m_justCreated(justCreated)
    , m_interface(new OrgKdeKclockTimerInterface(QStringLiteral("org.kde.kclockd"), QStringLiteral("/Timers/") + uuid, QDBusConnection::sessionBus(), this))

{
    if (m_interface->isValid()) {
        m_uuid = QUuid(m_interface->getUUID());
        m_label = m_interface->label();
        m_length = m_interface->length();
        m_running = m_interface->running();
        m_elapsed = m_interface->elapsed();
        m_looping = m_interface->looping();
        m_isCommandTimeout = m_interface->isCommandTimeout();
        m_commandTimeout = m_interface->commandTimeout();
        connect(m_interface, &OrgKdeKclockTimerInterface::lengthChanged, this, &Timer::updateLength);
        connect(m_interface, &OrgKdeKclockTimerInterface::labelChanged, this, &Timer::updateLabel);
        connect(m_interface, &OrgKdeKclockTimerInterface::runningChanged, this, &Timer::updateRunning);
        connect(m_interface, &OrgKdeKclockTimerInterface::loopingChanged, this, &Timer::updateLooping);
        connect(m_interface, &OrgKdeKclockTimerInterface::isCommandTimeoutChanged, this, &Timer::updateIsCommandTimeout);
        connect(m_interface, &OrgKdeKclockTimerInterface::commandTimeoutChanged, this, &Timer::updateCommandTimeout);

        updateRunning(); // start animation
    }
}

void Timer::toggleRunning()
{
    m_interface->toggleRunning();
}

void Timer::toggleLooping()
{
    m_interface->toggleLooping();
}

void Timer::toggleIsCommandTimeout()
{
    m_interface->toggleIsCommandTimeout();
}

void Timer::saveCommandTimeout(QString command)
{
    m_interface->saveCommandTimeout(command);
}

void Timer::reset()
{
    m_interface->reset();

    m_elapsed = m_interface->elapsed();
    Q_EMIT elapsedChanged();
}

void Timer::addMinute()
{
    int newLength = length() + 60;
    m_interface->setLength(newLength);
    updateLength();
    Q_EMIT propertyChanged();
}

void Timer::updateLength()
{
    m_length = m_interface->length();
    Q_EMIT propertyChanged();
}

void Timer::updateLabel()
{
    m_label = m_interface->label();
    Q_EMIT propertyChanged();
}
void Timer::updateRunning()
{
    m_running = m_interface->running();
    Q_EMIT propertyChanged();

    this->animation(m_running);

    m_elapsed = m_interface->elapsed();
    Q_EMIT elapsedChanged();
}

void Timer::updateLooping()
{
    m_looping = m_interface->looping();
    Q_EMIT propertyChanged();
}

void Timer::updateIsCommandTimeout()
{
    m_isCommandTimeout = m_interface->isCommandTimeout();
    Q_EMIT propertyChanged();
}

void Timer::updateCommandTimeout()
{
    m_commandTimeout = m_interface->commandTimeout();
    Q_EMIT propertyChanged();
}

void Timer::animation(bool start)
{
    if (!m_timer) {
        m_timer = new QTimer(this);
        connect(m_timer, &QTimer::timeout, [this] {
            m_elapsed = m_interface->elapsed();
            Q_EMIT this->elapsedChanged();
        });
    }

    if (start) {
        m_timer->start(250);
    } else {
        m_timer->stop();
    }
}
