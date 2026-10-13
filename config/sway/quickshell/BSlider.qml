import QtQuick

// Chunky progress bar you can drag / click / scroll. value in [0, 1], snapped to `step`.
Item {
    id: sl

    property real value: 0
    property real step: 0.05
    property real minimum: 0
    property color fill: Theme.main
    property bool ticks: true
    property bool muted: false

    signal moved(real value)

    implicitWidth: 260
    implicitHeight: 28 + Theme.pressOff

    function snap(v) {
        const s = Math.round(v / step) * step;
        return Math.max(minimum, Math.min(1, Math.round(s * 1000) / 1000));
    }
    function setFromX(x) {
        sl.moved(snap(x / track.width));
    }

    Rectangle {
        x: Theme.pressOff
        y: Theme.pressOff
        width: track.width
        height: track.height
        color: Theme.shadow
    }

    Rectangle {
        id: track
        width: parent.width - Theme.pressOff
        height: parent.height - Theme.pressOff
        color: Theme.surface
        border.width: Theme.bwSmall
        border.color: Theme.border
        clip: true

        Rectangle {
            x: Theme.bwSmall
            y: Theme.bwSmall
            height: parent.height - 2 * Theme.bwSmall
            width: Math.max(0, (parent.width - 2 * Theme.bwSmall) * Math.min(1, sl.value))
            color: sl.muted ? Theme.muted : sl.fill
            Behavior on width { NumberAnimation { duration: 80 } }

            // hard edge between filled / empty part
            Rectangle {
                anchors.right: parent.right
                width: parent.width > 0 && sl.value < 1 ? Theme.bwSmall : 0
                height: parent.height
                color: Theme.border
            }
        }

        // tick marks every `step`
        Repeater {
            model: sl.ticks ? Math.round(1 / sl.step) - 1 : 0
            Rectangle {
                required property int index
                readonly property bool major: Math.abs(((index + 1) * sl.step * 4) % 1) < 0.001
                x: (index + 1) * sl.step * track.width - 1
                y: track.height - height - Theme.bwSmall
                width: 2
                height: major ? 10 : 5
                color: Theme.border
                opacity: major ? 0.9 : 0.45
            }
        }
    }

    MouseArea {
        anchors.fill: track
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => sl.setFromX(mouse.x)
        onPositionChanged: mouse => { if (pressed) sl.setFromX(mouse.x); }
        onWheel: wheel => sl.moved(sl.snap(sl.value + (wheel.angleDelta.y > 0 ? sl.step : -sl.step)))
    }
}
