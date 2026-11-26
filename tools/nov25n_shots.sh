#!/usr/bin/env bash
# Nov 25 night: the shots of the new panels - the Silver Reserve's choice (Part D), the "Before the fight" panel of postgame fights
# (Parts A and E), and the encounter library's event rooms (Part G). One Godot window at a time; JPGs in docs/overnight_shots/nov25n/.
#   bash tools/nov25n_shots.sh [only=<name part>]
cd "$(dirname "$0")/.."
OUT=docs/overnight_shots/nov25n
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
shot pD_silver_reserve_choice --dungeon=S-GALLERY --silver=true --wait=4
shot pA_before_the_fight_lab_orderly --dungeon=D-LAB --open=brief --quiet=true --wait=4
shot pE_before_the_fight_lab_boss --dungeon=D-LAB --open=brief --brief_boss=true --quiet=true --wait=4
shot pE_before_the_fight_swolympus --dungeon=S-BEEF --open=brief --quiet=true --wait=4
shot pD_before_the_fight_echo_quota --dungeon=S-GALLERY --open=brief --quiet=true --wait=4
shot pG_L1_gallery_weight_of_glass --dungeon=S-GALLERY --open=event --event_id=dg_s_gallery_3 --wait=4
shot pG_L8_gallery_reflected_patrol --dungeon=S-GALLERY --open=event --event_id=dg_s_gallery_6 --wait=4
shot pG_L2_gallery_silent_glass --dungeon=S-GALLERY --open=event --event_id=dg_s_gallery_12 --wait=4
shot pG_L6_lab_specimen_trial --dungeon=D-LAB --open=event --event_id=dg_d_lab_4 --quiet=true --wait=4
shot pG_L7_lab_hedge_wizard --dungeon=D-LAB --open=event --event_id=dg_d_lab_7 --quiet=true --wait=4
shot pG_L5_ttk_head_chef --dungeon=D-TTK --open=event --event_id=dg_d_ttk_9 --wait=4
shot pG_L6_ttk_taste_test_rex --dungeon=D-TTK --open=event --event_id=dg_d_ttk_10 --wait=4
shot pG_L10_hog_coach --dungeon=D-HOG --open=event --event_id=dg_d_hog_5 --wait=4
shot pG_L9_hfa_night_patrol --dungeon=D-HFA --open=event --event_id=dg_d_hfa_12 --wait=4
shot pG_L3_castle_oath_of_order --dungeon=D-PC --open=event --event_id=dg_d_pc_6 --quiet=true --wait=4
