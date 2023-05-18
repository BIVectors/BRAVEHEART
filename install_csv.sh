#!/usr/bin/env bash
echo -e "\n\nINSTALLING BRAVEHEART CSV FILES TO ~/braveheart\n"
currentdir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo -e "Current Directory = $currentdir\n"
mkdir -p ~/braveheart
cd $currentdir
mv *.csv ~/braveheart
echo -e "CSV FILE INSTALL COMPLETE!"
echo -n -e "\033]0;braveheartterminal\007"
osascript -e 'tell application "Terminal" to close (every window whose name contains "braveheartterminal")' &