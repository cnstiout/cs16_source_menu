extends Node

signal new_game_pressed
signal options_opened
signal options_closed
signal credits_pressed
signal exit_pressed
signal menu_closed
signal settings_applied(settings: Dictionary)

@export var start_open: bool = true
@export var close_with_escape: bool = true
@export var pause_tree_while_open: bool = false
@export var block_input_behind_menu: bool = true

@onready var _boot: Node = $Boot
@onready var _services: Node = $Boot/Services
@onready var _app: Node = $App


func _ready() -> void:
	if _app == null:
		push_error("CS16 Source Menu: missing App node.")
		return

	_apply_runtime_config()
	_connect_app_signals()

	if start_open:
		open_menu()
	else:
		close_menu()


func open_menu() -> void:
	if _app != null and _app.has_method("open_menu"):
		_app.call("open_menu")


func close_menu() -> void:
	if _app != null and _app.has_method("close_menu"):
		_app.call("close_menu")


func toggle_menu() -> void:
	if _app != null and _app.has_method("toggle_menu"):
		_app.call("toggle_menu")


func open_options_tab(tab_name: String) -> void:
	if _app != null and _app.has_method("open_options_tab"):
		_app.call("open_options_tab", tab_name)


func get_settings() -> Dictionary:
	if _app != null and _app.has_method("get_settings"):
		return _app.call("get_settings")
	return {}


func set_settings(values: Dictionary) -> void:
	if _app != null and _app.has_method("set_settings"):
		_app.call("set_settings", values)


func _apply_runtime_config() -> void:
	if _app == null:
		return

	if _app.has_method("configure_services"):
		_app.call("configure_services", _services)

	_app.set("close_with_escape", close_with_escape)
	_app.set("pause_tree_while_open", pause_tree_while_open)
	_app.set("block_input_behind_menu", block_input_behind_menu)


func _connect_app_signals() -> void:
	if _app == null:
		return

	_bind_signal("new_game_pressed", Callable(self, "_on_app_new_game_pressed"))
	_bind_signal("options_opened", Callable(self, "_on_app_options_opened"))
	_bind_signal("options_closed", Callable(self, "_on_app_options_closed"))
	_bind_signal("credits_pressed", Callable(self, "_on_app_credits_pressed"))
	_bind_signal("exit_pressed", Callable(self, "_on_app_exit_pressed"))
	_bind_signal("menu_closed", Callable(self, "_on_app_menu_closed"))
	_bind_signal("settings_applied", Callable(self, "_on_app_settings_applied"))


func _bind_signal(signal_name: StringName, callback: Callable) -> void:
	if not _app.has_signal(signal_name):
		return
	if _app.is_connected(signal_name, callback):
		return
	_app.connect(signal_name, callback)


func _on_app_new_game_pressed() -> void:
	new_game_pressed.emit()


func _on_app_options_opened() -> void:
	options_opened.emit()


func _on_app_options_closed() -> void:
	options_closed.emit()


func _on_app_credits_pressed() -> void:
	credits_pressed.emit()


func _on_app_exit_pressed() -> void:
	exit_pressed.emit()


func _on_app_menu_closed() -> void:
	menu_closed.emit()


func _on_app_settings_applied(settings: Dictionary) -> void:
	settings_applied.emit(settings)
