pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Neo Brutalism palette, live-reloaded from colors.json (written by theme/neobrutal.sh)
Singleton {
    id: theme

    property var c: ({})

    readonly property bool dark: c.mode === "dark"
    readonly property color bg: c.bg ?? "#FFF4E0"
    readonly property color surface: c.surface ?? "#FFFFFF"
    readonly property color fg: c.fg ?? "#000000"
    readonly property color ink: c.ink ?? "#000000"
    readonly property color border: c.border ?? "#000000"
    readonly property color shadow: c.shadow ?? "#000000"
    readonly property color muted: c.muted ?? "#7A7468"
    readonly property color main: c.main ?? "#FFDC58"
    readonly property color accent: c.accent ?? "#FF6B6B"
    readonly property color yellow: c.yellow ?? "#FFDC58"
    readonly property color red: c.red ?? "#FF6B6B"
    readonly property color blue: c.blue ?? "#88AAEE"
    readonly property color green: c.green ?? "#A3E636"
    readonly property color purple: c.purple ?? "#A388EE"
    readonly property color orange: c.orange ?? "#FF9F45"
    readonly property color cyan: c.cyan ?? "#5DD9E6"
    readonly property color pink: c.pink ?? "#FF90E8"

    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property int bw: 3          // card border
    readonly property int bwSmall: 2     // control border
    readonly property int shadowOff: 6   // card shadow offset
    readonly property int pressOff: 3    // control shadow offset

    // text color to use on top of a given fill
    function onFill(fill) {
        return (Qt.colorEqual(fill, surface) || Qt.colorEqual(fill, bg)) ? fg : ink;
    }

    FileView {
        path: Quickshell.shellDir + "/colors.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            if (text().trim() === "") return;   // caught mid-write, the next change brings the full file
            try { theme.c = JSON.parse(text()); } catch (e) { console.warn("colors.json:", e); }
        }
    }
}
