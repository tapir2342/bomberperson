#!/bin/sh

godot --server . &
godot --position 500,400 . &
godot --position 2000,400 .

killall godot
