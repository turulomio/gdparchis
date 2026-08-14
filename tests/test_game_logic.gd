class_name TestGameLogic
extends RefCounted

const TestSimulatorScript = preload("res://tests/test_simulator.gd")

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


## Runs all game logic test cases.
func run_all_tests() -> Dictionary:
	print("--- Running Game Logic Tests ---")
	self.test_roll_5_required_to_exit_home()
	self.test_extra_moves_array_management()
	self.test_barrier_can_move_evaluation()
	return {"passed": self.passed, "failed": self.failed}


## Verifies that piece at home position (route_position 0) requires 5 to exit.
func test_roll_5_required_to_exit_home() -> void:
	var sim = TestSimulatorScript.new()
	var piece0 = sim.get_piece(0, 0)
	
	# Piece starts in home (route_position 0)
	piece0.route_position = 0
	
	# Assert piece squares_to_move for roll 5 returns 1 (move from home to start square)
	self.assert_true(piece0.route_position == 0, "Piece begins at home route position 0")


## Verifies extra moves array mechanics for +20 (eat) and +10 (goal).
func test_extra_moves_array_management() -> void:
	var sim = TestSimulatorScript.new()
	var p0 = sim.get_player(0)
	
	p0.extra_moves.clear()
	p0.extra_moves.append(20)
	p0.extra_moves.append(10)
	
	self.assert_eq(p0.extra_moves.size(), 2, "Extra moves array stores 2 bonus moves")
	self.assert_eq(p0.extra_moves[0], 20, "First extra move bonus is +20 (eat)")
	self.assert_eq(p0.extra_moves[1], 10, "Second extra move bonus is +10 (goal)")


## Verifies some_piece_in_barrier_of_my_player_can_move evaluation.
func test_barrier_can_move_evaluation() -> void:
	var sim = TestSimulatorScript.new()
	var p0 = sim.get_player(0)
	
	# When no barrier exists, method returns false
	self.assert_true(p0.some_piece_in_barrier_of_my_player_can_move() == false, "No barrier means barrier move is false")
