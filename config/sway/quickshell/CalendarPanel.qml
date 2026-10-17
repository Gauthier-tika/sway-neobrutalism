import QtQuick
import Quickshell
import Quickshell.Io

Card {
    id: panel

    implicitWidth: 410

    readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    readonly property var dayNames: ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    readonly property var monthShort: ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]
    readonly property var dayShort: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]

    property date today: new Date()
    property date selected: today
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()
    property var fetes: ({})

    // first Monday displayed in the grid
    readonly property date gridStart: {
        const first = new Date(viewYear, viewMonth, 1);
        return new Date(viewYear, viewMonth, 1 - (first.getDay() + 6) % 7);
    }

    function isoWeek(d) {
        const t = new Date(d.getFullYear(), d.getMonth(), d.getDate());
        t.setDate(t.getDate() + 3 - (t.getDay() + 6) % 7);     // thursday of this week
        const firstThu = new Date(t.getFullYear(), 0, 4);
        return 1 + Math.round(((t - firstThu) / 86400000 - 3 + (firstThu.getDay() + 6) % 7) / 7);
    }
    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }
    function feteOf(d) {
        const k = String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0");
        return fetes[k] ?? "";
    }
    function cap(s) {
        return s.charAt(0).toUpperCase() + s.slice(1);
    }
    function shiftMonth(n) {
        const d = new Date(viewYear, viewMonth + n, 1);
        viewYear = d.getFullYear();
        viewMonth = d.getMonth();
    }
    function goToday() {
        today = new Date();
        selected = today;
        viewYear = today.getFullYear();
        viewMonth = today.getMonth();
    }

    FileView {
        path: Quickshell.shellDir + "/data/fetes.json"
        onLoaded: panel.fetes = JSON.parse(text())
    }

    // ---------- today block ----------
    Item {
        width: parent.width
        implicitHeight: 84

        Rectangle {
            id: dayTile
            width: 84
            height: 84
            color: Theme.main
            border.width: Theme.bw
            border.color: Theme.border

            Column {
                anchors.centerIn: parent
                BText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: panel.today.getDate()
                    color: Theme.ink
                    font.pixelSize: 38
                    font.weight: Font.Black
                }
                BText {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: panel.monthShort[panel.today.getMonth()]
                    color: Theme.ink
                    font.pixelSize: 11
                    font.weight: Font.Black
                }
            }
        }

        Column {
            anchors.left: dayTile.right
            anchors.leftMargin: 14
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6

            BText {
                width: parent.width
                text: panel.dayNames[panel.today.getDay()].toUpperCase()
                font.pixelSize: 22
                font.weight: Font.Black
            }
            BText {
                width: parent.width
                text: `${panel.monthNames[panel.today.getMonth()]} ${panel.today.getDate()}, ${panel.today.getFullYear()}`
                color: Theme.muted
            }
            Row {
                spacing: 8
                Tag { text: "WEEK " + panel.isoWeek(panel.today); fill: Theme.blue }
                Tag { text: "󰃭 " + panel.feteOf(panel.today); fill: Theme.pink; visible: panel.feteOf(panel.today) !== "" }
            }
        }
    }

    // ---------- month navigation ----------
    Item {
        width: parent.width
        implicitHeight: 32 + Theme.pressOff

        BButton {
            id: prev
            icon: "󰅁"
            padX: 8
            onClicked: panel.shiftMonth(-1)
        }
        BText {
            anchors.left: prev.right
            anchors.right: todayBtn.left
            anchors.verticalCenter: prev.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            text: `${panel.cap(panel.monthNames[panel.viewMonth])} ${panel.viewYear}`.toUpperCase()
            font.pixelSize: 15
            font.weight: Font.Black
        }
        BButton {
            id: todayBtn
            anchors.right: next.left
            anchors.rightMargin: 6
            text: "TODAY"
            fontSize: 11
            fill: Theme.main
            visible: panel.viewMonth !== panel.today.getMonth() || panel.viewYear !== panel.today.getFullYear() || !panel.sameDay(panel.selected, panel.today)
            onClicked: panel.goToday()
        }
        BButton {
            id: next
            anchors.right: parent.right
            icon: "󰅂"
            padX: 8
            onClicked: panel.shiftMonth(1)
        }
    }

    // ---------- grid ----------
    Rectangle {
        id: grid
        readonly property int weekCol: 40
        readonly property real cell: (width - 2 * Theme.bw - weekCol) / 7
        readonly property int rowH: 34

        width: parent.width
        implicitHeight: 2 * Theme.bw + 28 + 6 * rowH
        color: Theme.surface
        border.width: Theme.bw
        border.color: Theme.border

        Column {
            x: Theme.bw
            y: Theme.bw
            width: parent.width - 2 * Theme.bw

            // header row
            Row {
                height: 28
                Rectangle {
                    width: grid.weekCol
                    height: 28
                    color: Theme.border
                    BText {
                        anchors.centerIn: parent
                        text: "WK"
                        color: Theme.dark ? Theme.fg : Theme.surface
                        font.pixelSize: 10
                        font.weight: Font.Black
                    }
                }
                Repeater {
                    model: panel.dayShort
                    Rectangle {
                        required property string modelData
                        required property int index
                        width: grid.cell
                        height: 28
                        color: index >= 5 ? Theme.pink : Theme.main
                        Rectangle { width: parent.width; height: Theme.bwSmall; anchors.bottom: parent.bottom; color: Theme.border }
                        Rectangle { width: Theme.bwSmall; height: parent.height; color: Theme.border }
                        BText {
                            anchors.centerIn: parent
                            text: modelData
                            color: Theme.ink
                            font.pixelSize: 10
                            font.weight: Font.Black
                        }
                    }
                }
            }

            // 6 week rows
            Repeater {
                model: 6
                Row {
                    id: weekRow
                    required property int index
                    readonly property date monday: new Date(panel.gridStart.getFullYear(), panel.gridStart.getMonth(), panel.gridStart.getDate() + 7 * index)
                    height: grid.rowH

                    Rectangle {
                        width: grid.weekCol
                        height: grid.rowH
                        readonly property real offset: (panel.today - weekRow.monday) / 86400000
                        color: offset >= 0 && offset < 7 ? Theme.blue : Theme.bg
                        Rectangle { width: parent.width; height: 1; color: Theme.border; opacity: 0.25 }
                        BText {
                            anchors.centerIn: parent
                            text: panel.isoWeek(weekRow.monday)
                            color: Theme.onFill(parent.color)
                            font.pixelSize: 11
                        }
                    }

                    Repeater {
                        model: 7
                        Item {
                            id: dayCell
                            required property int index
                            readonly property date day: new Date(weekRow.monday.getFullYear(), weekRow.monday.getMonth(), weekRow.monday.getDate() + index)
                            readonly property bool inMonth: day.getMonth() === panel.viewMonth
                            readonly property bool isToday: panel.sameDay(day, panel.today)
                            readonly property bool isSelected: panel.sameDay(day, panel.selected)
                            width: grid.cell
                            height: grid.rowH

                            Rectangle {   // grid lines
                                width: Theme.bwSmall
                                height: parent.height
                                color: Theme.border
                                opacity: 0.25
                            }
                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.border
                                opacity: 0.25
                            }

                            Rectangle {
                                anchors.centerIn: parent
                                width: 30
                                height: 26
                                color: dayCell.isToday ? Theme.main : dayCell.isSelected ? Theme.cyan : cellMa.containsMouse ? Theme.bg : "transparent"
                                border.width: dayCell.isToday || dayCell.isSelected ? Theme.bwSmall : 0
                                border.color: Theme.border

                                BText {
                                    anchors.centerIn: parent
                                    text: dayCell.day.getDate()
                                    color: dayCell.isToday || dayCell.isSelected ? Theme.ink : dayCell.inMonth ? Theme.fg : Theme.muted
                                    opacity: dayCell.inMonth || dayCell.isToday ? 1 : 0.5
                                    font.pixelSize: 13
                                    font.weight: dayCell.isToday ? Font.Black : Font.Bold
                                }
                            }

                            MouseArea {
                                id: cellMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    panel.selected = dayCell.day;
                                    if (!dayCell.inMonth) {
                                        panel.viewYear = dayCell.day.getFullYear();
                                        panel.viewMonth = dayCell.day.getMonth();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------- selected day ----------
    Rectangle {
        width: parent.width
        implicitHeight: 40
        color: panel.sameDay(panel.selected, panel.today) ? Theme.bg : Theme.cyan
        border.width: Theme.bwSmall
        border.color: Theme.border

        BText {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            readonly property string f: panel.feteOf(panel.selected)
            text: `${panel.dayNames[panel.selected.getDay()]}, ${panel.monthNames[panel.selected.getMonth()]} ${panel.selected.getDate()}`
                + (f ? `  ·  󰃭 ${f}` : "")
            color: Theme.onFill(parent.color)
        }
    }

    component Tag: Rectangle {
        property alias text: tagText.text
        property color fill: Theme.main
        width: tagText.implicitWidth + 14
        height: 24
        color: fill
        border.width: Theme.bwSmall
        border.color: Theme.border
        BText {
            id: tagText
            anchors.centerIn: parent
            color: Theme.ink
            font.pixelSize: 11
            font.weight: Font.Black
        }
    }
}
