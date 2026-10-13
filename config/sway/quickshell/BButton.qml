import QtQuick

// Pressable chip : the face slides onto its shadow when pressed.
Item {
    id: btn

    property string text: ""
    property string icon: ""
    property color fill: Theme.surface
    property color activeFill: Theme.main
    property bool active: false
    property bool enabled: true
    property int fontSize: 13
    property int padX: 12
    property int off: Theme.pressOff

    signal clicked

    readonly property bool down: ma.pressed
    readonly property color face: !enabled ? Theme.bg : active ? activeFill : ma.containsMouse ? Qt.darker(fill, Theme.dark ? 0.85 : 1.06) : fill

    implicitWidth: row.implicitWidth + 2 * padX + off
    implicitHeight: 32 + off
    opacity: enabled ? 1 : 0.55

    Rectangle {
        x: btn.off
        y: btn.off
        width: parent.width - btn.off
        height: parent.height - btn.off
        color: Theme.shadow
    }

    Rectangle {
        x: btn.down ? btn.off : 0
        y: btn.down ? btn.off : 0
        width: parent.width - btn.off
        height: parent.height - btn.off
        color: btn.face
        border.width: Theme.bwSmall
        border.color: Theme.border

        Row {
            id: row
            anchors.centerIn: parent
            spacing: 6

            BText {
                visible: btn.icon !== ""
                text: btn.icon
                color: Theme.onFill(btn.face)
                font.pixelSize: btn.fontSize + 2
            }
            BText {
                visible: btn.text !== ""
                text: btn.text
                color: Theme.onFill(btn.face)
                font.pixelSize: btn.fontSize
                font.weight: Font.ExtraBold
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        enabled: btn.enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: btn.clicked()
    }
}
