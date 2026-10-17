import QtQuick
import qs.theme
import qs.services
import qs.widgets
import "../../lib/format.js" as Format

// Temps (teal) | usage. Click opens the sensors popup (wired in Bar).
Island {
    Metric { icon: Icons.cpuTemp; text: Format.temp(Sensors.cpuTemp); ok: Sensors.cpuTemp !== null; accent: Theme.teal }
    Metric { icon: Icons.gpu; text: Format.temp(Sensors.gpuTemp); ok: Sensors.gpuTemp !== null; accent: Theme.teal }
    Metric { icon: Icons.nvme; text: Format.temp(Sensors.nvmeTemp); ok: Sensors.nvmeTemp !== null; accent: Theme.teal }
    Separator {}
    Metric { icon: Icons.cpu; text: Format.percent(SystemStats.cpuUsage); ok: SystemStats.cpuUsage !== null }
    Metric { icon: Icons.gpu; text: Format.percent(Sensors.gpuUtil); ok: Sensors.gpuUtil !== null }
    Metric { icon: Icons.memory; text: Format.gib(SystemStats.memUsedGiB); ok: SystemStats.memUsedGiB !== null }
}
