extends Node

signal new_game_pressed
signal options_opened
signal options_closed
signal credits_pressed
signal exit_pressed
signal menu_closed
signal settings_applied(settings: Dictionary)

enum MenuPage {
	MAIN,
	OPTIONS,
	CREDITS,
}

@export var module_data: SourceMenuModuleData

var close_with_escape: bool = true
var pause_tree_while_open: bool = false
var block_input_behind_menu: bool = true

var _services: Node
var _input_service: Node
var _menu_open: bool = false
var _menu_page: int = MenuPage.MAIN
var _paused_before_open: bool = false
var _mouse_mode_before_open: int = Input.MOUSE_MODE_VISIBLE
var _signals_wired: bool = false

@onready var _ui_root: Control = $MenuLayer/UIRoot
@onready var _main_menu: PanelContainer = $MenuLayer/UIRoot/Frame/Center/Stack/MainMenu
@onready var _options_menu: PanelContainer = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu
@onready var _credits_menu: PanelContainer = $MenuLayer/UIRoot/Frame/Center/Stack/CreditsMenu
@onready var _options_tabs: TabContainer = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs

@onready var _new_game_button: Button = $MenuLayer/UIRoot/Frame/Center/Stack/MainMenu/MainMargin/MainRow/MainRight/NewGameButton
@onready var _options_button: Button = $MenuLayer/UIRoot/Frame/Center/Stack/MainMenu/MainMargin/MainRow/MainRight/OptionsButton
@onready var _credits_button: Button = $MenuLayer/UIRoot/Frame/Center/Stack/MainMenu/MainMargin/MainRow/MainRight/CreditsButton
@onready var _exit_button: Button = $MenuLayer/UIRoot/Frame/Center/Stack/MainMenu/MainMargin/MainRow/MainRight/ExitButton

@onready var _options_back_button: Button = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsHeader/OptionsBackButton
@onready var _credits_back_button: Button = $MenuLayer/UIRoot/Frame/Center/Stack/CreditsMenu/CreditsMargin/CreditsLayout/CreditsHeader/CreditsBackButton
@onready var _reset_defaults_button: Button = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsFooter/ResetDefaultsButton
@onready var _apply_button: Button = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsFooter/ApplyButton

@onready var _controls_sensitivity_slider: HSlider = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Controls/ControlsSensitivityRow/ControlsSensitivitySlider
@onready var _controls_sensitivity_value: Label = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Controls/ControlsSensitivityRow/ControlsSensitivityValue
@onready var _controls_invert_mouse: CheckBox = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Controls/ControlsInvertMouseCheck
@onready var _controls_hold_crouch: CheckBox = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Controls/ControlsHoldCrouchCheck
@onready var _controls_hold_sprint: CheckBox = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Controls/ControlsHoldSprintCheck

@onready var _input_forward: LineEdit = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Inputs/InputForwardRow/InputForwardEdit
@onready var _input_backward: LineEdit = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Inputs/InputBackwardRow/InputBackwardEdit
@onready var _input_left: LineEdit = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Inputs/InputLeftRow/InputLeftEdit
@onready var _input_right: LineEdit = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Inputs/InputRightRow/InputRightEdit
@onready var _input_jump: LineEdit = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Inputs/InputJumpRow/InputJumpEdit
@onready var _input_run: LineEdit = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Inputs/InputUseRow/InputUseEdit
@onready var _input_crouch: LineEdit = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Inputs/InputReloadRow/InputReloadEdit

@onready var _audio_master_slider: HSlider = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Audio/AudioMasterRow/AudioMasterSlider
@onready var _audio_master_value: Label = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Audio/AudioMasterRow/AudioMasterValue
@onready var _audio_music_slider: HSlider = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Audio/AudioMusicRow/AudioMusicSlider
@onready var _audio_music_value: Label = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Audio/AudioMusicRow/AudioMusicValue
@onready var _audio_sfx_slider: HSlider = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Audio/AudioSfxRow/AudioSfxSlider
@onready var _audio_sfx_value: Label = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Audio/AudioSfxRow/AudioSfxValue
@onready var _audio_voice_slider: HSlider = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Audio/AudioVoiceRow/AudioVoiceSlider
@onready var _audio_voice_value: Label = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Audio/AudioVoiceRow/AudioVoiceValue

