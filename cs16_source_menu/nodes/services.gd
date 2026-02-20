extends Node

signal settings_loaded(snapshot: Dictionary)
signal settings_saved(snapshot: Dictionary)
signal settings_applied(snapshot: Dictionary)

@export var config_path: String = "user://cs16_source_menu_settings.cfg"
@export var auto_load_on_ready: bool = true
@export var auto_save_on_apply: bool = true

@onready var input_service: Node = $Input
@onready var audio_service: Node = $Audio
@onready var video_service: Node = $Video
@onready var game_service: Node = $Game
@onready var controls_service: Node = $Controls


func get_service(name: String) -> Node:
	return get_node_or_null(name)


func _ready() -> void:
	if auto_load_on_ready:
		load_settings_from_disk()


func get_settings_snapshot() -> Dictionary:
	var snapshot: Dictionary = {}

	if controls_service != null and controls_service.has_method("get_settings"):
		snapshot["controls"] = controls_service.call("get_settings")

	if input_service != null and input_service.has_method("get_settings"):
		snapshot["inputs"] = input_service.call("get_settings")

	if audio_service != null and audio_service.has_method("get_settings"):
		snapshot["audio"] = audio_service.call("get_settings")

	if video_service != null and video_service.has_method("get_settings"):
		snapshot["video"] = video_service.call("get_settings")

	if game_service != null and game_service.has_method("get_settings"):
		snapshot["game"] = game_service.call("get_settings")

	return snapshot


func apply_settings_snapshot(snapshot: Dictionary, persist: bool = false) -> void:
	if controls_service != null and snapshot.has("controls") and controls_service.has_method("set_settings"):
		controls_service.call("set_settings", snapshot["controls"])

	if input_service != null and snapshot.has("inputs") and input_service.has_method("set_settings"):
		input_service.call("set_settings", snapshot["inputs"])

	if audio_service != null and snapshot.has("audio") and audio_service.has_method("set_settings"):
		audio_service.call("set_settings", snapshot["audio"])

	if video_service != null and snapshot.has("video") and video_service.has_method("set_settings"):
		video_service.call("set_settings", snapshot["video"])

	if game_service != null and snapshot.has("game") and game_service.has_method("set_settings"):
		game_service.call("set_settings", snapshot["game"])

	var current_snapshot := get_settings_snapshot()
	settings_applied.emit(current_snapshot)

	if persist:
		save_settings_to_disk()
	elif auto_save_on_apply:
		save_settings_to_disk()


func reset_defaults(persist: bool = false) -> void:
	for service in [controls_service, input_service, audio_service, video_service, game_service]:
		if service != null and service.has_method("reset_defaults"):
			service.call("reset_defaults")

	settings_applied.emit(get_settings_snapshot())

	if persist:
		save_settings_to_disk()


func load_settings_from_disk() -> bool:
	var config := ConfigFile.new()
	var load_result: int = config.load(config_path)
	if load_result != OK:
		return false

	var snapshot: Dictionary = {}
	for section in ["controls", "inputs", "audio", "video", "game"]:
		if not config.has_section(section):
			continue

		var section_values: Dictionary = {}
		for key in config.get_section_keys(section):
			section_values[key] = config.get_value(section, key)

		snapshot[section] = section_values

	apply_settings_snapshot(snapshot, false)
	settings_loaded.emit(get_settings_snapshot())
	return true


func save_settings_to_disk() -> bool:
	var snapshot := get_settings_snapshot()
	var config := ConfigFile.new()

	for section in snapshot.keys():
		if snapshot[section] is Dictionary:
			var section_values: Dictionary = snapshot[section]
			for key in section_values.keys():
				config.set_value(section, key, section_values[key])

	var save_result: int = config.save(config_path)
	if save_result == OK:
		settings_saved.emit(snapshot)
		return true

	push_warning("CS16 Source Menu: failed to save settings at '%s' (error %d)." % [config_path, save_result])
	return false
