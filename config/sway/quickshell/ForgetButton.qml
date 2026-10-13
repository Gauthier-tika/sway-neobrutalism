import QtQuick

// Trash button that needs a second click (within 3s) to confirm.
BButton {
    id: fb

    property bool armed: false
    signal confirmed

    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    icon: armed ? "" : "󰆴"
    text: armed ? "OUBLIER ?" : ""
    padX: 6
    implicitHeight: 28
    fontSize: 10
    active: armed
    activeFill: Theme.red

    onClicked: {
        if (armed) {
            armed = false;
            confirmed();
        } else {
            armed = true;
            disarm.restart();
        }
    }

    Timer {
        id: disarm
        interval: 3000
        onTriggered: fb.armed = false
    }
}
