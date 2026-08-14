class_name TestUI
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
	self.test_match_history_persistence()
	self.test_settings_persistence()
	return {"passed": self.passed, "failed": self.failed}


## Verifies all UI scene files exist on filesystem.
func test_ui_scene_paths_exist() -> void:
	var scenes_to_check = [
		"res://scenes/Main.tscn",
		"res://scenes/PlayersSelection.tscn",
		"res://scenes/Options.tscn",
		"res://scenes/Controls.tscn",
		"res://scenes/GameHistory.tscn",
		"res://scenes/Game4.tscn",
		"res://scenes/GameDiceStart.tscn"
	]
	for sc_path in scenes_to_check:
		self.assert_true(ResourceLoader.exists(sc_path), "Scene exists: " + sc_path)


## Verifies match history adding, saving, loading, and clearing.
func test_match_history_persistence() -> void:
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
	
	# Cleanup
	Globals.clear_game_history()


## Verifies settings loading and difficulty mapping.
func test_settings_persistence() -> void:
	self.assert_true(Globals.settings != null, "Globals.settings initialized")
	self.assert_true(Globals.settings.has("difficulty"), "Settings dictionary contains difficulty key")
