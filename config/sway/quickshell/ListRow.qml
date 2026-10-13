import QtQuick

// Device / network row : [icon] title / subtitle .......... [right slot]
Item {
    id: row

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property bool showExtra: false
    property color activeFill: Theme.green
    default property alias slotContent: slot.data

    signal clicked

    readonly property color face: active ? activeFill : ma.containsMouse ? Theme.bg : Theme.surface

    width: parent ? parent.width : 300
    implicitHeight: extra.visible ? 50 + extra.height + 8 : 50

    // extra content (e.g. password field) shown under the row
    property alias extra: extra
    property alias extraData: extra.data

    Rectangle {
        anchors.fill: parent
        anchors.rightMargin: Theme.pressOff
        color: row.face
        border.width: Theme.bwSmall
        border.color: Theme.border
    }

    MouseArea {
        id: ma
        width: parent.width
        height: 50
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: row.clicked()
    }

    BText {
        id: ic
        x: 12
        width: 24
        height: 50
        text: row.icon
        color: Theme.onFill(row.face)
        font.pixelSize: 18
        horizontalAlignment: Text.AlignHCenter
    }

    Column {
        x: 46
        y: (50 - height) / 2
        width: slot.x - x - 8
        spacing: 1

        BText {
            width: parent.width
            text: row.title
            color: Theme.onFill(row.face)
        }
        BText {
            width: parent.width
            visible: text !== ""
            text: row.subtitle
            color: row.active ? Theme.ink : Theme.muted
            opacity: row.active ? 0.75 : 1
            font.pixelSize: 11
        }
    }

    Row {
        id: slot
        x: parent.width - Theme.pressOff - width - 10
        height: 50
        spacing: 6
    }

    Item {
        id: extra
        visible: row.showExtra
        x: 12
        y: 50
        width: parent.width - Theme.pressOff - 24
        height: childrenRect.height
    }
}
