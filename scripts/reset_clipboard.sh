#!/bin/bash

echo "Restarting macOS Continuity and clipboard services..."

killall sharingd 2>/dev/null
killall useractivityd 2>/dev/null
killall pboard 2>/dev/null

echo "Done."
