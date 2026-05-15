import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    property bool helperInstalled: false
    property bool loading: false

    ListModel { id: coreModel }

    Plasma5Support.DataSource {
        id: cmdSource
        engine: "executable"
        connectedSources: []

        onNewData: function(source, data) {
            disconnectSource(source)
            var out = data["stdout"].trim()

            if (source.startsWith("test ")) {
                root.helperInstalled = out === "1"
                if (root.helperInstalled) root.loadCores()
                return
            }

            if (source.startsWith("pkexec ")) {
                root.loadCores()
                return
            }

            root.parseCores(out)
        }
    }

    function checkHelper() {
        cmdSource.connectSource("test -x /usr/lib/koretoggle-helper && echo 1 || echo 0")
    }

    function loadCores() {
        loading = true
        cmdSource.connectSource(
            "for d in /sys/devices/system/cpu/cpu[0-9]*/; do " +
            "b=$(basename $d); f=${d}online; " +
            "[ -f $f ] && echo \"$b $(cat $f)\" || echo \"$b -1\"; " +
            "done | sort -V"
        )
    }

    function parseCores(out) {
        coreModel.clear()
        var lines = out.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var parts = lines[i].trim().split(" ")
            if (parts.length < 2) continue
            var num = parseInt(parts[0].replace("cpu", ""))
            if (isNaN(num)) continue
            coreModel.append({
                coreNum: num,
                alwaysOn: parts[1] === "-1",
                online: parts[1] === "1"
            })
        }
        loading = false
    }

    function toggleCore(coreNum, currentOnline) {
        cmdSource.connectSource(
            "pkexec /usr/lib/koretoggle-helper " + coreNum + " " + (currentOnline ? 0 : 1)
        )
    }

    compactRepresentation: Item {
        Kirigami.Icon {
            anchors.fill: parent
            anchors.margins: 4
            source: "cpu"
            active: compactMouse.containsMouse
        }
        MouseArea {
            id: compactMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: ColumnLayout {
        spacing: 0
        Layout.minimumWidth: 240
        Layout.preferredWidth: 240
        Layout.maximumWidth: 240

        Component.onCompleted: root.checkHelper()

        ColumnLayout {
            visible: !root.helperInstalled && !root.loading
            Layout.fillWidth: true
            Layout.margins: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                source: "dialog-warning"
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: Kirigami.Units.iconSizes.large
                implicitHeight: Kirigami.Units.iconSizes.large
            }
            PlasmaComponents.Label {
                text: "Helper not installed"
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
            PlasmaComponents.Label {
                text: "sudo ./install.sh"
                font.family: "monospace"
                opacity: 0.7
                Layout.alignment: Qt.AlignHCenter
            }
        }

        ListView {
            id: coreList
            visible: root.helperInstalled && !root.loading
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            model: coreModel
            delegate: RowLayout {
                width: coreList.width
                spacing: 0

                PlasmaComponents.Label {
                    text: "CPU " + model.coreNum
                    Layout.fillWidth: true
                    leftPadding: Kirigami.Units.largeSpacing
                    topPadding: Kirigami.Units.smallSpacing
                    bottomPadding: Kirigami.Units.smallSpacing
                }
                PlasmaComponents.Label {
                    visible: model.alwaysOn
                    text: "always on"
                    opacity: 0.5
                    rightPadding: Kirigami.Units.largeSpacing
                }
                Controls.Switch {
                    visible: !model.alwaysOn
                    checked: model.online
                    rightPadding: Kirigami.Units.largeSpacing
                    onClicked: root.toggleCore(model.coreNum, model.online)
                }
            }
        }

        PlasmaComponents.BusyIndicator {
            visible: root.loading
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Kirigami.Units.largeSpacing
        }
    }
}