@onready var _video_resolution_option: OptionButton = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Video/VideoResolutionRow/VideoResolutionOption
@onready var _video_display_option: OptionButton = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Video/VideoDisplayRow/VideoDisplayOption
@onready var _video_gamma_slider: HSlider = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Video/VideoGammaRow/VideoGammaSlider
@onready var _video_gamma_value: Label = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Video/VideoGammaRow/VideoGammaValue
@onready var _video_vsync_check: CheckBox = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Video/VideoVsyncCheck

@onready var _game_difficulty_option: OptionButton = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Game/GameDifficultyRow/GameDifficultyOption
@onready var _game_language_option: OptionButton = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Game/GameLanguageRow/GameLanguageOption
@onready var _game_subtitles_check: CheckBox = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Game/GameSubtitlesCheck
@onready var _game_tutorials_check: CheckBox = $MenuLayer/UIRoot/Frame/Center/Stack/OptionsMenu/OptionsMargin/OptionsLayout/OptionsTabs/Game/GameTutorialsCheck


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_module_data()
	_setup_option_buttons()
	_wire_ui_signals()

	if _services == null:
		_services = get_node_or_null("../Boot/Services")
	_connect_input_service()

	_sync_ui_from_services()
	_set_ui_visible(false)
	_show_page(MenuPage.MAIN, false)


func configure_services(services_node: Node) -> void:
	_services = services_node
	_connect_input_service()
	_sync_ui_from_services()


func open_menu() -> void:
	if _menu_open:
		return

	_menu_open = true
	_set_ui_visible(true)
	_mouse_mode_before_open = Input.get_mouse_mode()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if pause_tree_while_open:
		_paused_before_open = get_tree().paused
		get_tree().paused = true

	_sync_ui_from_services()
	_show_page(MenuPage.MAIN, false)
	_new_game_button.call_deferred("grab_focus")


func close_menu() -> void:
	if not _menu_open:
		_set_ui_visible(false)
		return

	_menu_open = false
	_set_ui_visible(false)

	if pause_tree_while_open:
		get_tree().paused = _paused_before_open

	Input.set_mouse_mode(_mouse_mode_before_open)


func toggle_menu() -> void:
	if _menu_open:
		close_menu()
	else:
		open_menu()


func open_options_tab(tab_name: String) -> void:
	_show_page(MenuPage.OPTIONS)
	for index in range(_options_tabs.get_tab_count()):
		if _options_tabs.get_tab_title(index).to_lower() == tab_name.to_lower():
			_options_tabs.current_tab = index
			return


func get_settings() -> Dictionary:
	if _services != null and _services.has_method("get_settings_snapshot"):
		return _services.call("get_settings_snapshot")
	return _collect_ui_settings()


func set_settings(values: Dictionary) -> void:
	_apply_settings_snapshot(values)
	_sync_ui_from_services()


func _connect_input_service() -> void:
	var callable := Callable(self, "_on_escape_requested")
	if _input_service != null and _input_service.is_connected("escape_pressed", callable):
		_input_service.disconnect("escape_pressed", callable)

	_input_service = _get_service("Input")
	if _input_service != null and not _input_service.is_connected("escape_pressed", callable):
		_input_service.connect("escape_pressed", callable)


func _get_service(name: String) -> Node:
	if _services == null:
		return null

	if _services.has_method("get_service"):
		return _services.call("get_service", name)

	return _services.get_node_or_null(name)


