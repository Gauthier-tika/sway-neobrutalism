import QtQuick
import Quickshell.Bluetooth

Card {
    id: panel

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool on: adapter?.enabled ?? false
    readonly property var all: adapter ? adapter.devices.values : []
    readonly property var known: all.filter(d => d.paired || d.connected)
        .sort((a, b) => (b.connected - a.connected) || deviceLabel(a).localeCompare(deviceLabel(b)))
    readonly property var nearby: all.filter(d => !d.paired && !d.connected && d.deviceName !== "")
        .sort((a, b) => deviceLabel(a).localeCompare(deviceLabel(b)))

    function deviceLabel(d) {
        return d.name || d.deviceName || d.address;
    }
    function deviceIcon(d) {
        const i = d.icon || "";
        if (i.includes("headset") || i.includes("headphone")) return "󰋋";
        if (i.includes("audio") || i.includes("speaker")) return "󰓃";
        if (i.includes("mouse")) return "󰍽";
        if (i.includes("keyboard")) return "󰌌";
        if (i.includes("phone")) return "󰏲";
        if (i.includes("gaming") || i.includes("joystick")) return "󰊴";
        if (i.includes("computer")) return "󰟀";
        return "󰂯";
    }
    function deviceStatus(d) {
        switch (d.state) {
        case BluetoothDeviceState.Connecting: return "Connexion…";
        case BluetoothDeviceState.Disconnecting: return "Déconnexion…";
        }
        if (d.pairing) return "Appairage…";
        if (d.connected) return "Connecté" + (d.batteryAvailable ? `  ·  󰥉 ${Math.round(d.battery * 100)}%` : "");
        if (d.paired) return "Appairé";
        return d.address;
    }

    Component.onDestruction: if (adapter && adapter.discovering) adapter.discovering = false

    PanelHeader {
        icon: "󰂯"
        title: "Bluetooth"
        tint: Theme.blue
        subtitle: !panel.adapter ? "Aucun adaptateur" : panel.on ? (panel.adapter.name || "Activé") : "Désactivé"

        BSwitch {
            checked: panel.on
            busy: panel.adapter?.state === BluetoothAdapterState.Enabling || panel.adapter?.state === BluetoothAdapterState.Disabling
            onToggled: if (panel.adapter) panel.adapter.enabled = !panel.adapter.enabled
        }
    }

    // ---- known devices ----
    SectionLabel {
        visible: panel.on
        text: "Mes appareils"
    }

    BText {
        visible: panel.on && panel.known.length === 0
        text: "Aucun appareil appairé"
        color: Theme.muted
    }

    Column {
        visible: panel.on
        width: parent.width
        spacing: 8

        Repeater {
            model: panel.known
            ListRow {
                required property var modelData
                icon: panel.deviceIcon(modelData)
                title: panel.deviceLabel(modelData)
                subtitle: panel.deviceStatus(modelData)
                active: modelData.connected
                activeFill: Theme.blue
                onClicked: modelData.connected ? modelData.disconnect() : modelData.connect()

                ForgetButton {
                    onConfirmed: modelData.forget()
                }
            }
        }
    }

    // ---- discovery ----
    SectionLabel {
        visible: panel.on
        text: "À proximité"
    }

    BButton {
        visible: panel.on
        width: parent.width
        icon: panel.adapter?.discovering ? "󰓛" : "󰍉"
        text: panel.adapter?.discovering ? "Recherche en cours… (arrêter)" : "Rechercher des appareils"
        fill: Theme.cyan
        active: panel.adapter?.discovering ?? false
        activeFill: Theme.yellow
        onClicked: panel.adapter.discovering = !panel.adapter.discovering
    }

    BText {
        visible: panel.on && (panel.adapter?.discovering ?? false) && panel.nearby.length === 0
        text: "Recherche…"
        color: Theme.muted
    }

    Column {
        visible: panel.on && panel.nearby.length > 0
        width: parent.width
        spacing: 8

        Repeater {
            model: panel.nearby.slice(0, 8)
            ListRow {
                required property var modelData
                icon: panel.deviceIcon(modelData)
                title: panel.deviceLabel(modelData)
                subtitle: panel.deviceStatus(modelData)
                onClicked: {
                    modelData.trusted = true;
                    modelData.pair();
                }

                // connect as soon as pairing succeeds
                Connections {
                    target: modelData
                    function onPairedChanged() {
                        if (modelData.paired) modelData.connect();
                    }
                }

                BText {
                    height: 50
                    text: "APPAIRER"
                    font.pixelSize: 10
                    font.weight: Font.Black
                }
            }
        }
    }
}
