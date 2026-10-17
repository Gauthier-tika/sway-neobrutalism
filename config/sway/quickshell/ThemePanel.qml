import QtQuick
import Quickshell

// Light/dark mode + main color (sway borders, bar, menus, cursor, login screen)
Card {
    id: panel

    readonly property string ctl: Quickshell.env("HOME") + "/.config/sway/theme/neobrutal.sh"
    readonly property var accents: Theme.c.accents ?? ["yellow", "red", "blue", "green", "purple", "orange", "cyan", "pink"]
    readonly property var labels: ({
        yellow: "Jaune", red: "Rouge", blue: "Bleu", green: "Vert",
        purple: "Violet", orange: "Orange", cyan: "Cyan", pink: "Rose"
    })

    // what was just clicked, until colors.json catches up (the switch takes ~1s)
    property string pendingMode: ""
    property string pendingAccent: ""
    property int pendingSize: 0
    readonly property bool dark: pendingMode !== "" ? pendingMode === "dark" : Theme.dark
    readonly property string accentName: pendingAccent !== "" ? pendingAccent : (Theme.c.accent_name ?? "yellow")
    readonly property var cursorSizes: Theme.c.cursor_sizes ?? [24, 32, 48, 72]
    readonly property int cursorSize: pendingSize !== 0 ? pendingSize : (Theme.c.cursor_size ?? 24)

    Connections {
        target: Theme
        function onCChanged() {
            panel.pendingMode = "";
            panel.pendingAccent = "";
            panel.pendingSize = 0;
        }
    }

    function setMode(mode) {
        if (mode === (Theme.dark ? "dark" : "light")) return;
        panel.pendingMode = mode;
        Quickshell.execDetached([panel.ctl, mode]);
    }

    function setAccent(name) {
        if (name === Theme.c.accent_name) return;
        panel.pendingAccent = name;
        Quickshell.execDetached([panel.ctl, "accent", name]);
    }

    function setCursorSize(size) {
        if (size === Theme.c.cursor_size) return;
        panel.pendingSize = size;
        Quickshell.execDetached([panel.ctl, "cursor-size", String(size)]);
    }

    PanelHeader {
        icon: "󰏘"
        title: "Thème"
        tint: Theme.main
        subtitle: "Bordures, barre, menus, curseur"
    }

    SectionLabel { text: "Mode" }

    Row {
        id: modes
        width: parent.width
        spacing: 8

        BButton {
            width: (modes.width - modes.spacing) / 2
            icon: "󰖨"
            text: "Clair"
            active: !panel.dark
            onClicked: panel.setMode("light")
        }
        BButton {
            width: (modes.width - modes.spacing) / 2
            icon: "󰖔"
            text: "Sombre"
            active: panel.dark
            onClicked: panel.setMode("dark")
        }
    }

    SectionLabel { text: "Couleur principale" }

    Grid {
        id: swatches
        width: parent.width
        columns: 4
        spacing: 8

        Repeater {
            model: panel.accents

            BButton {
                required property string modelData
                readonly property bool current: modelData === panel.accentName

                width: (swatches.width - 3 * swatches.spacing) / 4
                height: 44
                fill: Theme[modelData]
                activeFill: Theme[modelData]
                active: current
                padX: 4
                fontSize: 12
                icon: current ? "󰄬" : ""
                text: panel.labels[modelData] ?? modelData
                onClicked: panel.setAccent(modelData)
            }
        }
    }

    SectionLabel { text: "Taille du curseur" }

    Row {
        id: sizes
        width: parent.width
        spacing: 8

        Repeater {
            model: panel.cursorSizes

            BButton {
                required property int modelData
                width: (sizes.width - (panel.cursorSizes.length - 1) * sizes.spacing) / panel.cursorSizes.length
                fontSize: 13
                icon: "󰇀"
                text: modelData
                active: modelData === panel.cursorSize
                onClicked: panel.setCursorSize(modelData)
            }
        }
    }

    // mini preview : a focused window with the chosen border and title bar
    Item {
        width: parent.width
        height: 70

        Rectangle {
            x: Theme.pressOff
            y: Theme.pressOff
            width: preview.width
            height: preview.height
            color: Theme.shadow
        }

        Rectangle {
            id: preview
            width: parent.width - Theme.pressOff
            height: parent.height - Theme.pressOff
            color: Theme.bg
            border.width: Theme.bw
            border.color: Theme.accent

            // sway : client.focused <title border> <accent> <ink> … <accent child border>
            Rectangle {
                id: titlebar
                x: Theme.bw
                y: Theme.bw
                width: parent.width - 2 * Theme.bw
                height: 26
                color: Theme.accent
                border.width: Theme.bw
                border.color: Theme.border

                BText {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "~ : alacritty"
                    color: Theme.ink
                    font.pixelSize: 12
                    font.weight: Font.ExtraBold
                }
            }

            BText {
                anchors.left: parent.left
                anchors.leftMargin: Theme.bw + 8
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.bw + 6
                text: "$ neobrutal.sh accent " + (Theme.c.accent_name ?? "")
                color: Theme.fg
                font.pixelSize: 11
            }

            // the cursor, in the accent color
            BText {
                anchors.right: parent.right
                anchors.rightMargin: 14
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                text: "󰇀"
                color: Theme.accent
                style: Text.Outline
                styleColor: Theme.border
                font.pixelSize: 22
            }
        }
    }
}
