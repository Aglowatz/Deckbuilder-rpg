#!/usr/bin/env bash
# Nov 26 day (Part C): the "Before the fight" panel of one new-rules fight in each zone dungeon. One Godot window at a time;
# JPGs in docs/overnight_shots/nov26/.   bash tools/nov26_shots.sh [only=<name part>]
cd "$(dirname "$0")/.."
OUT=docs/overnight_shots/nov26
mkdir -p "$OUT"
ONLY="${1:-}"
MAP=res://scenes/dungeon_map.tscn
shot() {
	local name="$1"; shift
	[ -n "$ONLY" ] && [[ "$name" != *"$ONLY"* ]] && return
	bash tools/shot.sh "$MAP" "$name" "$@" > /dev/null 2>&1
	if [ -f "_screenshots/$name.png" ]; then
		python -c "from PIL import Image; Image.open('_screenshots/$name.png').convert('RGB').save('$OUT/$name.jpg', quality=86)"
		echo "shot $name"
	else
		echo "MISSING $name"
	fi
}
shot pC_before_the_fight_hog_8_cell_block --dungeon=D-HOG --open=brief --brief_room=8 --quiet=true --wait=4
shot pC_before_the_fight_ttk_3_frozen_cook --dungeon=D-TTK --open=brief --brief_room=3 --quiet=true --wait=4
shot pC_before_the_fight_ttk_12_expediter --dungeon=D-TTK --open=brief --brief_room=12 --quiet=true --wait=4
shot pC_before_the_fight_hfa_3_intake --dungeon=D-HFA --open=brief --brief_room=3 --quiet=true --wait=4
shot pC_before_the_fight_hfa_13_elevator --dungeon=D-HFA --open=brief --brief_room=13 --quiet=true --wait=4
shot pC_before_the_fight_rot_2_scarecrow --dungeon=D-ROT --open=brief --brief_room=2 --quiet=true --wait=4
shot pC_before_the_fight_rot_11_tunnel --dungeon=D-ROT --open=brief --brief_room=11 --quiet=true --wait=4
shot pC_before_the_fight_castle_5_curator --dungeon=D-PC --open=brief --brief_room=5 --quiet=true --wait=4
shot pD_event_ttk_head_chef_wrapped --dungeon=D-TTK --open=event --event_id=dg_d_ttk_10 --wait=4
