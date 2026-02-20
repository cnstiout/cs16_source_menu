extends Node

signal settings_changed(settings: Dictionary)

const GAMMA_SHADER_GLOBAL_SETTING_PATH: String = "shader_globals/cs16_gamma"

@export var apply_resolution: bool = true
@export var apply_display_mode: bool = true
@export var apply_vsync: bool = true
@export var apply_gamma_shader_global: bool = true
@export var module_data: SourceMenuModuleData

var _defaults: Dictionary = {}
var _settings: Dictionary = {}


func _ready() -> void:
	_ensure_module_data()
	var base_data := SourceMenuModuleData.new()
	_defaults = base_data.video_defaults.duplicate(true)
	_defaults.merge(module_data.video_defaults, true)
	_refresh_defaults_from_runtime()
	_settings = _defaults.duplicate(true)
	_apply_runtime_settings()


func get_settings() -> Dictionary:
	return _settings.duplicate(true)


func set_settings(values: Dictionary) -> void:
	for key in values.keys():
		if _defaults.has(key):
			_settings[key] = values[key]
	_sanitize()
	_apply_runtime_settings()
	settings_changed.emit(_settings.duplicate(true))


func reset_defaults() -> void:
	_settings = _defaults.duplicate(true)
	_apply_runtime_settings()
	settings_changed.emit(_settings.duplicate(true))


func _sanitize() -> void:
	var resolution_value := str(_settings.get("resolution", _defaults["resolution"]))
	var resolutions: Array[String] = module_data.video_resolutions
	_settings["resolution"] = resolution_value if resolution_value in resolutions else _defaults["resolution"]

	var mode_value := str(_settings.get("display_mode", _defaults["display_mode"]))
	var display_modes: Array[String] = module_data.video_display_modes
	_settings["display_mode"] = mode_value if mode_value in display_modes else _defaults["display_mode"]

	_settings["gamma"] = clampf(float(_settings.get("gamma", _defaults["gamma"])), 0.5, 2.5)
	_settings["vsync"] = bool(_settings.get("vsync", _defaults["vsync"]))


func _refresh_defaults_from_runtime() -> void:
	var window_size := DisplayServer.window_get_size()
	var resolution_label := "%dx%d" % [window_size.x, window_size.y]
	if resolution_label in module_data.video_resolutions:
		_defaults["resolution"] = resolution_label

	var mode := DisplayServer.window_get_mode()
	_defaults["display_mode"] = _label_from_window_mode(mode)

	var vsync_mode := DisplayServer.window_get_vsync_mode()
	_defaults["vsync"] = vsync_mode != DisplayServer.VSYNC_DISABLED


func _apply_runtime_settings() -> void:
	if apply_display_mode:
		_apply_display_mode_label(str(_settings.get("display_mode", _defaults["display_mode"])))

	if apply_resolution:
		_apply_resolution_label(str(_settings.get("resolution", _defaults["resolution"])))

	if apply_vsync:
		DisplayServer.window_set_vsync_mode(
			DisplayServer.VSYNC_ENABLED if bool(_settings.get("vsync", _defaults["vsync"])) else DisplayServer.VSYNC_DISABLED
		)

	if apply_gamma_shader_global:
		_apply_gamma_to_shader_global(float(_settings.get("gamma", _defaults["gamma"])))


func _label_from_window_mode(mode: int) -> String:
	match mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			return "Fullscreen"
		_:
			if DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS):
				return "Borderless"
			return "Windowed"


func _apply_display_mode_label(mode_label: String) -> void:
	match mode_label:
		"Windowed":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		"Borderless":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		"Fullscreen":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func _apply_resolution_label(resolution_label: String) -> void:
	var size := _parse_resolution(resolution_label)
	if size == Vector2i.ZERO:
		return

	# Resolution applies in windowed/borderless. Fullscreen uses current monitor mode.
	var mode_label := str(_settings.get("display_mode", _defaults["display_mode"]))
	if mode_label == "Fullscreen":
		return

	DisplayServer.window_set_size(size)


func _parse_resolution(text_value: String) -> Vector2i:
	var parts := text_value.strip_edges().split("x", false)
	if parts.size() != 2:
		return Vector2i.ZERO

	var width := int(parts[0])
	var height := int(parts[1])
	if width <= 0 or height <= 0:
		return Vector2i.ZERO

	return Vector2i(width, height)


func _apply_gamma_to_shader_global(gamma_value: float) -> void:
	if not ProjectSettings.has_setting(GAMMA_SHADER_GLOBAL_SETTING_PATH):
		return

	RenderingServer.global_shader_parameter_set(&"cs16_gamma", gamma_value)


func _ensure_module_data() -> void:
	if module_data != null:
		return

	var module_data_path: String = _get_module_data_path()
	if module_data_path != "":
		var loaded_data: SourceMenuModuleData = load(module_data_path) as SourceMenuModuleData
		if loaded_data != null:
			module_data = loaded_data

	if module_data == null:
		module_data = SourceMenuModuleData.new()


func _get_module_data_path() -> String:
	var script_ref: Script = get_script() as Script
	if script_ref == null:
		return ""

	var script_path: String = script_ref.resource_path
	if script_path == "":
		return ""

	var module_root: String = script_path.get_base_dir().get_base_dir()
	return module_root.path_join("resources/source_menu_module_data_default.tres")
