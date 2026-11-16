class_name VaultLeverEvent
extends RefCounted
## Brief 16, Group G: pulling a hidden vault lever. A heavy mechanical clunk and a short screen shake, then a notice that something
## happened far away. Fable Nov 16b (Part 4): the notice is `SealToast` ("A seal turns in Crosspath", the Path's icon, one line, "2 of
## 4"), shown for about six seconds or until it is clicked, and the hero moves again as soon as the lever is down - it was a cutaway card
## with four coloured discs that held the world for three seconds. Works in any ZoneScene (`player`, `hud`, `set_world_locked`,
## `shake_camera`, `_overlay_layer`).

## How long the pull itself holds the hero (the lever going down and the grind).
const PULL_SECONDS: float = 1.1


## The colour of zone `zone_id`'s seal.
static func seal_color(zone_id: String) -> Color:
	match zone_id:
		"beefcake":
			return UIStyle.affinity_color(Affinity.Type.BEEFCAKE)
		"gourmand":
			return UIStyle.affinity_color(Affinity.Type.GOURMAND)
		"refusemancer":
			return UIStyle.affinity_color(Affinity.Type.REFUSEMANCER)
		"necrocrat":
			return UIStyle.affinity_color(Affinity.Type.NECROCRAT)
	return UIStyle.GOLD


static func play(host: Node3D, zone_id: String, lever: Node3D) -> void:
	var player: TownPlayer = host.get("player") as TownPlayer
	var hud: TownHud = host.get("hud") as TownHud
	var tree: SceneTree = host.get_tree()
	if Session.vault_lever_pulled(zone_id):
		hud.toast("The lever is stuck fast. It has already done its work.", UIStyle.MUTED)
		return
	host.call("set_world_locked", true)
	player.input_enabled = false
	player.face(lever.global_position)
	var result: Dictionary = Session.pull_vault_lever(zone_id)
	Audio.sfx(&"lever_clunk")
	LeverKit.pull_animated(lever)
	host.call("shake_camera", 0.7, 0.35)
	await tree.create_timer(0.55).timeout
	Audio.sfx(&"vault_grind", -2.0, 0.02)
	host.call("shake_camera", 1.0, 1.2)
	await tree.create_timer(PULL_SECONDS - 0.55).timeout
	SealToast.show_on(host.get("_overlay_layer") as Control, zone_id, int(result.get("count", Session.vault_levers_pulled())))
	Session.save_game()
	host.call("set_world_locked", false)
	player.input_enabled = true


## Screenshot/dev helper (`--lever=1`): pulls this zone's lever once the scene has settled.
static func screenshot_run(host: Node3D, zone_id: String, lever: Node3D) -> void:
	await host.get_tree().create_timer(1.0).timeout
	play(host, zone_id, lever)
