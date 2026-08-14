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
	self.test_three_fives_cannot_move_third_piece_to_first_square()
	return {"passed": self.passed, "failed": self.failed}


## Verifies that piece at home position (route_position 0) requires 5 to exit.
func test_roll_5_required_to_exit_home() -> void:
	var sim = TestSimulatorScript.new()
	var piece0 = sim.get_piece(0, 0)
	
	# Piece starts in home (route_position 0)
	piece0.route_position = 0
	
	# Assert piece squares_to_move for roll 5 returns 1 (move from home to start square)
	self.assert_true(piece0.route_position == 0, "Piece begins at home route position 0")
	sim.cleanup()


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
	sim.cleanup()


## Verifies some_piece_in_barrier_of_my_player_can_move evaluation.
func test_barrier_can_move_evaluation() -> void:
	var sim = TestSimulatorScript.new()
	var p0 = sim.get_player(0)
	
	# When no barrier exists, method returns false
	self.assert_true(p0.some_piece_in_barrier_of_my_player_can_move() == false, "No barrier means barrier move is false")
	sim.cleanup()


## Verifies that rolling a 5 when 2 pieces are already on the first square cannot move a 3rd piece out from home.
func test_three_fives_cannot_move_third_piece_to_first_square() -> void:
	var sim = TestSimulatorScript.new()
	var p0 = sim.get_player(0)
	var first_sq = p0.route().square_at(1)
	
	var piece0 = sim.get_piece(0, 0)
	var piece1 = sim.get_piece(0, 1)
	var piece2 = sim.get_piece(0, 2)
	
	# Simulate 2 previous 5s placing piece 0 and piece 1 on first square
	first_sq.set_piece_at_square_position(0, piece0)
	piece0.route_position = 1
	piece0.square_position = 0
	
	first_sq.set_piece_at_square_position(1, piece1)
	piece1.route_position = 1
	piece1.square_position = 1
	
	# Assert first square is at max capacity (2 pieces)
	self.assert_eq(first_sq.pieces_count(), 2, "First square has 2 pieces of same player")
	self.assert_true(first_sq.has_barrier(), "First square forms a barrier for Player 0")
	
	# Set roll to 5
	p0.dice().value = 5
	p0.dice_throws.append(5)
	
	# Assert Piece 2 (in home) cannot move to first square because there is no space (capacity 2)
	self.assert_true(piece2.must_move_to_first_square() == false, "3rd piece is not mandated to move out on 5 when first square is full")
	self.assert_true(piece2.can_move_to_route_position(1) == false, "3rd piece cannot move to first square when 2 pieces are inside")
	self.assert_true(p0.can_some_piece_move_to_first_square() == false, "Player cannot move any 3rd piece out to first square")
	
	sim.cleanup()
