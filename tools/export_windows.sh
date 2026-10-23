#!/usr/bin/env bash
# Windows export with the build-size guard (docs/build_size.md) and the broken-build guard (docs/release/how_to_build.md).
# Usage: bash tools/export_windows.sh [version]        (default: config/version from project.godot)
# Run it in the foreground with Godot closed. It takes about 4 minutes and needs about 2 GB of free RAM (see NEED_FREE_MB).
#   0. preflight: no Godot running, enough free RAM (warns, lists what to close) and disk, dev folders carry a .gdignore
#   1. regenerates the export excludes (unreferenced 3D models) and applies tools/art_import_rules.json
#   2. imports in its own headless Godot run, so the export itself only packs (no texture is converted during the export)
#   3. exports into builds/_export.new (windowed: the shader baker needs a rendering device; headless skips it silently)
#   4. checks the build: Godot's exit code and log, the exe, the .pck (complete, every MD5, baked shaders, size), the tester kit
#   5. zips with tar.exe (streams from disk; Compress-Archive held ~1.6 GB) to a .partial file and tests every entry's CRC
#   6. only then swaps builds/_export and the zip in; the previous good zip stays until the new one has passed every check
# Any failure stops with "EXPORT STOPPED" and leaves builds/_export and the zip exactly as they were.
# Peak memory of each Godot run is sampled by tools/measure_process.ps1; logs go to _logs/export/.
set -u -o pipefail
GODOT="C:/Tools/Godot/Godot_v4.7.2-stable_win64_console.exe"
BUDGET_MB=800
# Measured Oct 23 on this 7.4 GB laptop: the windowed export with the shader baker peaks at ~1.7 GB (the editor ~1.45 GB + the
# baker ~0.25 GB); the headless import ~1.0-1.2 GB; tar and the checks almost nothing. Below NEED it warns; below MIN it stops.
NEED_FREE_MB=${NEED_FREE_MB:-2000}
MIN_FREE_MB=${MIN_FREE_MB:-1200}
NEED_DISK_MB=2500
cd "$(dirname "$0")/.."
version="${1:-$(grep '^config/version=' project.godot | sed 's/.*="\(.*\)"/\1/')}"
final="builds/_export"
stage="builds/_export.new"
zip_path="builds/TheWaywardPath-v${version}-windows.zip"
zip_tmp="${zip_path}.partial"
logs="_logs/export"
mkdir -p "$logs" builds

swapping=0
cleanup() {
	# a stage or a half-written zip never survives a stopped run; the final folder and zip are only touched by the swap below
	if [ "$swapping" = 0 ]; then rm -rf "$stage" "$zip_tmp"; fi
}
trap cleanup EXIT
stop() {
	echo ""
	echo "EXPORT STOPPED: $*"
	echo "Nothing was replaced: $final and $zip_path are as they were before this run."
	exit 1
}
mb_of() { du -m "$1" 2>/dev/null | awk '{print $1+0}'; }
bytes_of() { stat -c %s "$1" 2>/dev/null || echo 0; }

# A run killed in the middle of the swap leaves the previous build next to the final name; put it back.
if [ ! -d "$final" ] && [ -d "$final.prev" ]; then mv "$final.prev" "$final"; fi
if [ ! -f "$zip_path" ] && [ -f "$zip_path.prev" ]; then mv "$zip_path.prev" "$zip_path"; fi
rm -rf "$final.prev" "$zip_path.prev" "$stage" "$zip_tmp"

echo "=== The Wayward Path v${version}: Windows export ==="
# --- 0. preflight ---
if tasklist 2>/dev/null | grep -qi '^godot'; then
	tasklist | grep -i '^godot'
	stop "Godot is running. Close the editor and any game/smoke window (or run: taskkill //F //IM Godot_v4.7.2-stable_win64.exe), then run this again."
