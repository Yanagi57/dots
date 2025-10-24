#!/bin/bash

sudo systemctl disable bluetooth.service
sudo systemctl stop bluetooth.service
echo "Bluetooth service has been disabled and stopped."

sudo systemctl mask bluetooth.service
echo "Bluetooth service has been masked to prevent it from being started manually or automatically."
