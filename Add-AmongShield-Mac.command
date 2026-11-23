#!/bin/bash
# Adds the "AmongShield" server to Among Us on a Mac that plays the Windows version through
# CrossOver, Whisky, Wine or Porting Kit. Quit Among Us first, then open Terminal and run:
#   bash ~/Downloads/Add-AmongShield-Mac.command
# It only edits Among Us's server list and saves a backup copy first. Nothing is downloaded or installed.
shopt -s nullglob

finish() {  # $1 = message, $2 = ok | error
  if [ "$2" = ok ]; then printf '\n\033[32m%s\033[0m\n\n' "$1"; icon=note; else printf '\n\033[31m%s\033[0m\n\n' "$1"; icon=stop; fi
  osascript -e 'on run argv' -e "display dialog (item 1 of argv) with title \"AmongShield\" buttons {\"OK\"} default button 1 with icon $icon" -e 'end run' "$1" >/dev/null 2>&1
  exit 0
}
help=$'\n\nStill stuck? Tell us what this message says at github.com/AmongShieldServer/AmongShield/issues'

if pgrep -f '[A]mong Us\.exe' >/dev/null 2>&1; then
  finish $'Among Us is still open.\n\nQuit Among Us completely (and close its CrossOver window), then run this again.' error
fi

# Where the Windows version keeps its server list inside each CrossOver bottle / Whisky bottle / Wine prefix / wrapper
au='drive_c/users/*/AppData/LocalLow/Innersloth/Among Us'
IFS=$'\n'  # "Among Us" has a space: only split on new lines while the folder list is built
dirs=("$HOME/Library/Application Support/CrossOver/Bottles"/*/$au
       "$HOME/Library/Containers/com.isaacmarovitz.Whisky/Bottles"/*/$au
       "$HOME/.wine"/$au
       "$HOME/Applications"/*.app/Contents/SharedSupport/prefix/$au
       /Applications/*.app/Contents/SharedSupport/prefix/$au )
unset IFS
files=()
for d in "${dirs[@]}"; do [ -f "$d/regionInfo.json" ] && files+=("$d/regionInfo.json"); done
if [ ${#files[@]} -eq 0 ]; then
  finish "Among Us's server list wasn't found on this Mac.

This works for the Windows version of Among Us running in CrossOver, Whisky, Wine or Porting Kit. Start Among Us there once and wait for the main menu, quit it, then run this again.

Playing the App Store (iPhone/iPad) version on an Apple Silicon Mac instead? Open Among Us, then click \"Add AmongShield to Among Us\" on amongshieldserver.github.io/AmongShield.$help" error
fi

# Edits one server list with macOS's built-in JavaScript: keeps every other server, adds AmongShield, selects it.
edit() {
  osascript -l JavaScript - "$1" 2>&1 <<'JS'
function run(argv) {
  ObjC.import('Foundation');
  const path = argv[0];
  const text = $.NSString.stringWithContentsOfFileEncodingError(path, $.NSUTF8StringEncoding, null);
  if (!text || text.isNil()) return 'UNREADABLE';
  let list;
  try { list = JSON.parse(ObjC.unwrap(text).replace(/^﻿/, '')); } catch (e) { return 'DAMAGED'; }
  if (!list || !Array.isArray(list.Regions)) return 'DAMAGED';
  list.Regions = list.Regions.filter(r => !r || r.Name !== 'AmongShield');
  list.Regions.push({ '$type': 'StaticHttpRegionInfo, Assembly-CSharp', Name: 'AmongShield', PingServer: 'amongshield.duckdns.org',
    Servers: [{ Name: 'http-1', Ip: 'https://amongshield.duckdns.org', Port: 443, UseDtls: false, Players: 0, ConnectionFailures: 0 }],
    TargetServer: null, TranslateName: 1003 });
  list.CurrentRegionIdx = list.Regions.length - 1;
  return $(JSON.stringify(list)).writeToFileAtomicallyEncodingError(path, true, $.NSUTF8StringEncoding, null) ? 'OK' : 'NOWRITE';
}
JS
}

backups="$HOME/Library/Application Support/AmongShield-backup"
mkdir -p "$backups"
done_n=0; problems=""; n=0
for f in "${files[@]}"; do
  n=$((n + 1))
  if ! cp "$f" "$backups/regionInfo-$n.json" 2>/dev/null; then problems+=$'\n- '"couldn't make a backup of $f, so it was left alone"; continue; fi
  result=$(edit "$f")
  case "$result" in
    OK) done_n=$((done_n + 1)) ;;
    DAMAGED) problems+=$'\n- '"the server list file is damaged. Delete it, start Among Us once, quit it and run this again: $f" ;;
    UNREADABLE|NOWRITE) problems+=$'\n- '"macOS didn't allow the change (file in use or protected). Quit Among Us and CrossOver, then try again: $f" ;;
    *) problems+=$'\n- '"$result" ;;
  esac
done

if [ $done_n -gt 0 ] && [ -z "$problems" ]; then
  finish $'Server successfully added!\n\nPlease start Among Us. AmongShield is already selected in the region menu (the globe button).\n\nTo play on normal servers again, pick North America, Europe or Asia there.' ok
fi
if [ $done_n -gt 0 ]; then
  finish "AmongShield was added, so you can start Among Us. But one copy of the game couldn't be updated:$problems$help" ok
fi
finish "AmongShield couldn't be added:$problems$help" error
