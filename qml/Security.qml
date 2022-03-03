import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import Ubuntu.Components.Popups 1.3
import QtQuick.Layouts 1.1

Page {
    id: root

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Lock security")
    }

    Column {
        id: content
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right


        ListItems.ItemSelector {
            property string swipe: i18n.tr("Swipe (no security)")
            property string passcode: i18n.tr("4-digit passcode")
            property string passphrase: i18n.tr("Passphrase")
            property string fingerprint: i18n.tr("Fingerprint")
            property string swipeAlt: i18n.tr("Swipe (no security)… ")
            property string passcodeAlt: i18n.tr("4-digit passcode…")
            property string passphraseAlt: i18n.tr("Passphrase…")

            id: unlockMethod
            model:  3
            selectedIndex: 1
            delegate: OptionSelectorDelegate {
                objectName: {
                    switch (index) {
                    case 0:
                        return "method_swipe";
                    case 1:
                        return "method_code";
                    case 2:
                        return "method_phrase";
                    case 3:
                        return "method_finger";
                    default:
                        return "method_unknown";
                    }
                }
                text: {
                    var si = unlockMethod.selectedIndex;
                    switch (index) {
                    case 0:
                        return si == 0 ? unlockMethod.swipe : unlockMethod.swipeAlt;
                    case 1:
                        return si == 1 ? unlockMethod.passcode : unlockMethod.passcodeAlt;
                    case 2:
                        return si == 2 ? unlockMethod.passphrase : unlockMethod.passphraseAlt;
                    case 3:
                        return unlockMethod.fingerprint;
                    }
                }
                enabled: {
                    // Fingerprint is the only one we disable, unless the user
                    // has chosen FP ident and there are more than 0 enrolled
                    // FPs and there's a pass{code|phrase} set.
                    var passSet = (securityPrivacy.securityType ===
                                   UbuntuSecurityPrivacyPanel.Passcode
                                   || securityPrivacy.securityType ===
                                   UbuntuSecurityPrivacyPanel.Passphrase);
                    var haveFps = page.enrolledFingerprints > 0;
                    return index !== 3 || (haveFps && passSet);
                }

            }
            expanded: true
        }

        Column {
            id: pinCodeManagerPanel
            visible: unlockMethod.selectedIndex === 1
            //anchors.top: content.bottom
            //anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: pinCodeManagerItems.itemHeight * pinCodePromptModel.count
            anchors.margins: units.gu(2)

            Item {
                //property alias text: label.text
                anchors {
                    left: parent.left
                    right: parent.right
                }
                height: units.gu(6)

                Label {
                    id: label
                    anchors {
                        top: parent.top
                        topMargin: units.gu(3)
                        right: parent.right
                        rightMargin: units.gu(2)
                        bottom: parent.bottom
                        left: parent.left
                        leftMargin: units.gu(2)
                    }
                    text: i18n.tr("Choose pincode prompt")
                    fontSize: "small"
                    opacity: 0.75
                }
            }


            OptionSelector {
                id: pinCodeManagerItems
                anchors.margins: units.gu(2)
                expanded: true
                //text: i18n.tr("Choose pincode prompt")
                model: pinCodePromptModel
                selectedIndex: pinCodePromptModel.findIndex("SchemaPinPrompt")
                delegate: OptionSelectorDelegate {
                    height: units.gu(8)
                    text: name
                    subText: description

                    Button {
                        id: tryMeBtn
                        height: implicitHeight
                        visible: index == 1
                        anchors {

                            right: parent.right

                            rightMargin: units.gu(6)
                            verticalCenter: parent.verticalCenter
                        }

                        text: i18n.tr("try me")
                        onClicked: pageStack.addPageToNextColumn(root, Qt.resolvedUrl("SchemaPinPromptTutorial.qml"))
                    }
                }
            }
        }
    }

    ListModel {
        id: pinCodePromptModel

        function findIndex(pinCodePromptManager) {
            for(var i = 0; i < pinCodePromptModel.count; i++) {
                var element = pinCodePromptModel.get(i);

                if(pinCodePromptManager === element.manager) {
                    return i;
                }
            }
            return -1;
        }

        Component.onCompleted: {
            pinCodePromptModel.append({name: i18n.tr("Default Prompt"), description: i18n.tr("Classic keyboard input"), manager: "PinPrompt"})
            pinCodePromptModel.append({name: i18n.tr("Clock Prompt"), description: i18n.tr("Click or swipe on dots to unlock"), manager: "SchemaPinPrompt"})
        }
    }



    Component {
        id: pinCodePrompComp
        ListItem {
            id: systemSettings1
            height: systemSettings1_layout.height + tryMeBtn.height + (divider.visible ? divider.height : 0)

            ListItemLayout {
                id: systemSettings1_layout
                title.text: name
                subtitle.text: description

                Icon {
                    name: "tick"
                    visible: index == pinCodeManagerItems.selectedIndex
                    width: units.gu(2);
                    height: units.gu(2);
                    SlotsLayout.position: SlotsLayout.Trailing
                }

            }
            Button {
                id: tryMeBtn
                anchors.top: systemSettings1_layout.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: units.gu(1)
                text: i18n.tr("try me")
                onClicked: pageStack.addPageToNextColumn(root, Qt.resolvedUrl("SchemaPinPrompt2.qml"))

            }

        }
    }
}
