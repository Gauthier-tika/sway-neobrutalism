import QtQuick

// Square brutalist toggle switch
Item {
    id: sw

    property bool checked: false
    property bool busy: false
    signal toggled

    implicitWidth: 58 + Theme.pressOff
    implicitHeight: 28 + Theme.pressOff

    Rectangle {
        x: Theme.pressOff
        y: Theme.pressOff
        width: parent.width - Theme.pressOff
        height: parent.height - Theme.pressOff
        color: Theme.shadow
    }

    Rectangle {
        id: track
        width: parent.width - Theme.pressOff
        height: parent.height - Theme.pressOff
        color: sw.checked ? Theme.green : Theme.surface
        border.width: Theme.bwSmall
        border.color: Theme.border

        Rectangle {
            id: knob
            width: track.height - 10
            height: width
            y: 5
            x: sw.checked ? track.width - width - 5 : 5
            color: Theme.dark && !sw.checked ? Theme.fg : Theme.border
            opacity: sw.busy ? 0.4 : 1
            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: sw.toggled()
    }
}
