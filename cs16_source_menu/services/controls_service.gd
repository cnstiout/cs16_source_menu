extends Node

signal settings_changed(settings: Dictionary)

@export var module_data: SourceMenuModuleData

var _defaults: Dictionary = {}
var _settings: Dictionary = {}


func _ready() -> void:
	_ensure_module_data()
	var base_data := SourceMenuModuleData.new()
	_defaults = base_data.controls_defaults.duplicate(true)
	_defaults.merge(module_data.controls_defaults, true)
	_settings = _defaults.duplicate(true)
	_connect_tree_signals()
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
	_settings["mouse_sensitivity"] = clampf(float(_settings.get("mouse_sensitivity", _defaults["mouse_sensitivity"])), 0.1, 10.0)
	_settings["invert_mouse"] = bool(_settings.get("invert_mouse", _defaults["invert_mouse"]))
	_settings["hold_to_crouch"] = bool(_settings.get("hold_to_crouch", _defaults["hold_to_crouch"]))
	_settings["hold_to_sprint"] = bool(_settings.get("hold_to_sprint", _defaults["hold_to_sprint"]))


func _connect_tree_signals() -> void:
	var tree := get_tree()
	if tree == null:
		return

	var callback := Callable(self, "_on_tree_node_added")
	if not tree.is_connected("node_added", callback):
		tree.connect("node_added", callback)


func _on_tree_node_added(node: Node) -> void:
	# Apply settings when player/camera nodes spawn dynamically later.
	_apply_to_node(node)


func _apply_runtime_settings() -> void:
	Engine.set_meta(&"cs16_controls_settings", _settings.duplicate(true))

	var tree := get_tree()
	if tree == null:
		return

	var root := tree.current_scene
	if root == null:
		return

	_apply_to_subtree(root)


func _apply_to_subtree(root: Node) -> void:
	_apply_to_node(root)
	for child in root.get_children():
		if child is Node:
			_apply_to_subtree(child)


func _apply_to_node(node: Node) -> void:
	var sensitivity_value: float = float(_settings.get("mouse_sensitivity", _defaults["mouse_sensitivity"]))
	var invert_mouse: bool = bool(_settings.get("invert_mouse", _defaults["invert_mouse"]))
	var hold_to_crouch: bool = bool(_settings.get("hold_to_crouch", _defaults["hold_to_crouch"]))
	var hold_to_sprint: bool = bool(_settings.get("hold_to_sprint", _defaults["hold_to_sprint"]))

	var camera_axis_sensitivity: float = clampf(sensitivity_value / 50.0, 0.001, 0.5)
	var camera_y_sensitivity: float = camera_axis_sensitivity * (-1.0 if invert_mouse else 1.0)

	if _has_property(node, &"x_axis_sensibility"):
		node.set("x_axis_sensibility", camera_axis_sensitivity)

	if _has_property(node, &"y_axis_sensibility"):
		node.set("y_axis_sensibility", camera_y_sensitivity)

	if _has_property(node, &"continious_crouch"):
		node.set("continious_crouch", not hold_to_crouch)

	if _has_property(node, &"continious_run"):
		node.set("continious_run", not hold_to_sprint)


func _has_property(node: Object, property_name: StringName) -> bool:
	for property_info in node.get_property_list():
		if StringName(property_info.name) == property_name:
			return true
	return false


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
