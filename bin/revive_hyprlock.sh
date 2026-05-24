#!/bin/bash

hyprctl --instance 0 eval 'hl.config({ misc = { allow_session_lock_restore=1 } })'
hyprctl --instance 0 'dispatch hl.dsp.exec_cmd("hyprlock")'
