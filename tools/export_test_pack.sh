#!/usr/bin/env bash
# Overnight Oct 22, Part 5: a test pack = the release export's content plus tools/ (the bots), so the windowed bots can run on exported
# resources (imports, compression, baked shaders) with the stock binary (tools/run_exported_suite.sh). Run after tools/export_windows.sh
# (which applies the import rules and re-imports). Writes builds/_testpack/TheWaywardPath_test.pck. export_presets.cfg is restored after.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
cd "$(dirname "$0")/.."
out="builds/_testpack"
mkdir -p "$out"
cp -f export_presets.cfg export_presets.cfg.testpack_backup
# The first preset's exclude filter without "tools/*" (tests, docs and the rest stay out).
node -e "const fs=require('fs');let s=fs.readFileSync('export_presets.cfg','utf8');const i=s.indexOf('exclude_filter=\"');const j=s.indexOf('\n',i);s=s.slice(0,i)+s.slice(i,j).replace('tools/*, ','')+s.slice(j);fs.writeFileSync('export_presets.cfg',s)"
"$GODOT" --path . --export-pack "Windows Desktop" "$out/TheWaywardPath_test.pck" 2>&1 | grep -E "ERROR|savepack" | head -10
mv -f export_presets.cfg.testpack_backup export_presets.cfg
ls -la "$out"/*.pck
