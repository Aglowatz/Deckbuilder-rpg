#!/usr/bin/env bash
# Copies the audio files named in app/audio_catalog.gd from _asset_library/ to assets/audio/
# (keeping each pack's folder name and license file). Run after editing the catalog.
cd "$(dirname "$0")/.."
grep -o 'res://assets/audio/kenney_[^"]*\.ogg' app/audio_catalog.gd >/dev/null
for pack in ui-audio interface-sounds impact-sounds rpg-audio casino-audio music-jingles; do
	mkdir -p "assets/audio/kenney_$pack"
	cp "_asset_library/kenney-$pack/License.txt" "assets/audio/kenney_$pack/License.txt"
done
python_free_copy() {
	local pack="$1" prefix="$2" file="$3"
	mkdir -p "$(dirname "assets/audio/kenney_$pack/$file")"
	cp "_asset_library/kenney-$pack/Audio/$file" "assets/audio/kenney_$pack/$file"
}
# Resolve the const prefixes used in the catalog to pack names, then copy every referenced file.
declare -A PACKS=([UI]=ui-audio [IFACE]=interface-sounds [IMPACT]=impact-sounds [RPG]=rpg-audio [CASINO]=casino-audio [JINGLE]=music-jingles)
grep -oE '(UI|IFACE|IMPACT|RPG|CASINO|JINGLE) \+ "[^"]+\.ogg"' app/audio_catalog.gd | sort -u | while read -r prefix _ file; do
	file="${file//\"/}"
	python_free_copy "${PACKS[$prefix]}" "$prefix" "$file"
done
echo "audio synced"
