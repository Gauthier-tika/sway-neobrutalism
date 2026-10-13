import QtQuick

// Inline dropdown : header chip + options list that expands below it.
Column {
    id: dd

    property var model: []                         // array of objects
    property var current: null                     // currently selected object
    property var labelOf: o => o ? String(o) : "—"
    property color fill: Theme.surface
    property bool open: false

    signal selected(var item)

    width: parent ? parent.width : 300
    spacing: 6

    BButton {
        id: head
        width: dd.width
        fill: dd.fill
        active: dd.open
        padX: 10
        onClicked: dd.open = !dd.open

        // custom content : label left, chevron right
        text: ""
        BText {
            x: 12 + (head.down ? head.off : 0)
            y: (head.height - head.off - height) / 2 + (head.down ? head.off : 0)
            width: head.width - 50
            text: dd.labelOf(dd.current)
            color: Theme.onFill(head.face)
        }
        BText {
            x: head.width - head.off - 26 + (head.down ? head.off : 0)
            y: (head.height - head.off - height) / 2 + (head.down ? head.off : 0)
            text: dd.open ? "󰅃" : "󰅀"
            color: Theme.onFill(head.face)
            font.pixelSize: 16
        }
    }

    Rectangle {
        visible: dd.open
        width: dd.width - Theme.pressOff
        height: list.implicitHeight + 2 * Theme.bwSmall
        color: Theme.surface
        border.width: Theme.bwSmall
        border.color: Theme.border

        Column {
            id: list
            x: Theme.bwSmall
            y: Theme.bwSmall
            width: parent.width - 2 * Theme.bwSmall

            Repeater {
                model: dd.model
                Rectangle {
                    required property var modelData
                    required property int index
                    readonly property bool isCurrent: modelData === dd.current
                    width: list.width
                    height: 32
                    color: isCurrent ? Theme.main : rowMa.containsMouse ? Theme.bg : Theme.surface

                    Rectangle {   // separators
                        visible: index > 0
                        width: parent.width
                        height: Theme.bwSmall
                        color: Theme.border
                    }
                    BText {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        text: (parent.isCurrent ? "● " : "  ") + dd.labelOf(parent.modelData)
                        color: parent.isCurrent ? Theme.ink : Theme.fg
                    }
                    MouseArea {
                        id: rowMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            dd.selected(parent.modelData);
                            dd.open = false;
                        }
                    }
                }
            }
        }
    }
}
