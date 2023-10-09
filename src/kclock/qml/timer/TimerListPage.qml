/*
 * Copyright 2020-2021 Devin Lin <devin@kde.org>
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as Components

import "../components"
import kclock

Kirigami.ScrollablePage {
    id: root

    property real yTranslate: 0

    title: i18n("Timers")
    icon.name: "player-time"

    // desktop action
    actions: [
        Kirigami.Action {
            icon.name: "list-add"
            text: i18n("New Timer")
            onTriggered: root.addTimer()
            visible: !Kirigami.Settings.isMobile
        },
        Kirigami.Action {
            displayHint: Kirigami.DisplayHint.IconOnly
            visible: !applicationWindow().isWidescreen
            icon.name: "settings-configure"
            text: i18n("Settings")
            onTriggered: applicationWindow().pageStack.push(applicationWindow().getPage("Settings"))
        }
    ]

    function addTimer() {
        newTimerForm.active = true;
        newTimerForm.item.open();
    }

    header: Components.Banner {
        type: Kirigami.MessageType.Error
        text: i18n("The clock daemon was not found. Please start kclockd in order to have timer functionality.")
        visible: !TimerModel.connectedToDaemon // by default, it's false so we need this
    }

    Kirigami.CardsListView {
        id: timersList
        model: TimerModel

        transform: Translate { y: yTranslate }

        add: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: Kirigami.Units.shortDuration }
        }
        remove: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: Kirigami.Units.shortDuration }
        }
        displaced: Transition {
            NumberAnimation { properties: "x,y"; duration: Kirigami.Units.longDuration; easing.type: Easing.InOutQuad}
        }

        // mobile action
        FloatingActionButton {
            icon.name: "list-add"
            onClicked: root.addTimer()
            visible: Kirigami.Settings.isMobile
        }

        // no timer placeholder
        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            visible: timersList.count === 0
            text: i18n("No timers configured")
            icon.name: "player-time"

            helpfulAction: Kirigami.Action {
                icon.name: "list-add"
                text: i18n("Add timer")
                onTriggered: root.addTimer()
            }
        }

        // create timer form
        TimerFormWrapper {
            id: newTimerForm
            active: false
        }

        // timer card delegate
        delegate: TimerListDelegate {
            timer: model.timer
        }
    }
}
