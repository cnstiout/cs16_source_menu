extends Node

signal settings_changed(settings: Dictionary)

@export var master_bus_name: StringName = &"Master"
@export var music_bus_name: StringName = &"Music"
@export var sfx_bus_name: StringName = &"SFX"
@export var voice_bus_name: StringName = &"Voice"
@export var module_data: SourceMenuModuleData

var _defaults: Dictionary = {}
var _settings: Dictionary = {}


func _ready() -> void:
	_ensure_module_data()
	var base_data := SourceMenuModuleData.new()
	_defaults = base_data.audio_defaults.duplicate(true)
	_defaults.merge(module_data.audio_defaults, true)
	_refresh_defaults_from_buses()
	_settings = _defaults.duplicate(true)
	_apply_to_audio_server()


func get_settings() -> Dictionary:
	return _settings.duplicate(true)


func set_settings(values: Dictionary) -> void:
	for key in values.keys():
		if _defaults.has(key):
			_settings[key] = float(values[key])
	_sanitize()
	_apply_to_audio_server()
	settings_changed.emit(_settings.duplicate(true))


func reset_defaults() -> void:
	_settings = _defaults.duplicate(true)
	_apply_to_audio_server()
	settings_changed.emit(_settings.duplicate(true))


func _sanitize() -> void:
	for key in _defaults.keys():
		_settings[key] = clampf(float(_settings.get(key, _defaults[key])), 0.0, 100.0)


func _refresh_defaults_from_buses() -> void:
	_defaults["master_volume"] = _read_bus_percent(master_bus_name, _defaults["master_volume"])
	_defaults["music_volume"] = _read_bus_percent(music_bus_name, _defaults["music_volume"])
	_defaults["sfx_volume"] = _read_bus_percent(sfx_bus_name, _defaults["sfx_volume"])
	_defaults["voice_volume"] = _read_bus_percent(voice_bus_name, _defaults["voice_volume"])


func _apply_to_audio_server() -> void:
	_write_bus_percent(master_bus_name, float(_settings.get("master_volume", _defaults["master_volume"])))
	_write_bus_percent(music_bus_name, float(_settings.get("music_volume", _defaults["music_volume"])))
	_write_bus_percent(sfx_bus_name, float(_settings.get("sfx_volume", _defaults["sfx_volume"])))
	_write_bus_percent(voice_bus_name, float(_settings.get("voice_volume", _defaults["voice_volume"])))


func _read_bus_percent(bus_name: StringName, fallback: float) -> float:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return fallback

	var db_value: float = AudioServer.get_bus_volume_db(bus_index)
	var linear_value: float = db_to_linear(db_value)
	return clampf(linear_value * 100.0, 0.0, 100.0)


func _write_bus_percent(bus_name: StringName, value_percent: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		return

	var linear_value: float = clampf(value_percent / 100.0, 0.0, 1.0)
	var db_value: float = -80.0 if linear_value <= 0.0001 else linear_to_db(linear_value)
	AudioServer.set_bus_volume_db(bus_index, db_value)


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
