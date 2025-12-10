#!/usr/bin/env bash

sudo systemctl unmask bluetooth.service
sudo systemctl start bluetooth.service
echo "Bluetooth service has been started."
sudo systemctl enable bluetooth.service
echo "Bluetooth service has been enabled to start on boot."
