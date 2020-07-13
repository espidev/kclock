/*
 * Copyright 2020 Devin Lin <espidev@gmail.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Window 2.2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.11 as Kirigami
import org.kde.kirigamiaddons.dateandtime 0.1 as DateAndTime
import kclock 1.0

Kirigami.ScrollablePage {

    property Alarm selectedAlarm: null
    property QtObject selectedAlarmModel: null // so that we call setData rather than the getters and setters
    property bool newAlarm: false
    property int alarmDaysOfWeek: newAlarm ? 0 : selectedAlarm.daysOfWeek
    property string ringtonePath

    title: newAlarm ? i18n("New Alarm") : i18n("Edit") + " " + selectedAlarmModel.name
    
    function init(alarm, alarmModel) {
        if (alarm == null) {
            newAlarm = true;
            alarmDaysOfWeek = 0;
            // manually set because binding doesn't seem to work
            let date = new Date();
            selectedAlarmTime.pm = date.getHours() >= 12;
            selectedAlarmTime.hours = date.getHours() >= 12 ? date.getHours() - 12 : date.getHours();
            selectedAlarmTime.minutes = date.getMinutes();
        } else {
            newAlarm = false;
            alarmDaysOfWeek = alarm.daysOfWeek;
            // manually set because binding doesn't seem to work
            selectedAlarmTime.pm = alarm.hours > 12;
            selectedAlarmTime.hours = alarm.hours >= 12 ? alarm.hours - 12 : alarm.hours;
            selectedAlarmTime.minutes = alarm.minutes;
        }
        selectedAlarm = alarm;
        selectedAlarmModel = alarmModel;
    }
    
    actions {
        main: Kirigami.Action {
            iconName: "checkmark"
            text: i18n("Done")
            onTriggered: {
                // save
                let hours = selectedAlarmTime.hours + (selectedAlarmTime.pm ? 12 : 0);
                let minutes = selectedAlarmTime.minutes;
                if (newAlarm) {
                    alarmModel.newAlarm(selectedAlarmName.text, minutes, hours, alarmDaysOfWeek, ringtonePath);
                    newAlarm = false; // reset form
                } else {
                    selectedAlarmModel.name = selectedAlarmName.text;
                    selectedAlarmModel.minutes = minutes;
                    selectedAlarmModel.hours = hours;
                    selectedAlarmModel.daysOfWeek = alarmDaysOfWeek;
                    
                    // if the user did not set a new ringtone path, ignore
                    if (ringtonePath != "")
                        selectedAlarmModel.ringtonePath = ringtonePath;
                }
                // reset
                alarmDaysOfWeek = 0;
                newAlarm = true;
                pageStack.pop()
            }
        }
    }
    
    Column {
        spacing: Kirigami.Units.largeSpacing
        
        // time picker
        DateAndTime.TimePicker {
            id: selectedAlarmTime

            height: 400
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(400, parent.width)
        }
        
        Kirigami.Separator {
            width: parent.width
        }

        // repeat day picker
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n("Days to Repeat")
            font.weight: Font.Bold
        }

        Flow {
            anchors.horizontalCenter: parent.horizontalCenter
            Repeater {
                model: ListModel {
                    id: selectedDays
                    ListElement { displayText: "S"; dayFlag: 64 }
                    ListElement { displayText: "M"; dayFlag: 1 }
                    ListElement { displayText: "T"; dayFlag: 2 }
                    ListElement { displayText: "W"; dayFlag: 4 }
                    ListElement { displayText: "T"; dayFlag: 8 }
                    ListElement { displayText: "F"; dayFlag: 16 }
                    ListElement { displayText: "S"; dayFlag: 32 }
                }

                ToolButton {
                    implicitWidth: 40
                    text: displayText
                    checkable: true
                    checked: ((newAlarm ? alarmDaysOfWeek : selectedAlarm.daysOfWeek) & dayFlag) == dayFlag
                    highlighted: false
                    onClicked: {
                        if (checked) alarmDaysOfWeek |= dayFlag;
                        else alarmDaysOfWeek &= ~dayFlag;
                    }
                }
            }
        }

        Kirigami.Separator {
            width: parent.width
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n("Alarm Name")
            font.weight: Font.Bold
        }
        TextField {
            anchors.horizontalCenter: parent.horizontalCenter
            id: selectedAlarmName
            placeholderText: i18n("Wake Up")
            text: newAlarm ? "Alarm" : selectedAlarm.name
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            text: i18n("Ringtone")
            font.weight: Font.Bold
        }

        Kirigami.ActionTextField {
            id: selectAlarmField
            anchors.horizontalCenter: parent.horizontalCenter
            placeholderText: newAlarm ? i18n("default") : selectedAlarm.ringtoneName

            rightActions: [
                Kirigami.Action {
                    iconName: "list-add"
                    onTriggered: {
                        ringtonePath = alarmModel.selectRingtone();
                        if (ringtonePath.toString().length != 0)
                            selectAlarmField.placeholderText = ringtonePath.toString().split('/').pop();
                    }
                }
            ]
        }
    }
}