func _wire_ui_signals() -> void:
	if _signals_wired:
		return
	_signals_wired = true

	_new_game_button.pressed.connect(_on_new_game_button_pressed)
	_options_button.pressed.connect(_on_options_button_pressed)
	_credits_button.pressed.connect(_on_credits_button_pressed)
	_exit_button.pressed.connect(_on_exit_button_pressed)

	_options_back_button.pressed.connect(func() -> void:
		_show_page(MenuPage.MAIN)
	)
	_credits_back_button.pressed.connect(func() -> void:
		_show_page(MenuPage.MAIN)
	)
	_reset_defaults_button.pressed.connect(_on_reset_defaults_pressed)
	_apply_button.pressed.connect(_on_apply_pressed)

	_controls_sensitivity_slider.value_changed.connect(func(value: float) -> void:
		_controls_sensitivity_value.text = _format_slider_value(value, "x")
	)

	_audio_master_slider.value_changed.connect(func(value: float) -> void:
		_audio_master_value.text = _format_slider_value(value, "%")
	)
	_audio_music_slider.value_changed.connect(func(value: float) -> void:
		_audio_music_value.text = _format_slider_value(value, "%")
	)
	_audio_sfx_slider.value_changed.connect(func(value: float) -> void:
		_audio_sfx_value.text = _format_slider_value(value, "%")
	)
	_audio_voice_slider.value_changed.connect(func(value: float) -> void:
		_audio_voice_value.text = _format_slider_value(value, "%")
	)
	_video_gamma_slider.value_changed.connect(func(value: float) -> void:
		_video_gamma_value.text = _format_slider_value(value, "x")
	)

	for edit in [_input_forward, _input_backward, _input_left, _input_right, _input_jump, _input_run, _input_crouch]:
		_connect_input_capture(edit)


func _setup_option_buttons() -> void:
	_populate_option_button(_video_resolution_option, module_data.video_resolutions)
	_populate_option_button(_video_display_option, module_data.video_display_modes)
	_populate_option_button(_game_difficulty_option, module_data.game_difficulties)
	_populate_option_button(_game_language_option, module_data.game_languages)


func _connect_input_capture(edit: LineEdit) -> void:
	edit.placeholder_text = "PRESS KEY"
	edit.focus_entered.connect(func() -> void:
		edit.select_all()
	)
	edit.focus_exited.connect(func() -> void:
		edit.text = edit.text.strip_edges().to_upper()
	)
	edit.gui_input.connect(func(event: InputEvent) -> void:
		if not (event is InputEventKey):
			return

		var key_event := event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return

		var key_name := _format_key_event_for_binding(key_event)
		if key_name == "":
			return

		edit.text = key_name
		edit.release_focus()
		get_viewport().set_input_as_handled()
	)


func _format_key_event_for_binding(key_event: InputEventKey) -> String:
	var code := int(key_event.physical_keycode)
	if code == 0:
		code = int(key_event.keycode)
	if code == 0:
		return ""
	return OS.get_keycode_string(code).strip_edges().to_upper()


func _populate_option_button(button: OptionButton, values: Array[String]) -> void:
	button.clear()
	for value in values:
		button.add_item(value)
	if button.item_count > 0:
		button.select(0)


