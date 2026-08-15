extends RefCounted

var passed: int = 0
var failed: int = 0


## Asserts boolean condition is true.
func assert_true(condition: bool, test_name: String) -> void:
	if condition:
		self.passed += 1
		print("  [PASS] ", test_name)
	else:
		self.failed += 1
		print("  [FAIL] ", test_name)


## Asserts equality between two values.
func assert_eq(val1: Variant, val2: Variant, test_name: String) -> void:
	self.assert_true(val1 == val2, test_name + " (Expected: %s, Got: %s)" % [str(val2), str(val1)])


## Runs all UI and persistence test cases.
func run_all_tests() -> Dictionary:
	print("--- Running UI & Persistence Tests ---")
	self.test_ui_scene_paths_exist()
	self.test_font_resources_exist()
	self.test_match_history_persistence()
	self.test_settings_persistence()
	self.test_version_comparison()
	return {"passed": self.passed, "failed": self.failed}


## Verifies all UI scene files exist on filesystem.
func test_ui_scene_paths_exist() -> void:
	var scenes_to_check = [
		"res://scenes/Main.tscn",
		"res://scenes/PlayersSelection.tscn",
		"res://scenes/Options.tscn",
		"res://scenes/Controls.tscn",
		"res://scenes/GameHistory.tscn",
		"res://scenes/Credits.tscn",
		"res://scenes/Game4.tscn",
		"res://scenes/Game6.tscn",
		"res://scenes/GameDiceStart.tscn",
		"res://scenes/GameDiceStart6.tscn",
		"res://scenes/Board6Calibration.tscn"
	]
	for sc_path in scenes_to_check:
		self.assert_true(ResourceLoader.exists(sc_path), "Scene exists: " + sc_path)


## Verifies that font and theme resources exist and load cleanly.
func test_font_resources_exist() -> void:
	# List of font and theme resource paths to validate
	var font_paths = [
		"res://fonts/Freshman.ttf",
		"res://themes/Freshman.tres",
		"res://themes/FreshmanSmall.tres",
		"res://themes/FreshmanMiddle.tres"
	]
	# Iterate and assert each resource loads successfully
	for f_path in font_paths:
		self.assert_true(ResourceLoader.exists(f_path), "Font resource exists: " + f_path)
		var res = ResourceLoader.load(f_path)
		self.assert_true(res != null, "Font resource loaded: " + f_path)
	
	# Verify specific glyphs exist in Freshman.ttf
	var freshman_font: Font = load("res://fonts/Freshman.ttf") as Font
	if freshman_font:
		self.assert_true(freshman_font.has_char("ô".unicode_at(0)), "Font contains ô glyph (U+00F4)")
		self.assert_true(freshman_font.has_char("Ô".unicode_at(0)), "Font contains Ô glyph (U+00D4)")
		self.assert_true(freshman_font.has_char("ç".unicode_at(0)), "Font contains ç glyph (U+00E7)")
		self.assert_true(freshman_font.has_char("Ç".unicode_at(0)), "Font contains Ç glyph (U+00C7)")


## Verifies match history adding, saving, loading, and clearing.
func test_match_history_persistence() -> void:
	# Backup real user history before testing
	Globals.load_game_history()
	var real_history_backup = Globals.game_history.duplicate(true)
	
	Globals.clear_game_history()
	self.assert_eq(Globals.game_history.size(), 0, "Game history cleared to 0 entries")
	
	# Create mock history entry
	var mock_entry = {
		"datetime": "2026-08-14 09:30",
		"duration_sec": 420,
		"duration_str": "07:00",
		"max_players": 4,
		"winner_name": "TestPlayer",
		"winner_id": 0,
		"winner_ia": false,
		"composition": []
	}
	Globals.game_history.push_front(mock_entry)
	Globals.save_game_history()
	
	# Reload and verify
	Globals.load_game_history()
	self.assert_eq(Globals.game_history.size(), 1, "Game history saved and loaded 1 entry")
	self.assert_eq(Globals.game_history[0]["winner_name"], "TestPlayer", "Match history winner name restored correctly")
	
	# Restore real user history
	Globals.game_history = real_history_backup
	Globals.save_game_history()


## Verifies settings loading and difficulty mapping.
func test_settings_persistence() -> void:
	self.assert_true(Globals.settings != null, "Globals.settings initialized")
	self.assert_true(Globals.settings.has("difficulty"), "Settings dictionary contains difficulty key")
	
	# Test sound toggle helper
	var initial_sound = Globals.settings.get("sound", true)
	var toggled_sound = Globals.toggle_sound()
	self.assert_true(toggled_sound == not initial_sound, "Globals.toggle_sound toggled sound state")
	# Restore initial state
	Globals.toggle_sound()


## Verifies semver string comparison logic for update checking system.
func test_version_comparison() -> void:
	self.assert_true(Globals.is_newer_version("v1.0.0", "0.9.99"), "v1.0.0 is newer than 0.9.99")
	self.assert_true(Globals.is_newer_version("0.10.0", "0.9.99"), "0.10.0 is newer than 0.9.99")
	self.assert_true(Globals.is_newer_version("gdparchis-1.2.3", "0.9.99"), "gdparchis-1.2.3 is newer than 0.9.99")
	self.assert_true(not Globals.is_newer_version("0.9.99", "0.9.99"), "0.9.99 is not newer than 0.9.99")
	self.assert_true(not Globals.is_newer_version("v0.9.0", "0.9.99"), "v0.9.0 is not newer than 0.9.99")
