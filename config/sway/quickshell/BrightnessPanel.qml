import QtQuick
import Quickshell
import Quickshell.Io

Card {
    id: panel

    property real value: 0      // 0..1
    property bool ready: false
    readonly property string ctl: Quickshell.env("HOME") + "/.config/sway/scripts/backlight"

    function apply(v) {
        v = Math.max(0.05, Math.min(1, v));   // never go fully black
        panel.value = v;
        Quickshell.execDetached([panel.ctl, "set", String(Math.round(v * 100))]);
    }

    Process {
        running: true
        command: [panel.ctl, "get"]
        stdout: StdioCollector {
            onStreamFinished: {
                panel.value = parseFloat(text) / 100;
                panel.ready = true;
            }
        }
    }

    PanelHeader {
        icon: "󰃠"
        title: "Brightness"
        tint: Theme.orange
        subtitle: "Scroll on the bar: ±5%"

        BText {
            text: panel.ready ? Math.round(panel.value * 100) + "%" : "…"
            font.pixelSize: 26
            font.weight: Font.Black
        }
    }

    SectionLabel { text: "Presets" }

    Row {
        id: presets
        width: parent.width
        spacing: 8

        Repeater {
            model: [0.25, 0.5, 0.75, 1]
            BButton {
                required property real modelData
                width: (presets.width - 3 * presets.spacing) / 4
                text: Math.round(modelData * 100) + "%"
                fontSize: 14
                fill: Theme.surface
                activeFill: Theme.orange
                active: Math.abs(panel.value - modelData) < 0.01
                onClicked: panel.apply(modelData)
            }
        }
    }

    SectionLabel { text: "Fine · 5% steps" }

    BSlider {
        width: parent.width
        value: panel.value
        step: 0.05
        minimum: 0.05
        fill: Theme.orange
        onMoved: v => panel.apply(v)
    }

    Row {
        width: parent.width
        spacing: 8

        BButton {
            icon: "󰃞"
            text: "-5%"
            width: (parent.width - 8) / 2
            onClicked: panel.apply(Math.round((panel.value - 0.05) * 20) / 20)
        }
        BButton {
            icon: "󰃠"
            text: "+5%"
            width: (parent.width - 8) / 2
            onClicked: panel.apply(Math.round((panel.value + 0.05) * 20) / 20)
        }
    }
}