func _sync_ui_from_services() -> void:
	var snapshot: Dictionary = {}
	if _services != null and _services.has_method("get_settings_snapshot"):
		snapshot = _services.call("get_settings_snapshot")

	var controls_defaults: Dictionary = module_data.controls_defaults
	var input_defaults: Dictionary = module_data.input_defaults
	var audio_defaults: Dictionary = module_data.audio_defaults
	var video_defaults: Dictionary = module_data.video_defaults
	var game_defaults: Dictionary = module_data.game_defaults

	var controls: Dictionary = _get_section(snapshot, "controls")
	var inputs: Dictionary = _get_section(snapshot, "inputs")
	var audio: Dictionary = _get_section(snapshot, "audio")
	var video: Dictionary = _get_section(snapshot, "video")
	var game: Dictionary = _get_section(snapshot, "game")

	var mouse_sensitivity_default: float = float(controls_defaults.get("mouse_sensitivity", 2.5))
	var mouse_sensitivity: float = clampf(float(controls.get("mouse_sensitivity", mouse_sensitivity_default)), 0.1, 10.0)
	_controls_sensitivity_slider.set_value_no_signal(mouse_sensitivity)
	_controls_sensitivity_value.text = _format_slider_value(mouse_sensitivity, "x")
	_controls_invert_mouse.button_pressed = bool(controls.get("invert_mouse", controls_defaults.get("invert_mouse", false)))
	_controls_hold_crouch.button_pressed = bool(controls.get("hold_to_crouch", controls_defaults.get("hold_to_crouch", true)))
	_controls_hold_sprint.button_pressed = bool(controls.get("hold_to_sprint", controls_defaults.get("hold_to_sprint", true)))

	_input_forward.text = str(inputs.get("move_forward", input_defaults.get("move_forward", "W")))
	_input_backward.text = str(inputs.get("move_backward", input_defaults.get("move_backward", "S")))
	_input_left.text = str(inputs.get("move_left", input_defaults.get("move_left", "A")))
	_input_right.text = str(inputs.get("move_right", input_defaults.get("move_right", "D")))
	_input_jump.text = str(inputs.get("jump", input_defaults.get("jump", "SPACE")))
	_input_run.text = str(inputs.get("run", input_defaults.get("run", "SHIFT")))
	_input_crouch.text = str(inputs.get("crouch", input_defaults.get("crouch", "C")))

	var master_volume: float = clampf(float(audio.get("master_volume", audio_defaults.get("master_volume", 90.0))), 0.0, 100.0)
	var music_volume: float = clampf(float(audio.get("music_volume", audio_defaults.get("music_volume", 70.0))), 0.0, 100.0)
	var sfx_volume: float = clampf(float(audio.get("sfx_volume", audio_defaults.get("sfx_volume", 85.0))), 0.0, 100.0)
	var voice_volume: float = clampf(float(audio.get("voice_volume", audio_defaults.get("voice_volume", 80.0))), 0.0, 100.0)

	_audio_master_slider.set_value_no_signal(master_volume)
	_audio_music_slider.set_value_no_signal(music_volume)
	_audio_sfx_slider.set_value_no_signal(sfx_volume)
	_audio_voice_slider.set_value_no_signal(voice_volume)
	_audio_master_value.text = _format_slider_value(master_volume, "%")
	_audio_music_value.text = _format_slider_value(music_volume, "%")
	_audio_sfx_value.text = _format_slider_value(sfx_volume, "%")
	_audio_voice_value.text = _format_slider_value(voice_volume, "%")

	_set_option_from_text(_video_resolution_option, str(video.get("resolution", video_defaults.get("resolution", "1280x720"))))
	_set_option_from_text(_video_display_option, str(video.get("display_mode", video_defaults.get("display_mode", "Fullscreen"))))
	var gamma_value: float = clampf(float(video.get("gamma", video_defaults.get("gamma", 1.0))), 0.5, 2.5)
	_video_gamma_slider.set_value_no_signal(gamma_value)
	_video_gamma_value.text = _format_slider_value(gamma_value, "x")
	_video_vsync_check.button_pressed = bool(video.get("vsync", video_defaults.get("vsync", true)))

	_set_option_from_text(_game_difficulty_option, str(game.get("difficulty", game_defaults.get("difficulty", "Normal"))))
	_set_option_from_text(_game_language_option, str(game.get("language", game_defaults.get("language", "English"))))
	_game_subtitles_check.button_pressed = bool(game.get("subtitles", game_defaults.get("subtitles", true)))
	_game_tutorials_check.button_pressed = bool(game.get("show_tutorials", game_defaults.get("show_tutorials", true)))


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


