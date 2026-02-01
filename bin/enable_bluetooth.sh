#!/usr/bin/env bash

sudo rfkill unblock bluetooth
sudo systemctl unmask bluetooth.service
sudo systemctl enable --now bluetooth.service
echo "Bluetooth service has been started and enabled to start on boot."
