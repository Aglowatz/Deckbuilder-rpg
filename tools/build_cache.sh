#!/usr/bin/env bash
# Performance pass Oct 25 (world/build_cache.gd): the zone build cache.
#   bash tools/build_cache.sh status   - the development cache folders and the baked manifest
#   bash tools/build_cache.sh clear    - force a rebuild: deletes the development cache (the next visit to each area rebuilds it)
#   bash tools/build_cache.sh bake     - builds every area into res://build_cache/ for an export (tools/export_windows.sh runs this)
#   bash tools/build_cache.sh unbake   - deletes res://build_cache/ (the game then builds live / from the development cache)
# Single runs can skip the cache with WAYWARD_BUILD_CACHE=off or rebuild everything they touch with WAYWARD_BUILD_CACHE=rebuild.
cd "$(dirname "$0")/.."
dev="$APPDATA/Deckbuilder-RPG/build_cache"
case "$1" in
	status)
		echo "development cache: $dev"
		ls -la "$dev" 2>/dev/null || echo "  (empty)"
		for d in "$dev"/*/; do [ -d "$d" ] && echo "  $(basename "$d"): $(ls "$d" | wc -l) results, $(du -sh "$d" | cut -f1)"; done
		echo "baked: build_cache/"
		cat build_cache/manifest.json 2>/dev/null || echo "  (not baked)"
		;;
	clear)
		rm -rf "$dev" && echo "cleared $dev"
		;;
	bake)
		/c/Tools/Godot/Godot_v4.7.2-stable_win64.exe --path . --resolution 1280x720 -s res://tools/bake_build_cache.gd 2>&1 | grep -E "bake_build_cache|ERROR|SCRIPT ERROR" | grep -v "^$"
		;;
	unbake)
		rm -rf build_cache && echo "removed build_cache/"
		;;
	*)
		echo "usage: bash tools/build_cache.sh status|clear|bake|unbake"
		;;
esac
