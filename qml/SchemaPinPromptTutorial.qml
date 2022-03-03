/*
 * Copyright 2014-2016 Canonical Ltd.
 * Copyright 2022 UBports Foundation
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3

Page {
    id: root
    objectName: "SchemaPinPrompt"

    property string text
    property bool isSecret
    property bool interactive: true
    property bool loginError: false
    property bool hasKeyboard: false //unused
    property string enteredText: ""
    property bool keyboardNeeded: false
    property bool editMode: false
    property bool activeAreaVisible: false

    property string codeToTest: Math.floor(1000 + Math.random() * 9000)
    property int previousNumber: -1
    property var currentCode: []
    property int maxnum: 10
    property int maxPinCodeDigits: 4
    property string previousState: ""
    property bool isLandscape: root.width > root.height

    signal clicked()
    signal canceled()
    signal accepted(string response)

    onCurrentCodeChanged: {
        let tmpText = ""
        let tmpCode = ""
        for( let i = 0; i < codeToTest.length; i++) {
            if (i < currentCode.length) {
                tmpText += '●'
                tmpCode += currentCode[i]
            } else {
                tmpText += codeToTest[i]
            }
        }
        pinHint.text = tmpText
        root.enteredText = tmpCode

        // hard limit of 4 for passcodes right now
        if (root.enteredText.length >= maxPinCodeDigits) {
            if (root.enteredText === root.codeToTest) {
                root.state = "PASSWORD_SUCCESS"
            } else {
                root.state = "WRONG_PASSWORD"
            }
            root.previousState = root.state
        }
    }

    function addNumber (number, fromKeyboard) {
        let tmpCodes = currentCode
        tmpCodes.push(number)
        currentCode = tmpCodes

        if (!fromKeyboard) {
            repeater.itemAt(number).animation.restart()
        }

        root.previousNumber = number
    }

    function removeOne() {
        let tmpCodes = currentCode
        const number = tmpCodes.pop()
        currentCode = tmpCodes
    }

    function reset() {
        currentCode = []
        loginError = false;
    }

    header: PageHeader {
        id: pageHeader
        title: i18n.tr('Clock prompt demo')
    }

    Rectangle {
        anchors.fill: parent
        color: "purple"
        MouseArea {
            anchors.fill: parent
            enabled: root.editMode
            onClicked: {
                pinHint.text = ""
                pinHint.text = root.codeToTest
            }
        }
    }

    StyledItem {
        id: d

        readonly property color normal: theme.palette.normal.raisedText
        readonly property color selected: theme.palette.normal.raisedSecondaryText
        readonly property color disabled:theme.palette.disabled.raisedSecondaryText
    }

    GridLayout {
        id: grid
        anchors {
            top: pageHeader.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        columns: isLandscape ? 2 : 1

        Column {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: units.gu(2)

            Label {
                text: root.editMode ? i18n.tr("enter custom code:") : i18n.tr("try code:")
                color: d.selected
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: pinHint
                anchors.horizontalCenter: parent.horizontalCenter
                width: units.gu(20)
                readOnly: !root.editMode
                color: root.editMode ? d.normal : d.selected
                maximumLength: root.maxPinCodeDigits
                hasClearButton: false
                onTextChanged: {
                    if (root.editMode && text.length === maximumLength) {
                        root.editMode = false
                        pinHint.focus = false
                        root.codeToTest = text
                        root.state = "ENTRY_MODE"
                        root.reset()
                    }
                }
                onFocusChanged: console.log('pinHint focus', focus)
                onActiveFocusChanged: console.log('pinHint activeFocus', activeFocus)

                font {
                    pixelSize: units.gu(3)
                    letterSpacing: units.gu(1.2)
                }

                secondaryItem: Icon {
                    id: icon
                    name: root.editMode ? "tick" : "edit"
                    objectName: "EraseBtn"
                    height: units.gu(2.5)
                    width: units.gu(2.5)
                    color: enabled ? d.selected : d.disabled
                    enabled: true
                    anchors.verticalCenter: parent.verticalCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!root.editMode) {
                                pinHint.text = codeToTest
                                root.editMode = true
                                pinHint.forceActiveFocus()

                            }
                        }
                    }
                }


                inputMethodHints: Qt.ImhDigitsOnly

            }

            Label {
                id: resultLabel

                visible: !root.editMode
                anchors.horizontalCenter: parent.horizontalCenter
                fontSize: "large"
                text: i18n.tr("Click or swipe on the dots")
                color: d.selected
            }
        }

        Rectangle {
            id: main
            objectName: "SelectArea"
            implicitHeight: root.width > root.height ? root.width /2.2 : root.height / 2
            implicitWidth: implicitHeight

            Layout.fillWidth: true
            Layout.rowSpan: 2
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            color: "transparent"
            border.color: activeAreaVisible ? d.selected : "transparent"

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: !root.editMode
                //onPressed: checkboxActive.checked = false

                onPositionChanged: {
                    if (pressed)
                        reEvaluate()
                }

                function reEvaluate() {
                    var child = main.childAt(mouseX, mouseY)

                    if (child !== null && child.number !== undefined) {
                        var number = child.number
                        if (number > -1 && ( root.previousNumber === -1 || number !== root.previousNumber)) {
                            root.addNumber(number)
                        }
                    } else {
                        root.previousNumber = -1
                    }
                }
            }

            Rectangle {
                id: center
                objectName: "CenterCircle"
                height: main.height / 3
                width: height
                radius: height / 2
                property int radiusSquared: radius * radius
                property alias locker: centerImg.source
                anchors.centerIn: parent
                color: "transparent"
                border.color: d.normal
                property int number: -1

                Image {
                    id: centerImg
                    source: "image://theme/lock"
                    anchors.fill: parent
                    anchors.margins: parent.height / 4
                    fillMode: Image.PreserveAspectFit
                    onSourceChanged: imgAnim.start()
                }

                MouseArea {
                    id: centerMouseArea
                    anchors.fill: parent
                    propagateComposedEvents: true
                    onPressed: {
                        root.state = "ENTRY_MODE"
                        mouse.accepted = false
                    }
                }

                SequentialAnimation {
                    id: imgAnim
                    NumberAnimation { target: centerImg; property: "opacity"; from: 0; to: 1; duration: 1000 }
                }
            }

            // numbers
            Repeater {
                id: numbers
                model: root.maxnum

                Text {
                    id: point
                    font.pixelSize: main.height / 10
                    width: height
                    color: d.disabled
                    text: index
                    opacity: root.state === "ENTRY_MODE" ? 1 : 0
                    property bool selected: false

                    property int bigR: main.height / 3.5
                    property int offsetRadius: height / 2
                    x: (main.width / 2) + bigR * Math.sin(2 * Math.PI * index / root.maxnum) - height /4
                    y: (main.height / 2) - bigR * Math.cos(2 * Math.PI * index / root.maxnum) - offsetRadius

                    Behavior on opacity {
                        UbuntuNumberAnimation{ duration: 500 }
                    }
                }
            }

            // dots
            Repeater {
                id: repeater
                objectName: "dotRepeater"
                model: root.maxnum

                Rectangle {
                    id: selectionRect
                    height: bigR / 2.2
                    width: height
                    radius: height / 2
                    color: activeAreaVisible ? d.selected : "transparent"
                    opacity: activeAreaVisible ? 0.3 : 1.0
                    property int number: index
                    property alias dot: centerDot
                    property alias animation: anim

                    property int bigR: root.state === "ENTRY_MODE" ? main.height / 2.7 : 0
                    property int offsetRadius: radius
                    x: (main.width / 2) + bigR * Math.sin(2 * Math.PI * index / root.maxnum) - offsetRadius
                    y: (main.height / 2) - bigR * Math.cos(2 * Math.PI * index / root.maxnum) - offsetRadius

                    Rectangle {
                        id: centerDot
                        height: parent.height / 3.2
                        width: height
                        radius: height / 2
                        anchors.centerIn: parent
                        color: "transparent"
                        border.color: d.selected
                        border.width: 2
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !root.editMode
                        onPressed: {
                            root.addNumber(index)
                            mouse.accepted = false
                        }
                    }

                    Behavior on bigR {
                        UbuntuNumberAnimation { duration: 500 }
                    }


                    SequentialAnimation {
                        id: anim
                        ParallelAnimation {
                            PropertyAnimation {
                                target: centerDot
                                property: "color"
                                to: d.selected
                                duration: 100
                            }
                            PropertyAnimation {
                                target: selectionRect
                                property: "color"
                                to: Qt.rgba(d.selected.r, d.selected.g, d.selected.b, 0.3)
                                duration: 100
                            }
                        }
                        ParallelAnimation {
                            PropertyAnimation {
                                target: centerDot
                                property: "color"
                                to: "transparent"
                                duration: 400
                            }
                            PropertyAnimation {
                                target: selectionRect
                                property: "color"
                                to: activeAreaVisible ? d.selected : "transparent"
                                duration: 400
                            }
                        }
                    }
                }
            }
        }

        Column {
            Layout.margins: units.gu(2)
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom
            spacing: units.gu(2)

            RowLayout {
                 width: parent.width
                visible: !root.editMode
                Label {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignLeft
                    text: i18n.tr("Display active area")
                    color: d.selected
                }
                Switch {
                    id: checkboxActive
                    Layout.alignment: Qt.AlignRight
                    onCheckedChanged: activeAreaVisible = checked
                }
            }
        }
    }

    states: [
        State{
            name: "ENTRY_MODE"
            StateChangeScript {
                script: root.reset();
            }
        },
        State{
            name: "WRONG_PASSWORD"
            PropertyChanges {
                target: center
                locker: "image://theme/reload"
            }
            PropertyChanges {
                target: resultLabel
                text: i18n.tr("Wrong code, try again!")
            }
        },
        State{
            name: "PASSWORD_SUCCESS"
            PropertyChanges {
                target: center
                locker: "image://theme/reload"
            }
            PropertyChanges {
                target: resultLabel
                text: i18n.tr("Well done!")
            }
        }
    ]

    transitions:[
        Transition {
            from: "ENTRY_MODE"; to: "WRONG_PASSWORD";
            PropertyAction { target: resultLabel; property: "text"; value: i18n.tr("Wrong code, try again!") }
            PropertyAction { target: center; property: "locker"; value: "image://theme/dialog-warning-symbolic" }
            PauseAnimation { duration: 1000 }
        },
        Transition {
            from: "ENTRY_MODE"; to: "PASSWORD_SUCCESS";
            PropertyAction { target: resultLabel; property: "text"; value: i18n.tr("Well done!")}
            PropertyAction { target: center; property: "locker"; value: "image://theme/tick" }
            PauseAnimation { duration: 1200 }

        }
    ]

    Timer {
        running: true
        interval: 1
        onTriggered: root.state = "ENTRY_MODE"
    }
}
