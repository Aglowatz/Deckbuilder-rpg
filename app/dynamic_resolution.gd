class_name DynamicResolution
extends Node
## Performance pass Oct 25, Part 5 (docs/perf/perf_state.md): a safety net for slower PCs. When the frame rate stays under the target for a moment
## and the GPU is the reason, the 3D render scale steps down a little (FSR 1 upscales it to the window as before); when the GPU has headroom again it
## steps back up to the quality level's own scale. Never above that scale, never below FLOOR_DROP under it (and never under MIN_SCALE).
## `Settings.dynamic_resolution`: Auto (Low and Medium, when the render scale is the level's own), Always (any level, any fixed scale), Off.
## A child of the Settings autoload; `WAYWARD_DRS_LOG=1` prints every step.

enum Mode { AUTO, ALWAYS, OFF }
const MODE_NAMES: Array[String] = ["Auto (Low and Medium)", "Always", "Off"]

const STEP: float = 0.04
const FLOOR_DROP: float = 0.14
const MIN_SCALE: float = 0.4
## Frame time over the budget by this factor, for DOWN_AFTER seconds, with the GPU busy for at least GPU_BUSY of the budget: one step down.
const SLOW: float = 1.15
const DOWN_AFTER: float = 0.75
const GPU_BUSY: float = 0.8
## GPU time under this share of the budget for UP_AFTER seconds: one step up.
const ROOMY: float = 0.68
const UP_AFTER: float = 2.0
## After a scene change or a settings change nothing is judged for this long (loads and shader warm-up spike).
const SETTLE: float = 2.5

var _scale: float = 0.0
var _base: float = 1.0
var _frame_ms: float = 0.0
var _gpu_ms: float = 0.0
var _slow_for: float = 0.0
var _roomy_for: float = 0.0
var _settle: float = SETTLE
var _scene: Node
var _measuring: bool = false
var _log: bool = OS.get_environment("WAYWARD_DRS_LOG") != ""


func _ready() -> void:
	name = "DynamicResolution"
	process_mode = Node.PROCESS_MODE_ALWAYS
	Settings.graphics_changed.connect(_reset)


## True when the safety net may change the scale for this level and these settings.
static func applies(mode: int, level: int, render_scale_pct: int, upscaling: int) -> bool:
	if mode == Mode.OFF:
		return false
	if mode == Mode.ALWAYS:
		return true
	return level <= GraphicsQuality.Level.MEDIUM and render_scale_pct == 0 and upscaling != GraphicsQuality.Upscaler.NATIVE


## The lowest scale it may reach from `base`.
static func floor_for(base: float) -> float:
	return maxf(MIN_SCALE, base - FLOOR_DROP)


## One decision (pure, for tests): returns the new scale given the smoothed frame and GPU times, the budget, and how long each condition has held.
## `slow_for` / `roomy_for` are the seconds the frame has been slow / the GPU roomy, already including this frame.
static func decide(scale: float, base: float, frame_ms: float, gpu_ms: float, budget_ms: float, slow_for: float, roomy_for: float) -> float:
	if slow_for >= DOWN_AFTER and frame_ms > budget_ms * SLOW and gpu_ms > budget_ms * GPU_BUSY:
		return maxf(floor_for(base), snappedf(scale - STEP, 0.01))
	if roomy_for >= UP_AFTER and gpu_ms < budget_ms * ROOMY and scale < base:
		return minf(base, snappedf(scale + STEP, 0.01))
	return scale


func _reset() -> void:
	_settle = SETTLE
	_slow_for = 0.0
	_roomy_for = 0.0
	_scale = 0.0


func current_scale() -> float:
	return _scale


func _budget_ms() -> float:
	var target: float = 60.0
	if Settings.max_fps >= 30 and Settings.max_fps < 60:
		target = float(Settings.max_fps)
	return 1000.0 / target


func _process(delta: float) -> void:
	var tree: SceneTree = get_tree()
	var viewport: Viewport = tree.root
	if tree.current_scene != _scene:
		_scene = tree.current_scene
		_reset()
	var level: int = Settings.graphics_quality
	if not applies(Settings.dynamic_resolution, level, Settings.render_scale_pct, Settings.upscaling_mode) or viewport.disable_3d \
			or viewport.get_camera_3d() == null or SceneManager.busy or not GraphicsQuality.forward_plus():
		if _scale > 0.0 and _scale < _base - 0.001:
			GraphicsQuality.apply_to_viewport(viewport, level)  # hand the window back its own scale
		_scale = 0.0
		return
	if not _measuring:
		RenderingServer.viewport_set_measure_render_time(viewport.get_viewport_rid(), true)
		_measuring = true
	if _scale <= 0.0:
		_base = GraphicsQuality.effective_render_scale(level)
		_scale = _base
		_frame_ms = delta * 1000.0
		_gpu_ms = 0.0
	if _settle > 0.0:
		_settle -= delta
		return
	var gpu: float = RenderingServer.viewport_get_measured_render_time_gpu(viewport.get_viewport_rid())
	_frame_ms = lerpf(_frame_ms, delta * 1000.0, 0.1)
	_gpu_ms = lerpf(_gpu_ms, gpu, 0.1)
	var budget: float = _budget_ms()
	_slow_for = _slow_for + delta if _frame_ms > budget * SLOW and _gpu_ms > budget * GPU_BUSY else 0.0
	_roomy_for = _roomy_for + delta if _gpu_ms < budget * ROOMY else 0.0
	var next: float = decide(_scale, _base, _frame_ms, _gpu_ms, budget, _slow_for, _roomy_for)
	if not is_equal_approx(next, _scale):
		if _log:
			print("dynamic_resolution: %.2f -> %.2f (frame %.1f ms, gpu %.1f ms, budget %.1f)" % [_scale, next, _frame_ms, _gpu_ms, budget])
		_scale = next
		_slow_for = 0.0
		_roomy_for = 0.0
		_settle = 0.5  # let the new scale show in the numbers before judging again
	if not is_equal_approx(viewport.scaling_3d_scale, _scale):
		viewport.scaling_3d_scale = _scale
		if viewport.scaling_3d_mode == Viewport.SCALING_3D_MODE_BILINEAR and _scale < 0.999:
			viewport.scaling_3d_mode = Viewport.SCALING_3D_MODE_FSR