func _collect_ui_settings() -> Dictionary:
	return {
		"controls": {
			"mouse_sensitivity": _controls_sensitivity_slider.value,
			"invert_mouse": _controls_invert_mouse.button_pressed,
			"hold_to_crouch": _controls_hold_crouch.button_pressed,
			"hold_to_sprint": _controls_hold_sprint.button_pressed,
		},
		"inputs": {
			"move_forward": _input_forward.text.strip_edges().to_upper(),
			"move_backward": _input_backward.text.strip_edges().to_upper(),
			"move_left": _input_left.text.strip_edges().to_upper(),
			"move_right": _input_right.text.strip_edges().to_upper(),
			"jump": _input_jump.text.strip_edges().to_upper(),
			"run": _input_run.text.strip_edges().to_upper(),
			"crouch": _input_crouch.text.strip_edges().to_upper(),
		},
		"audio": {
			"master_volume": _audio_master_slider.value,
			"music_volume": _audio_music_slider.value,
			"sfx_volume": _audio_sfx_slider.value,
			"voice_volume": _audio_voice_slider.value,
		},
		"video": {
			"resolution": _option_text(_video_resolution_option),
			"display_mode": _option_text(_video_display_option),
			"gamma": _video_gamma_slider.value,
			"vsync": _video_vsync_check.button_pressed,
		},
		"game": {
			"difficulty": _option_text(_game_difficulty_option),
			"language": _option_text(_game_language_option),
			"subtitles": _game_subtitles_check.button_pressed,
			"show_tutorials": _game_tutorials_check.button_pressed,
		}
	}


func _apply_settings_snapshot(snapshot: Dictionary, persist: bool = false) -> void:
	if _services != null and _services.has_method("apply_settings_snapshot"):
		_services.call("apply_settings_snapshot", snapshot, persist)


func _get_section(snapshot: Dictionary, key: String) -> Dictionary:
	if snapshot.has(key) and snapshot[key] is Dictionary:
		return snapshot[key]
	return {}


func _option_text(button: OptionButton) -> String:
	if button.item_count == 0:
		return ""
	return button.get_item_text(button.selected)


func _set_option_from_text(button: OptionButton, text_value: String) -> void:
	for index in range(button.item_count):
		if button.get_item_text(index) == text_value:
			button.select(index)
			return

	if button.item_count > 0:
		button.select(0)


func _show_page(next_page: int, emit_events: bool = true) -> void:
	var previous_page: int = _menu_page
	_menu_page = next_page

	_main_menu.visible = next_page == MenuPage.MAIN
	_options_menu.visible = next_page == MenuPage.OPTIONS
	_credits_menu.visible = next_page == MenuPage.CREDITS

	if emit_events:
		if previous_page != MenuPage.OPTIONS and next_page == MenuPage.OPTIONS:
			options_opened.emit()
		elif previous_page == MenuPage.OPTIONS and next_page != MenuPage.OPTIONS:
			options_closed.emit()

	if not _menu_open:
		return

	match next_page:
		MenuPage.MAIN:
			_new_game_button.call_deferred("grab_focus")
		MenuPage.OPTIONS:
			_options_back_button.call_deferred("grab_focus")
		MenuPage.CREDITS:
			_credits_back_button.call_deferred("grab_focus")


func _set_ui_visible(visible: bool) -> void:
	_ui_root.visible = visible
	_ui_root.mouse_filter = Control.MOUSE_FILTER_STOP if visible and block_input_behind_menu else Control.MOUSE_FILTER_IGNORE


func _on_escape_requested() -> void:
	if not _menu_open:
		return

	if _menu_page == MenuPage.MAIN:
		if close_with_escape:
			close_menu()
			menu_closed.emit()
	else:
		_show_page(MenuPage.MAIN)

	get_viewport().set_input_as_handled()


func _on_new_game_button_pressed() -> void:
	new_game_pressed.emit()


func _on_options_button_pressed() -> void:
	_show_page(MenuPage.OPTIONS)


func _on_credits_button_pressed() -> void:
	credits_pressed.emit()
	_show_page(MenuPage.CREDITS)


func _on_exit_button_pressed() -> void:
	exit_pressed.emit()


func _on_reset_defaults_pressed() -> void:
	if _services != null and _services.has_method("reset_defaults"):
		_services.call("reset_defaults")
	_sync_ui_from_services()


func _on_apply_pressed() -> void:
	var snapshot := _collect_ui_settings()
	_apply_settings_snapshot(snapshot, true)
	_sync_ui_from_services()
	settings_applied.emit(snapshot)


func _format_slider_value(value: float, suffix: String) -> String:
	if absf(value - roundf(value)) <= 0.001:
		return "%d%s" % [int(roundf(value)), suffix]
	return "%.2f%s" % [value, suffix]
