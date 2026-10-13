import QtQuick
import Quickshell.Networking

Card {
    id: panel

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wired: Networking.devices.values.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property bool on: Networking.wifiEnabled
    readonly property var networks: wifi ? wifi.networks.values.filter(n => n.name !== "") : []
    readonly property var known: networks.filter(n => n.known || n.connected)
        .sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength))
    readonly property var others: networks.filter(n => !n.known && !n.connected)
        .sort((a, b) => b.signalStrength - a.signalStrength)
    readonly property var current: known.find(n => n.connected) ?? null

    property string pskFor: ""      // network name whose password field is open
    property string error: ""

    function strengthIcon(s) {
        return s > 0.75 ? "󰤨" : s > 0.5 ? "󰤥" : s > 0.25 ? "󰤢" : "󰤟";
    }
    function secured(n) {
        return n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Unknown;
    }
    function status(n) {
        if (n.state === ConnectionState.Connecting) return "Connexion…";
        if (n.state === ConnectionState.Disconnecting) return "Déconnexion…";
        if (n.connected) return "Connecté";
        return `${Math.round(n.signalStrength * 100)}%` + (secured(n) ? "  ·  󰌾 " + WifiSecurityType.toString(n.security) : "  ·  ouvert");
    }
    function activate(n) {
        panel.error = "";
        if (n.connected) n.disconnect();
        else if (n.known || !secured(n)) n.connect();
        else panel.pskFor = (panel.pskFor === n.name ? "" : n.name);
    }

    // start scanning as soon as the wifi device shows up
    onWifiChanged: if (wifi && on) wifi.scannerEnabled = true
    Component.onCompleted: if (wifi && on) wifi.scannerEnabled = true
    Component.onDestruction: if (wifi) wifi.scannerEnabled = false

    PanelHeader {
        icon: "󰖩"
        title: "Wi-Fi"
        tint: Theme.green
        subtitle: !panel.wifi ? "Aucune carte Wi-Fi" : !panel.on ? "Désactivé"
            : panel.current ? panel.current.name : panel.wired ? "Filaire : " + panel.wired.name : "Non connecté"

        BSwitch {
            checked: panel.on
            onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
        }
    }

    BText {
        visible: panel.error !== ""
        width: parent.width
        text: "󰀦 " + panel.error
        color: Theme.red
        wrapMode: Text.WordWrap
    }

    SectionLabel {
        visible: panel.on && panel.known.length > 0
        text: "Réseaux connus"
    }

    Column {
        visible: panel.on
        width: parent.width
        spacing: 8

        Repeater {
            model: panel.known
            ListRow {
                required property var modelData
                icon: panel.strengthIcon(modelData.signalStrength)
                title: modelData.name
                subtitle: panel.status(modelData)
                active: modelData.connected
                onClicked: panel.activate(modelData)

                Connections {
                    target: modelData
                    function onConnectionFailed(reason) {
                        panel.error = `${modelData.name} : ${ConnectionFailReason.toString(reason)}`;
                    }
                }

                ForgetButton {
                    visible: modelData.known
                    onConfirmed: modelData.forget()
                }
            }
        }
    }

    SectionLabel {
        visible: panel.on
        text: "Disponibles"
    }

    BButton {
        visible: panel.on && panel.wifi !== null
        width: parent.width
        icon: panel.wifi?.scannerEnabled ? "󰓛" : "󰍉"
        text: panel.wifi?.scannerEnabled ? "Recherche en cours… (arrêter)" : "Rechercher des réseaux"
        fill: Theme.cyan
        active: panel.wifi?.scannerEnabled ?? false
        activeFill: Theme.yellow
        onClicked: panel.wifi.scannerEnabled = !panel.wifi.scannerEnabled
    }

    Flickable {
        visible: panel.on && panel.others.length > 0
        width: parent.width
        height: Math.min(contentHeight, 290)
        contentHeight: othersCol.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: othersCol
            width: parent.width
            spacing: 8

            Repeater {
                model: panel.others
                ListRow {
                    id: netRow
                    required property var modelData
                    icon: panel.strengthIcon(modelData.signalStrength)
                    title: modelData.name
                    subtitle: panel.status(modelData)
                    showExtra: panel.pskFor === modelData.name
                    onClicked: panel.activate(modelData)

                    Connections {
                        target: netRow.modelData
                        function onConnectionFailed(reason) {
                            panel.error = `${netRow.modelData.name} : ${ConnectionFailReason.toString(reason)}`;
                        }
                    }

                    extraData: [
                        Row {
                            width: netRow.extra.width
                            spacing: 8

                            Rectangle {
                                width: parent.width - okBtn.width - 8
                                height: 32
                                color: Theme.bg
                                border.width: Theme.bwSmall
                                border.color: Theme.border

                                TextInput {
                                    id: psk
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    verticalAlignment: TextInput.AlignVCenter
                                    echoMode: TextInput.Password
                                    color: Theme.fg
                                    font.family: Theme.font
                                    font.pixelSize: 13
                                    font.weight: Font.Bold
                                    clip: true
                                    focus: netRow.showExtra
                                    onVisibleChanged: if (visible) forceActiveFocus()
                                    onAccepted: okBtn.clicked()

                                    BText {
                                        visible: psk.text === ""
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: "Mot de passe"
                                        color: Theme.muted
                                    }
                                }
                            }

                            BButton {
                                id: okBtn
                                text: "OK"
                                fill: Theme.main
                                onClicked: {
                                    netRow.modelData.connectWithPsk(psk.text);
                                    panel.pskFor = "";
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
}