fi
free_mb=$(powershell.exe -NoProfile -Command "[int](New-Object System.Diagnostics.PerformanceCounter('Memory','Available MBytes')).NextValue()" | tr -d '\r')
free_mb=${free_mb:-0}
echo "free RAM: ${free_mb} MB (the export needs about ${NEED_FREE_MB} MB)"
if [ "$free_mb" -lt "$NEED_FREE_MB" ]; then
	echo ""
	echo "WARNING: only ${free_mb} MB of RAM is free; the export peaks at about 1.7 GB and runs slowly (or stalls) when it has to page."
	echo "Close what you can first - the biggest programs running now:"
	powershell.exe -NoProfile -Command "Get-Process | Where-Object { \$_.ProcessName -notmatch '^(System|Idle|Memory Compression|Registry|MsMpEng|svchost|csrss|smss|wininit|services|lsass|dwm|fontdrvhost|winlogon)$' } | Group-Object ProcessName | ForEach-Object { [pscustomobject]@{ Name = \$_.Name; MB = [int](((\$_.Group | Measure-Object WorkingSet64 -Sum).Sum) / 1MB) } } | Sort-Object MB -Descending | Select-Object -First 8 | ForEach-Object { '   {0,6} MB  {1}' -f \$_.MB, \$_.Name }" | tr -d '\r'
	echo "   (browsers, Discord, other Claude/terminal sessions and a running Godot editor are the usual ones)"
	if [ "$free_mb" -lt "$MIN_FREE_MB" ] && [ "${EXPORT_LOW_MEMORY_OK:-0}" != 1 ]; then
		stop "under ${MIN_FREE_MB} MB free. Close the programs above and run this again (EXPORT_LOW_MEMORY_OK=1 runs anyway, slowly)."
	fi
	echo ""
fi
disk_mb=$(df -m . | awk 'NR==2 {print $4}')
if [ "${disk_mb:-0}" -lt "$NEED_DISK_MB" ]; then stop "only ${disk_mb} MB free on the drive; the export needs about ${NEED_DISK_MB} MB (stage + zip). Free some disk space first."; fi
# Working folders the game never loads: Godot skips a folder with a .gdignore, so new inbox art (full-size PNGs) is never imported
# or scanned during a build. The art tools read these folders with Image.load_from_file, which does not need an import.
for d in _art_inbox _art_source _screenshots _logs _reference _tmp_tools builds; do [ -d "$d" ] && [ ! -f "$d/.gdignore" ] && : > "$d/.gdignore"; done

# --- 1. excludes and import rules ---
node tools/update_export_excludes.js || stop "update_export_excludes.js failed"
node tools/apply_import_rules.js || stop "apply_import_rules.js failed"

measure() { # <log name> <godot args...>: runs Godot in the foreground, sampling memory; prints the MEASURE lines
	local name="$1"; shift
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/measure_process.ps1 -Exe "$GODOT" -ArgList "$*" \
		-Log "$logs/$name.log" -Csv "$logs/$name.csv" | tr -d '\r' | tee "$logs/$name.measure"
	return "${PIPESTATUS[0]}"
}
peak_of() { sed -n 's/.*peak_working_set_mb=\([0-9]*\).*/\1/p' "$logs/$1.measure" | head -1; }

# --- 2. import (own process) ---
echo "--- importing (headless) ---"
measure import --headless --path . --import || stop "the import exited with code $? (log: $logs/import.log)"
echo "--- estimated payload before export ---"
node tools/build_audit.js --md docs/build_size.md --quiet
est_mb=$(sed -n 's/^Estimated export payload: \*\*\([0-9.]*\) MB.*/\1/p' docs/build_size.md | head -1 | cut -d. -f1)
est_mb=${est_mb:-0}

# --- 3. export into the stage ---
echo "--- exporting to $stage (windowed, with the shader baker; about 2.5 minutes) ---"
mkdir -p "$stage"
measure export --path . --export-release '"Windows Desktop"' "$stage/TheWaywardPath.exe"
code=$?
[ "$code" = 0 ] || stop "Godot exited with code $code - killed or failed (log: $logs/export.log)"
# Any Godot ERROR line stops the build, except the at-exit resource note every run prints (a file named error_004.ogg is not an error).
if sed 's/\x1b\[[0-9;]*m//g' "$logs/export.log" | grep -E "^(ERROR|SCRIPT ERROR):" | grep -v "resources still in use at exit"; then
	stop "Godot reported an export error (log: $logs/export.log)"
