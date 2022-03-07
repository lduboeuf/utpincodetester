import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.ListItems 1.3 as ListItems
import Ubuntu.Components.Popups 1.3
import QtQuick.Layouts 1.1

Page {
    id: root

    property bool changeMode: false
    property alias index: unlockMethod.selectedIndex

    header: PageHeader {
        id: pageHeader
        title: i18n.tr("Lock security")
        leadingActionBar.actions: [
            Action {
                iconName: "back"
                text: "Back"
                onTriggered: pageStack.removePages(root)
            }
        ]
    }

    Column {
        id: content
        anchors.top: header.bottom
        anchors.left: parent.left
        anchors.right: parent.right

        ListItems.ItemSelector {
            property string swipe: i18n.tr("Swipe (no security)")
            property string passcode: i18n.tr("4-digit passcode")
            property string passcodeClock: i18n.tr("4-digit passcode (clock)")
            property string passphrase: i18n.tr("Passphrase")
            property string fingerprint: i18n.tr("Fingerprint")
            property string swipeAlt: i18n.tr("Swipe (no security)… ")
            property string passcodeAlt: i18n.tr("4-digit passcode…")
            property string passcodeClockAlt: i18n.tr("4-digit passcode (clock)...")
            property string passphraseAlt: i18n.tr("Passphrase…")

            id: unlockMethod
            model:  5
            //selectedIndex: 0
            delegate: OptionSelectorDelegate {
                objectName: {
                    switch (index) {
                    case 0:
                        return "method_swipe";
                    case 1:
                        return "method_code";
                    case 2:
                        return "method_codeclock";
                    case 3:
                        return "method_phrase";
                    case 4:
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
                        return si == 2 ? unlockMethod.passcodeClock : unlockMethod.passcodeClockAlt;
                    case 3:
                        return si == 3 ? unlockMethod.passphrase : unlockMethod.passphraseAlt;
                    case 4:
                        return unlockMethod.fingerprint;
                    }
                }
            }
            onDelegateClicked: {
                console.log(index, selectedIndex)
                if (index === 2) {
                    //if (root.changeMode) {
                    var incubator = pageStack.addPageToNextColumn(root, Qt.resolvedUrl("SchemaPinPromptTutorialNoDots.qml"), { changeMode: root.changeMode})
                    console.log('incubator status',incubator.status)
                    if (incubator.status === Component.Ready) {
                    } else {
                        console.log('loaded')
                        incubator.onStatusChanged = function(status) {
                            console.log('kikou status', status)
                            if (status == Component.Ready) {

                                incubator.object.accepted.connect(function(response) {
                                    console.log('kikou pincode', response)
                                    var dialog = PopupUtils.open(dialogComponent, root, { pinCode: response})

                                });
                            }
                        }
                    }

                    //} else {
                    //    var dialog = PopupUtils.open(dialogComponent, root)
                    //}

                    //pageStack.addPageToNextColumn(root, Qt.resolvedUrl("SchemaPinPromptTutorialNoDots.qml"))
                }
            }

            expanded: true
        }
    }

    Component {
        id: dialogComponent
        Dialog {
            id: dialog
            title: i18n.tr("Change passcode…")

            property string pinCode: ""
            // the dialog and its children will use SuruDark
//            theme: ThemeSettings {
//                name: "Ubuntu.Components.Themes.SuruDark"
//            }
            TextField {
                placeholderText: i18n.tr("Existing passcode")
            }

            TextField {
                id: setInput
                //
                text: pinCode
                echoMode: TextInput.Password
            }

            TextField {
                id: confirmInput
                text: pinCode
                echoMode: TextInput.Password
            }

            RowLayout {
                spacing: units.gu(1)

                Button {
                    Layout.fillWidth: true
                    text: i18n.tr("Cancel")
                    onClicked: PopupUtils.close(dialog)
                }
                Button {
                    Layout.fillWidth: true
                    color: theme.palette.normal.positive
                    text: i18n.tr("validate")
                    onClicked: {
                        PopupUtils.close(dialog)
                        pageStack.removePages(root)
                        //pageStack.addPageToNextColumn(root, Qt.resolvedUrl("SchemaPinPromptTutorialNoDots.qml"))
                    }
                }
            }


        }
    }
}
