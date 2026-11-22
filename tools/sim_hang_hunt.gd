extends SceneTree
## Fable Nov 21 castle (Part 7): finds a balance-sim game that never ends (the gear sim hung on one variant). Plays the gear
## sim's games one by one and prints each before it starts, so the last line before a hang names it; --trace=<path>:<fight>:<i>
## prints every action of that one game (BalanceSim.trace).
##   Godot --headless --path . -s res://tools/sim_hang_hunt.gd -- --filter=D-PC:12,D-PC:19 --level=21 --games=6 --gear=wicked_dagger [--trace=0:D-PC:19:3]


func _initialize() -> void:
	process_frame.connect(_run, CONNECT_ONE_SHOT)


func _run() -> void:
	var body: GDScript = load("res://tools/sim_hang_hunt_body.gd") as GDScript
	(body.new() as RefCounted).call("run")
	quit(0)
