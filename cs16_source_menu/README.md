# CS16 Source Menu Module

Runtime addon module for a Source/CS16 style menu.
It is not an EditorPlugin and is not enabled in `project.godot`.

## Architecture

The module is now fully node-based (no runtime UI generation):

- `SourceMenuModule` (`source_menu_module.gd`): orchestration + public API + relayed signals
- `Boot` (`nodes/boot.gd`)
- `Boot/Services` (`nodes/services.gd`)
- `Boot/Services/Input` (`services/input_service.gd`)
- `Boot/Services/Audio` (`services/audio_service.gd`)
- `Boot/Services/Video` (`services/video_service.gd`)
- `Boot/Services/Game` (`services/game_service.gd`)
- `Boot/Services/Controls` (`services/controls_service.gd`)
- `App` (`nodes/app.gd`): menu state + UI binding
- `resources/source_menu_module_data.gd`: data model (`Resource`)
- `resources/source_menu_module_data_default.tres`: module data preset
- `App/MenuLayer/UIRoot`: full static UI tree (Main / Options tabs / Credits)

## Features

- Main menu: `NEW GAME`, `OPTIONS`, `CREDITS`, `EXIT`
- Options tabs: `Controls`, `Inputs`, `Audio`, `Video`, `Game`
- Input tab defaults: `Move Forward`, `Move Backward`, `Move Left`, `Move Right`, `Jump`, `Run`, `Crouch`
- Theme: `res://ressources/themes/cs16_classic.theme`
- Runtime functionality:
  - `Input`: real `InputMap` rebinding (`play_char_*` actions), with key capture in UI
  - `Audio`: applies to bus volumes (`Master/Music/SFX/Voice` if present)
  - `Video`: applies window mode, resolution (windowed/borderless), VSync, and optional shader-global gamma (`cs16_gamma`)
  - `Controls`: applies camera sensitivity/invert and maps hold toggles to `PlayerCharacter.continious_*`
  - `Game`: applies locale via `TranslationServer` and exposes settings metadata
- Persistence:
  - Saved to `user://cs16_source_menu_settings.cfg`
  - Auto-load on startup, auto-save on apply
- Data-driven defaults:
  - Runtime data/options are loaded from `resources/source_menu_module_data_default.tres`
  - Logic stays in scripts, editable data stays in `.tres`
- Public methods:
  - `open_menu()`
  - `close_menu()`
  - `toggle_menu()`
  - `open_options_tab(name)`
  - `get_settings()`
  - `set_settings(values)`
- Signals:
  - `new_game_pressed`
  - `options_opened`
  - `options_closed`
  - `credits_pressed`
  - `exit_pressed`
  - `menu_closed`
  - `settings_applied(settings)`

## Usage

1. Instance `res://addons/cs16_source_menu/scenes/source_menu_module.tscn` in a scene.
2. Connect signals on `SourceMenuModule` to your game flow.
3. Configure exported vars on root:
   - `start_open`
   - `close_with_escape`
   - `pause_tree_while_open`
   - `block_input_behind_menu`
4. (Optional) Duplicate/edit `resources/source_menu_module_data_default.tres` to override module defaults/options without touching logic scripts.
