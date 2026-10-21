class_name KeepAlive
extends RefCounted
## Phase 2 (stability): areas are still built in one long frame (a zone 4-8 s on the dev PC, longer on a laptop). Windows marks a window
## that has not handled its messages for 5 s "(Not Responding)", greys it out and offers to close it - to a tester that is a freeze.
## Build code calls `tick()` from its hot loops; once the current frame has run longer than LONG_FRAME_USEC it pumps the window's
## messages every PUMP_USEC with `DisplayServer.force_process_and_drop_events()` (about 20 us; input during such a frame is dropped,
## never dispatched mid-build). An ordinary frame never pumps, so gameplay input is untouched.

const LONG_FRAME_USEC: int = 500000
const PUMP_USEC: int = 250000

## Set by GameLog at the start of every frame.
static var frame_start_usec: int = 0
static var _last_pump_usec: int = 0
## How many times this session pumped (the game log notes it at each reveal).
static var pumps: int = 0
static var _pumped: bool = false


static func tick() -> void:
	var now: int = Time.get_ticks_usec()
	if frame_start_usec == 0 or now - frame_start_usec < LONG_FRAME_USEC or now - _last_pump_usec < PUMP_USEC:
		return
	_last_pump_usec = now
	pumps += 1
	_pumped = true
	DisplayServer.force_process_and_drop_events()


## Called at the start of the next frame: a key or button released during a pumped frame was dropped with the rest, so the action
## would stay held (the hero walking on with no key down after a load). Every held action is released; returns how many.
static func after_frame() -> int:
	if not _pumped:
		return 0
	_pumped = false
	var released: int = 0
	for action: StringName in InputMap.get_actions():
		if Input.is_action_pressed(action):
			Input.action_release(action)
			released += 1
	return released
