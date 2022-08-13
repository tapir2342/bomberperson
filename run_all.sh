#!/bin/sh

godot --server . &
sleep 5
godot --position 500,400 . &
godot --position 2000,400 .

killall godot
