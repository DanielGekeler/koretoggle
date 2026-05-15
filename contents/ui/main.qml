import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
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

            // core state read result
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
        PlasmaComponents.Label {
            anchors.centerIn: parent
            text: "CPU"
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: ColumnLayout {
        implicitWidth: 280

        Component.onCompleted: root.checkHelper()

        PlasmaComponents.Label {
            visible: !root.helperInstalled && !root.loading
            text: "Helper not installed.\nRun: sudo ./install.sh"
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            Layout.margins: 12
        }

        ListView {
            id: coreList
            visible: root.helperInstalled && !root.loading
            Layout.fillWidth: true
            Layout.preferredHeight: contentHeight
            model: coreModel
            delegate: RowLayout {
                width: coreList.width
                PlasmaComponents.Label {
                    text: "CPU " + model.coreNum
                    Layout.fillWidth: true
                }
                PlasmaComponents.Label {
                    visible: model.alwaysOn
                    text: "always on"
                    opacity: 0.5
                }
                Controls.Switch {
                    visible: !model.alwaysOn
                    checked: model.online
                    onClicked: root.toggleCore(model.coreNum, model.online)
                }
            }
        }

        PlasmaComponents.BusyIndicator {
            visible: root.loading
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
