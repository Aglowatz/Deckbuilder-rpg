class_name StoryStillScreen
extends Control
## A story still: a full-screen illustration (`StoryStills`, STORY-* key art) fades in, its caption box at the bottom (the dialogue box) types out the captions one by one,
## a click, Space, Enter or E advances them, and after the last the picture fades out and `finished` fires. Captions: story keys `still.<name>`.
## `play` puts it above everything the current scene draws (its own canvas layer) and calls back when it is over.

signal finished

const FADE_IN: float = 0.9
const FADE_OUT: float = 0.8
const LAYER: int = 80

var still_id: String = ""
var captions: Array[String] = []
var dialogue: DialogueBox
var _picture: TextureRect
var _closing: bool = false


## A still screen, or null when the image is not in the game (the story just carries on without it).
static func make(id: String) -> StoryStillScreen:
	if not KeyArt.has(id):
		return null
	var screen: StoryStillScreen = StoryStillScreen.new()
	screen.still_id = id
	screen.captions = StoryStills.captions(id)
	screen.name = "StoryStill"
	return screen


## Shows still `id` over `host` and calls `then` when it has faded out (at once when there is no art).
static func play(host: Node, id: String, then: Callable = Callable()) -> StoryStillScreen:
	var screen: StoryStillScreen = StoryStillScreen.make(id)
	if screen == null:
		if then.is_valid():
			then.call()
		return null
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = LAYER
	layer.name = "StoryStillLayer"
	layer.process_mode = Node.PROCESS_MODE_ALWAYS
	host.add_child(layer)
	layer.add_child(screen)
	screen.finished.connect(func() -> void:
		layer.queue_free()
		if then.is_valid():
			then.call(), CONNECT_ONE_SHOT)
	return screen


func _ready() -> void:
	PadFocus.register(self)  # controller support (Oct 26): the pad focuses this screen's buttons
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var backdrop: ColorRect = ColorRect.new()
	backdrop.color = Color(0.02, 0.01, 0.04)
	UIKit.full_rect(backdrop)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	_picture = TextureRect.new()
	_picture.name = "StillArt"
	_picture.texture = KeyArt.texture(still_id)
	_picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	UIKit.full_rect(_picture)
	_picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_picture)
	# A soft dark fade under the caption box so the words read on any picture.
	var shade: TextureRect = TextureRect.new()
	var gradient: Gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color(0.02, 0.01, 0.04, 0.0), Color(0.02, 0.01, 0.04, 0.72)])
	var shade_texture: GradientTexture2D = GradientTexture2D.new()
	shade_texture.gradient = gradient
	shade_texture.width = 4
	shade_texture.height = 256
	shade_texture.fill_from = Vector2(0, 0)
	shade_texture.fill_to = Vector2(0, 1)
	shade.texture = shade_texture
	shade.stretch_mode = TextureRect.STRETCH_SCALE
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shade.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	shade.offset_top = -380
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)
	dialogue = DialogueBox.new()
	add_child(dialogue)
	dialogue.finished.connect(_close, CONNECT_ONE_SHOT)
	modulate.a = 0.0
	var appear: Tween = create_tween()
	appear.tween_property(self, "modulate:a", 1.0, FADE_IN)
	appear.tween_callback(func() -> void:
		if not captions.is_empty():
			dialogue.start("", captions))


## The screen stops the mouse (so nothing behind it is clicked), which also keeps clicks from the dialogue box's own input: pass them on.
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		if dialogue != null and dialogue.active:
			dialogue.press()


func _close() -> void:
	if _closing:
		return
	_closing = true
	var vanish: Tween = create_tween()
	vanish.tween_interval(0.25)
	vanish.tween_property(self, "modulate:a", 0.0, FADE_OUT)
	vanish.tween_callback(func() -> void:
		finished.emit())