fi

# --- 4. check the build ---
echo "--- checking the build ---"
exe="$stage/TheWaywardPath.exe"
pck="$stage/TheWaywardPath.pck"
[ -f "$exe" ] || stop "no exe in $stage"
[ "$(bytes_of "$exe")" -gt 50000000 ] || stop "the exe is only $(bytes_of "$exe") bytes (expected ~100 MB)"
[ -f "$pck" ] || stop "no .pck in $stage"
min_pck=$(( est_mb * 9 / 10 ))
[ "$min_pck" -lt 300 ] && min_pck=300
node tools/verify_pck.js "$pck" --min-mb="$min_pck" --min-shaders=40 || stop "the .pck is incomplete or unreadable"
cp tools/playtest_kit/*.bat "$stage/" || stop "could not copy the launchers"
node -e "const fs=require('fs');fs.writeFileSync(process.argv[2],fs.readFileSync(process.argv[1],'utf8').replace(/\r?\n/g,'\r\n'))" tools/playtest_kit/README_PLAYTEST.txt "$stage/README_PLAYTEST.txt" || stop "could not write README_PLAYTEST.txt"
expected=$( (cd "$stage" && ls -1) | sort)
pck_mb=$(mb_of "$pck")
total_mb=$(du -sm "$stage" | awk '{print $1}')
echo "pck: ${pck_mb} MB, folder: ${total_mb} MB"
if [ "$pck_mb" -gt "$BUDGET_MB" ]; then
	echo "WARNING: the export is ${pck_mb} MB, over the ${BUDGET_MB} MB budget. See docs/build_size.md for what is large."
fi

# --- 5. zip (streamed by tar.exe; --format zip, because -a would pick tar from the .partial extension) and test it ---
echo "--- zipping ---"
(cd "$stage" && /c/Windows/System32/tar.exe --format zip -c -f "../../$zip_tmp" *) || stop "tar.exe could not write the zip"
unzip -tq "$zip_tmp" >/dev/null || stop "the new zip failed its CRC test"
listed=$(unzip -Z1 "$zip_tmp" | sort)
[ "$listed" = "$expected" ] || stop "the zip lists different files than the build folder: $(echo $listed)"
for need in TheWaywardPath.exe TheWaywardPath.pck README_PLAYTEST.txt "Start (Safe Mode).bat"; do
	echo "$listed" | grep -qxF "$need" || stop "the zip has no $need"
done
zip_bytes=$(bytes_of "$zip_tmp")
low=$(( ($(bytes_of "$pck") + $(bytes_of "$exe")) * 6 / 10 ))
high=$(du -sb "$stage" | awk '{print $1}')
if [ "$zip_bytes" -lt "$low" ] || [ "$zip_bytes" -gt "$high" ]; then stop "the zip is $zip_bytes bytes, outside the expected $low - $high"; fi

# --- 6. swap in ---
swapping=1
[ -d "$final" ] && mv "$final" "$final.prev"
mv "$stage" "$final"
[ -f "$zip_path" ] && mv "$zip_path" "$zip_path.prev"
mv "$zip_tmp" "$zip_path"
rm -rf "$final.prev" "$zip_path.prev"
swapping=0

zip_mb=$(mb_of "$zip_path")
echo "--- exported ---"
echo "zip: $zip_path = ${zip_mb} MB (checked: CRCs, contents, size); build folder: $final"
echo "peak memory: import $(peak_of import) MB, export $(peak_of export) MB (Godot working set; logs in $logs/)"
echo "--- size by category ---"
node tools/build_audit.js | sed -n '1,/^### 30 largest/p' | head -30
echo "EXPORT OK"
