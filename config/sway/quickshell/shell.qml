// Neo Brutalism panels for waybar (sway)
//   qs -p ~/.config/sway/quickshell ipc call panel toggle <bluetooth|audio|brightness|wifi|calendar|theme>

import Quickshell
import Quickshell.Io
import Quickshell.I3
import Quickshell.Wayland
import QtQuick

ShellRoot {
    id: root

    property string current: ""

    readonly property var panels: ({
        bluetooth: bluetoothPanel,
        audio: audioPanel,
        brightness: brightnessPanel,
        wifi: wifiPanel,
        calendar: calendarPanel,
        theme: themePanel
    })

    IpcHandler {
        target: "panel"

        function toggle(name: string): void {
            root.current = (root.current === name || !(name in root.panels)) ? "" : name;
        }
        function open(name: string): void {
            root.current = (name in root.panels) ? name : "";
        }
        function close(): void {
            root.current = "";
        }
    }

    Component { id: bluetoothPanel; BluetoothPanel {} }
    Component { id: audioPanel; AudioPanel {} }
    Component { id: brightnessPanel; BrightnessPanel {} }
    Component { id: wifiPanel; WifiPanel {} }
    Component { id: calendarPanel; CalendarPanel {} }
    Component { id: themePanel; ThemePanel {} }

    PanelWindow {
        id: win

        visible: root.current !== ""
        screen: {
            const name = I3.focusedMonitor?.name;
            return Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
        }

        // full-screen transparent catcher *below* the bar (respects waybar's exclusive zone)
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        exclusionMode: ExclusionMode.Normal
        exclusiveZone: 0
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "neobrutal-panel"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent
            onClicked: root.current = ""
        }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.current = ""
        }

        Loader {
            id: loader

            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 10
            anchors.rightMargin: 14

            active: root.current !== ""
            sourceComponent: root.panels[root.current] ?? null

            // swallow clicks inside the panel
            MouseArea {
                anchors.fill: parent
                z: -1
            }

            // drop-in animation
            onLoaded: {
                item.opacity = 0;
                drop.restart();
            }
            ParallelAnimation {
                id: drop
                NumberAnimation { target: loader.item; property: "opacity"; from: 0; to: 1; duration: 110 }
                NumberAnimation { target: loader.item; property: "y"; from: -14; to: 0; duration: 140; easing.type: Easing.OutBack }
            }
        }
    }
}
