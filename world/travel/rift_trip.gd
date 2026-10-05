class_name RiftTrip
extends RefCounted
## The ripping sequence shared by the town and the zones (brief 10b): the operator shouts a rip line, the station tears open (sound,
## flare, a white flash over the screen), then `Session.fast_travel_to` takes the hero there. Text: `travel.rip.*` in the story file.


## A coroutine: `await RiftTrip.run(...)`. `station` may be null (no tearing animation, just the flash).
static func run(host: Node, overlay_layer: Control, dialogue: DialogueBox, station: FastTravelStation, operator_name: String, destination: String) -> void:
	var story: StoryText = StoryText.shared()
	var shout: int = randi_range(1, FastTravel.RIP_LINES)
	var lines: Array[String] = story.get_lines("travel.rip.%d" % shout)
	lines.append_array(story.get_lines("travel.rip.sound"))
	dialogue.start(operator_name, lines)
	await dialogue.finished
	Audio.sfx(&"attack")
	if station != null:
		station.rip_effect(1.4)
	await host.get_tree().create_timer(0.35).timeout
	Audio.sfx(&"hit_heavy")
	var flash: ColorRect = ColorRect.new()
	flash.color = Color(1.0, 1.0, 1.0, 0.0)
	flash.mouse_filter = Control.MOUSE_FILTER_STOP
	UIKit.full_rect(flash)
	overlay_layer.add_child(flash)
	var fade: Tween = flash.create_tween()
	fade.tween_property(flash, "color:a", 1.0, 0.8).set_ease(Tween.EASE_IN)
	await host.get_tree().create_timer(0.5).timeout
	Audio.sfx(&"spell")
	await host.get_tree().create_timer(0.7).timeout
	Session.fast_travel_to(destination)
