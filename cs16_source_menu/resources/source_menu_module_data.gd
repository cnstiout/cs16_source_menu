@tool
class_name SourceMenuModuleData
extends Resource

@export var video_resolutions: Array[String] = ["1024x768", "1280x720", "1600x900", "1920x1080"]
@export var video_display_modes: Array[String] = ["Windowed", "Borderless", "Fullscreen"]
@export var game_difficulties: Array[String] = ["Easy", "Normal", "Hard"]
@export var game_languages: Array[String] = ["English", "French"]
@export var language_to_locale: Dictionary = {
	"English": "en",
	"French": "fr",
}

@export var input_action_bindings: Dictionary = {
	"move_forward": "play_char_move_forward_action",
	"move_backward": "play_char_move_backward_action",
	"move_left": "play_char_move_left_ation",
	"move_right": "play_char_move_right_action",
	"jump": "play_char_jump_action",
	"run": "play_char_run_action",
	"crouch": "play_char_crouch_action",
}

@export var input_key_aliases: Dictionary = {
	"ESC": "Escape",
	"ESCAPE": "Escape",
	"SPACE": "Space",
	"SHIFT": "Shift",
	"L_SHIFT": "Shift",
	"R_SHIFT": "Shift",
	"CTRL": "Ctrl",
	"CONTROL": "Ctrl",
	"L_CTRL": "Ctrl",
	"R_CTRL": "Ctrl",
	"ALT": "Alt",
	"L_ALT": "Alt",
	"R_ALT": "Alt",
	"ENTER": "Enter",
	"RETURN": "Enter",
	"TAB": "Tab",
	"BACKSPACE": "Backspace",
	"UP": "Up",
	"DOWN": "Down",
	"LEFT": "Left",
	"RIGHT": "Right",
}

@export var controls_defaults: Dictionary = {
	"mouse_sensitivity": 2.5,
	"invert_mouse": false,
	"hold_to_crouch": true,
	"hold_to_sprint": true,
}

@export var input_defaults: Dictionary = {
	"move_forward": "W",
	"move_backward": "S",
	"move_left": "A",
	"move_right": "D",
	"jump": "SPACE",
	"run": "SHIFT",
	"crouch": "C",
}

@export var audio_defaults: Dictionary = {
	"master_volume": 90.0,
	"music_volume": 70.0,
	"sfx_volume": 85.0,
	"voice_volume": 80.0,
}

@export var video_defaults: Dictionary = {
	"resolution": "1280x720",
	"display_mode": "Fullscreen",
	"gamma": 1.0,
	"vsync": true,
}

@export var game_defaults: Dictionary = {
	"difficulty": "Normal",
	"language": "English",
	"subtitles": true,
	"show_tutorials": true,
}
