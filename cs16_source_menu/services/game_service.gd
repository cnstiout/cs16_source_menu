extends Node

signal settings_changed(settings: Dictionary)

@export var module_data: SourceMenuModuleData

var _defaults: Dictionary = {}
var _settings: Dictionary = {}


func _ready() -> void:
	_ensure_module_data()
	var base_data := SourceMenuModuleData.new()
	_defaults = base_data.game_defaults.duplicate(true)
	_defaults.merge(module_data.game_defaults, true)
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
	var difficulty_value := str(_settings.get("difficulty", _defaults["difficulty"]))
	var difficulties: Array[String] = module_data.game_difficulties
	_settings["difficulty"] = difficulty_value if difficulty_value in difficulties else _defaults["difficulty"]

	var language_value := str(_settings.get("language", _defaults["language"]))
	var languages: Array[String] = module_data.game_languages
	_settings["language"] = language_value if language_value in languages else _defaults["language"]

	_settings["subtitles"] = bool(_settings.get("subtitles", _defaults["subtitles"]))
	_settings["show_tutorials"] = bool(_settings.get("show_tutorials", _defaults["show_tutorials"]))


func _apply_runtime_settings() -> void:
	var language_label := str(_settings.get("language", _defaults["language"]))
	var locale := str(module_data.language_to_locale.get(language_label, "en"))
	TranslationServer.set_locale(locale)

	# Expose latest values for gameplay systems that want lightweight global access.
	Engine.set_meta(&"cs16_game_settings", _settings.duplicate(true))


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
