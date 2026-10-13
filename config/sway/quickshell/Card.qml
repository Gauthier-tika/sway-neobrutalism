import QtQuick

// Bordered block with a hard offset shadow; children are stacked in a Column.
Item {
    id: card

    property color fill: Theme.surface
    property int pad: 16
    property int spacing: 14
    default property alias content: inner.data

    implicitWidth: 380
    implicitHeight: inner.implicitHeight + 2 * (pad + Theme.bw) + Theme.shadowOff

    Rectangle {
        x: Theme.shadowOff
        y: Theme.shadowOff
        width: face.width
        height: face.height
        color: Theme.shadow
    }

    Rectangle {
        id: face
        width: parent.width - Theme.shadowOff
        height: parent.height - Theme.shadowOff
        color: card.fill
        border.width: Theme.bw
        border.color: Theme.border

        Column {
            id: inner
            anchors.fill: parent
            anchors.margins: card.pad + Theme.bw
            spacing: card.spacing
        }
    }
}
