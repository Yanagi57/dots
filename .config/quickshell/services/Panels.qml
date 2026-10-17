pragma Singleton
import Quickshell
import QtQuick

// Lets bar widgets open full-screen panels without holding references to them.
Singleton {
    signal powerMenuRequested()
}
