extends Node

signal escape_pressed
signal settings_changed(settings: Dictionary)

@export var close_action: StringName = &"ui_cancel"
@export var module_data: SourceMenuModuleData

var _action_bindings: Dictionary = {}
var _defaults: Dictionary = {}
var _key_aliases: Dictionary = {}
var _settings: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_module_data()
	var base_data := SourceMenuModuleData.new()
	_action_bindings = base_data.input_action_bindings.duplicate(true)
	_action_bindings.merge(module_data.input_action_bindings, true)
	_defaults = base_data.input_defaults.duplicate(true)
	_defaults.merge(module_data.input_defaults, true)
	_key_aliases = base_data.input_key_aliases.duplicate(true)
	_key_aliases.merge(module_data.input_key_aliases, true)
	_refresh_defaults_from_input_map()
	_settings = _defaults.duplicate(true)
	_apply_bindings_to_input_map()


func _unhandled_input(event: InputEvent) -> void:
	var should_emit: bool = false

	if event is InputEventKey:
		var key_event := event as InputEventKey
		if key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
			should_emit = true

	if not should_emit and close_action != StringName() and event.is_action_pressed(close_action):
		should_emit = true

	if should_emit:
		escape_pressed.emit()


func get_settings() -> Dictionary:
	return _settings.duplicate(true)


func set_settings(values: Dictionary) -> void:
	for key in values.keys():
		if _defaults.has(key):
			_settings[key] = str(values[key]).strip_edges().to_upper()
	_sanitize()
	_apply_bindings_to_input_map()
	settings_changed.emit(_settings.duplicate(true))


func reset_defaults() -> void:
	_settings = _defaults.duplicate(true)
	_apply_bindings_to_input_map()
	settings_changed.emit(_settings.duplicate(true))


func _sanitize() -> void:
	for key in _defaults.keys():
		var text := str(_settings.get(key, _defaults[key])).strip_edges().to_upper()
		_settings[key] = text if text != "" else _defaults[key]


func _refresh_defaults_from_input_map() -> void:
	for setting_name in _defaults.keys():
		var action_name := _get_action_name(setting_name)
		if action_name == StringName():
			continue

		var event := _get_first_key_event(action_name)
		if event == null:
			continue

		var code := int(event.physical_keycode)
		if code == 0:
			code = int(event.keycode)
		if code == 0:
			continue

		var display_name := OS.get_keycode_string(code).strip_edges().to_upper()
		if display_name != "":
			_defaults[setting_name] = display_name


func _apply_bindings_to_input_map() -> void:
	for setting_name in _settings.keys():
		_apply_single_binding(setting_name, str(_settings[setting_name]))


func _apply_single_binding(setting_name: String, key_label: String) -> void:
	var action_name := _get_action_name(setting_name)
	if action_name == StringName():
		return

	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var existing_events := InputMap.action_get_events(action_name)
	for event in existing_events:
		if event is InputEventKey:
			InputMap.action_erase_event(action_name, event)

	var keycode := _parse_keycode(key_label)
	if keycode == 0:
		return

	var key_event := InputEventKey.new()
	key_event.keycode = keycode
	key_event.physical_keycode = keycode
	InputMap.action_add_event(action_name, key_event)


func _get_action_name(setting_name: String) -> StringName:
	if not _action_bindings.has(setting_name):
		return StringName()

	return StringName(_action_bindings[setting_name])


func _get_first_key_event(action_name: StringName) -> InputEventKey:
	if not InputMap.has_action(action_name):
		return null

	for event in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			return event as InputEventKey

	return null


func _parse_keycode(key_label: String) -> int:
	var normalized := key_label.strip_edges().to_upper()
	if normalized == "":
		return 0

	var query := normalized
	if _key_aliases.has(normalized):
		query = _key_aliases[normalized]
	elif normalized.length() == 1:
		query = normalized
	else:
		query = normalized.capitalize()

	return OS.find_keycode_from_string(query)


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
