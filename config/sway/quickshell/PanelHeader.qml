import QtQuick

// Big title row : [icon tile] TITLE / subtitle ........ [right slot]
Item {
    id: hdr

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property color tint: Theme.main
    default property alias slotContent: slot.data

    width: parent ? parent.width : 300
    implicitHeight: 44

    Rectangle {
        id: tile
        width: 40
        height: 40
        anchors.verticalCenter: parent.verticalCenter
        color: hdr.tint
        border.width: Theme.bwSmall
        border.color: Theme.border

        BText {
            anchors.centerIn: parent
            text: hdr.icon
            color: Theme.ink
            font.pixelSize: 20
        }
    }

    Column {
        anchors.left: tile.right
        anchors.leftMargin: 12
        anchors.right: slot.left
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter
        spacing: 1

        BText {
            width: parent.width
            text: hdr.title.toUpperCase()
            font.pixelSize: 17
            font.weight: Font.Black
        }
        BText {
            width: parent.width
            visible: text !== ""
            text: hdr.subtitle
            color: Theme.muted
            font.pixelSize: 11
        }
    }

    Item {
        id: slot
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: childrenRect.width
        height: childrenRect.height
    }
}
