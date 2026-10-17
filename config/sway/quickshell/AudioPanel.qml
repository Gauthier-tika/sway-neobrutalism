import QtQuick
import Quickshell.Services.Pipewire

Card {
    id: panel

    readonly property var devices: Pipewire.nodes.values.filter(n => n.audio && !n.isStream)
    readonly property var sinks: devices.filter(n => n.isSink)
    readonly property var sources: devices.filter(n => !n.isSink)
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    function label(n) {
        return n ? (n.description || n.nickname || n.name) : "No device";
    }

    // bind the default devices so their audio properties are live
    PwObjectTracker {
        objects: [panel.sink, panel.source]
    }

    PanelHeader {
        icon: "󰕾"
        title: "Sound"
        tint: Theme.red
        subtitle: panel.sink ? `Output ${Math.round((panel.sink.audio?.volume ?? 0) * 100)}%  ·  Input ${Math.round((panel.source?.audio?.volume ?? 0) * 100)}%` : ""
    }

    // ---------- output ----------
    SectionLabel { text: "Output" }

    Dropdown {
        model: panel.sinks
        current: panel.sink
        labelOf: panel.label
        onSelected: item => Pipewire.preferredDefaultAudioSink = item
    }

    VolumeRow {
        node: panel.sink
        fill: Theme.red
        iconOn: "󰕾"
        iconOff: "󰖁"
    }

    // ---------- input ----------
    SectionLabel { text: "Input" }

    Dropdown {
        model: panel.sources
        current: panel.source
        labelOf: panel.label
        onSelected: item => Pipewire.preferredDefaultAudioSource = item
    }

    VolumeRow {
        node: panel.source
        fill: Theme.purple
        iconOn: "󰍬"
        iconOff: "󰍭"
    }

    component VolumeRow: Item {
        id: vr
        property var node: null
        property color fill: Theme.main
        property string iconOn: ""
        property string iconOff: ""
        readonly property bool muted: node?.audio?.muted ?? false
        readonly property real volume: node?.audio?.volume ?? 0

        width: parent.width
        implicitHeight: 34 + Theme.pressOff

        BButton {
            id: muteBtn
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            icon: vr.muted ? vr.iconOff : vr.iconOn
            padX: 0
            fontSize: 14
            active: vr.muted
            activeFill: Theme.surface
            fill: vr.fill
            enabled: vr.node !== null
            onClicked: vr.node.audio.muted = !vr.node.audio.muted
        }

        BSlider {
            anchors.left: muteBtn.right
            anchors.leftMargin: 8
            anchors.right: pct.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            value: vr.volume
            fill: vr.fill
            muted: vr.muted
            step: 0.05
            onMoved: v => { if (vr.node) vr.node.audio.volume = v; }
        }

        BText {
            id: pct
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 44
            horizontalAlignment: Text.AlignRight
            text: vr.muted ? "OFF" : Math.round(vr.volume * 100) + "%"
            font.pixelSize: 14
            font.weight: Font.Black
        }
    }
}
