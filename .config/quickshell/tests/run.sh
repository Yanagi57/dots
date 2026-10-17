#!/bin/sh
# Run QML unit tests headless. Optional arg: a single tst_*.qml file.
here="$(cd "$(dirname "$0")" && pwd)"
QT_QPA_PLATFORM=offscreen exec /usr/lib/qt6/bin/qmltestrunner -input "${1:-$here}"
