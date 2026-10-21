class_name GpuInfo
extends RefCounted
## Overnight Oct 20 (playtest stability): what kind of GPU the game runs on. The engine's adapter type cannot be trusted on D3D12:
## Godot 4.7's D3D12 driver reports integrated GPUs (AMD Radeon Graphics, Intel Iris Xe / Arc 130V) as DISCRETE (checked on the dev
## PC: D3D12 says 2 = discrete, Vulkan says 1 = integrated for the same AMD iGPU), so every iGPU started on High. The name decides here.

enum Kind { UNKNOWN, CPU, INTEGRATED_LOW, INTEGRATED, DISCRETE }

const KIND_NAMES: Array[String] = ["unknown", "software (CPU)", "integrated (older)", "integrated", "discrete"]


## The GPU kind from its name, vendor and the engine's type (the engine's word only where the name says nothing).
static func classify(adapter_name: String, vendor: String, engine_type: int) -> Kind:
	var name_text: String = adapter_name.to_lower()
	var vendor_text: String = vendor.to_lower()
	if engine_type == RenderingDevice.DEVICE_TYPE_CPU or name_text.contains("microsoft basic render") or name_text.contains("llvmpipe") or name_text.contains("swiftshader") or name_text.contains("warp"):
		return Kind.CPU
	if vendor_text.contains("intel") or name_text.contains("intel"):
		# Discrete Arc cards: A310..A770 (Alchemist), B570/B580 (Battlemage). Arc 130V/140V/140T and "Arc Graphics" are integrated.
		var discrete_arc: RegEx = RegEx.create_from_string("arc\\(tm\\) [ab][0-9]{3}|arc [ab][0-9]{3}|arc pro [ab][0-9]")
		if discrete_arc.search(name_text) != null:
			return Kind.DISCRETE
		if name_text.contains("uhd") or name_text.contains("hd graphics") or name_text.contains("iris(r) plus") or name_text.contains("iris plus"):
			return Kind.INTEGRATED_LOW
		return Kind.INTEGRATED
	if vendor_text.contains("amd") or vendor_text.contains("ati") or name_text.contains("radeon"):
		# "AMD Radeon(TM) Graphics", "Radeon Vega 8", "Radeon 780M" are APUs; "Radeon RX 6600", "Radeon Pro W..." are cards.
		if name_text.contains(" rx ") or name_text.contains("rx ") or name_text.contains("radeon pro") or name_text.contains("radeon vii") or name_text.contains("fury"):
			return Kind.DISCRETE
		var apu_model: RegEx = RegEx.create_from_string("radeon\\(tm\\) [0-9]{3}m|radeon [0-9]{3}m|vega")
		if name_text.contains("radeon(tm) graphics") or name_text.contains("radeon graphics") or apu_model.search(name_text) != null:
			return Kind.INTEGRATED
		return Kind.DISCRETE if engine_type == RenderingDevice.DEVICE_TYPE_DISCRETE_GPU else Kind.INTEGRATED
	if vendor_text.contains("nvidia") or name_text.contains("geforce") or name_text.contains("quadro") or name_text.contains("rtx"):
		return Kind.DISCRETE
	if vendor_text.contains("qualcomm") or name_text.contains("adreno") or vendor_text.contains("apple") or name_text.contains("mali"):
		return Kind.INTEGRATED
	match engine_type:
		RenderingDevice.DEVICE_TYPE_DISCRETE_GPU:
			return Kind.DISCRETE
		RenderingDevice.DEVICE_TYPE_INTEGRATED_GPU:
			return Kind.INTEGRATED
	return Kind.UNKNOWN


static func current_kind() -> Kind:
	return classify(RenderingServer.get_video_adapter_name(), RenderingServer.get_video_adapter_vendor(), RenderingServer.get_video_adapter_type())


static func is_integrated(kind: Kind) -> bool:
	return kind == Kind.INTEGRATED or kind == Kind.INTEGRATED_LOW


## The default graphics level for a GPU kind: only a discrete GPU starts on High; older Intel iGPUs and software renderers on Low.
static func recommended_level(kind: Kind) -> int:
	match kind:
		Kind.DISCRETE:
			return GraphicsQuality.Level.HIGH
		Kind.CPU, Kind.INTEGRATED_LOW:
			return GraphicsQuality.Level.LOW
	return GraphicsQuality.Level.MEDIUM


## The startup lines of the game log: renderer, driver, GPU and what the game made of it.
static func describe_lines() -> PackedStringArray:
	var lines: PackedStringArray = []
	var driver_info: PackedStringArray = OS.get_video_adapter_driver_info()
	lines.append("renderer: %s / %s, API %s" % [RenderingServer.get_current_rendering_driver_name(), RenderingServer.get_current_rendering_method(),
		RenderingServer.get_video_adapter_api_version()])
	lines.append("GPU: %s (vendor %s, engine type %d, read as %s)" % [RenderingServer.get_video_adapter_name(), RenderingServer.get_video_adapter_vendor(),
		RenderingServer.get_video_adapter_type(), KIND_NAMES[current_kind()]])
	lines.append("GPU driver: %s" % (" ".join(driver_info) if not driver_info.is_empty() else "unknown"))
	var device: RenderingDevice = RenderingServer.get_rendering_device()
	if device != null:
		lines.append("video memory in use at start: %d MB" % int(device.get_memory_usage(RenderingDevice.MEMORY_TOTAL) / 1048576))
	var screen: int = DisplayServer.window_get_current_screen()
	lines.append("screen: %s at %d Hz, window %s, scale %.2f" % [str(DisplayServer.screen_get_size(screen)), int(DisplayServer.screen_get_refresh_rate(screen)),
		str(DisplayServer.window_get_size()), DisplayServer.screen_get_scale(screen)])
	return lines
