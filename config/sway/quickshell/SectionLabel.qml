import QtQuick

// "── LABEL ─────────" section divider
Item {
    id: sec

    property string text: ""

    width: parent ? parent.width : 300
    implicitHeight: 18

    Rectangle {
        id: tag
        height: 18
        width: label.implicitWidth + 12
        color: Theme.border

        BText {
            id: label
            anchors.centerIn: parent
            text: sec.text.toUpperCase()
            color: Theme.dark ? Theme.fg : Theme.surface
            font.pixelSize: 10
            font.weight: Font.Black
            font.letterSpacing: 1
        }
    }

    Rectangle {
        anchors.left: tag.right
        anchors.right: parent.right
        anchors.verticalCenter: tag.verticalCenter
        height: Theme.bwSmall
        color: Theme.border
    }
}
