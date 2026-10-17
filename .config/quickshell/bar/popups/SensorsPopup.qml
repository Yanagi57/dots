import QtQuick
import QtQuick.Layouts
import qs.theme
import qs.services
import qs.widgets
import "../../lib/format.js" as Format

BarPopup {
    name: "sensors"

    ColumnLayout {
        spacing: 6

        StyledText { text: "Last 60 s"; color: Theme.gold; font.bold: true }

        SensorRow {
            label: "CPU temp"; value: Format.temp(Sensors.cpuTemp); ok: Sensors.cpuTemp !== null
            history: Sensors.cpuTempHistory; capacity: Sensors.historyLength
        }
        SensorRow {
            label: "GPU temp"; value: Format.temp(Sensors.gpuTemp); ok: Sensors.gpuTemp !== null
            history: Sensors.gpuTempHistory; capacity: Sensors.historyLength
        }
        SensorRow {
            label: "NVMe temp"; value: Format.temp(Sensors.nvmeTemp); ok: Sensors.nvmeTemp !== null
            history: Sensors.nvmeTempHistory; capacity: Sensors.historyLength
        }
        SensorRow {
            label: "CPU"; value: Format.percent(SystemStats.cpuUsage); ok: SystemStats.cpuUsage !== null
            history: SystemStats.cpuHistory; capacity: SystemStats.historyLength; lineColor: Theme.gold
        }
        SensorRow {
            label: "GPU"; value: Format.percent(Sensors.gpuUtil); ok: Sensors.gpuUtil !== null
            history: Sensors.gpuUtilHistory; capacity: Sensors.historyLength; lineColor: Theme.gold
        }
        SensorRow {
            label: "RAM"; value: Format.gib(SystemStats.memUsedGiB); ok: SystemStats.memUsedGiB !== null
            history: SystemStats.memHistory; capacity: SystemStats.historyLength; lineColor: Theme.gold
        }
    }
}
