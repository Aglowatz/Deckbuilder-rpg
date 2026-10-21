#!/usr/bin/env bash
# Windows export with the build-size guard (docs/build_size.md).
# Usage: bash tools/export_windows.sh [version]        (default: config/version from project.godot)
#   1. regenerates the export excludes (unreferenced 3D models) and applies tools/art_import_rules.json
#   2. re-imports, then estimates the payload by category and warns above the 800 MB budget
#   3. exports to builds/_export/, adds tools/playtest_kit (launchers + README_PLAYTEST.txt) and zips to builds/TheWaywardPath-v<version>-windows.zip
#   4. prints the real pck/zip size and the size-by-category summary again
# One Godot process at a time. The estimate and the real size are both printed; a warning is not an error.
GODOT="/c/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
BUDGET_MB=800
cd "$(dirname "$0")/.."
version="${1:-$(grep '^config/version=' project.godot | sed 's/.*="\(.*\)"/\1/')}"
out="builds/_export"
zip_path="builds/TheWaywardPath-v${version}-windows.zip"

node tools/update_export_excludes.js || exit 1
node tools/apply_import_rules.js || exit 1
"$GODOT" --headless --path . --import >/dev/null 2>&1
echo "--- estimated payload before export ---"
node tools/build_audit.js --md docs/build_size.md --quiet

rm -rf "$out"
mkdir -p "$out"
"$GODOT" --headless --path . --export-release "Windows Desktop" "$out/TheWaywardPath.exe" 2>&1 | grep -E "ERROR|error|Error|WARNING: .*export|savepack|Packing" | head -20
if [ ! -f "$out/TheWaywardPath.exe" ]; then echo "EXPORT FAILED: no exe in $out"; exit 1; fi

pck_mb=$(du -m "$out"/*.pck 2>/dev/null | awk '{s+=$1} END {print s+0}')
total_mb=$(du -sm "$out" | awk '{print $1}')
echo "--- exported ---"
echo "pck: ${pck_mb} MB, folder: ${total_mb} MB"
if [ "$pck_mb" -gt "$BUDGET_MB" ]; then
	echo "WARNING: the export is ${pck_mb} MB, over the ${BUDGET_MB} MB budget. See docs/build_size.md for what is large."
fi

# Overnight Oct 20: the tester kit (Safe Mode / Vulkan / DirectX 12 / Verbose Log launchers, README_PLAYTEST.txt) goes next to the exe.
cp tools/playtest_kit/*.bat "$out/"
node -e "const fs=require('fs');fs.writeFileSync(process.argv[2],fs.readFileSync(process.argv[1],'utf8').replace(/\r?\n/g,'\r\n'))" tools/playtest_kit/README_PLAYTEST.txt "$out/README_PLAYTEST.txt"
rm -f "$zip_path"
(cd "$out" && powershell.exe -NoProfile -Command "Compress-Archive -Path '*' -DestinationPath '../../$zip_path' -CompressionLevel Optimal")
zip_mb=$(du -m "$zip_path" | awk '{print $1}')
echo "zip: $zip_path = ${zip_mb} MB"
echo "--- size by category ---"
node tools/build_audit.js | sed -n '1,/^### 30 largest/p' | head -30
