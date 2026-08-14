class_name TestSquareRules
extends RefCounted

var passed: int = 0
var failed: int = 0
var test_names: Array[String] = []


## Asserts boolean condition is true.
func assert_true(condition: bool, test_name: String) -> void:
	self.test_names.append(test_name)
	if condition:
		self.passed += 1
		print("  [PASS] ", test_name)
	else:
		self.failed += 1
		print("  [FAIL] ", test_name)


## Asserts equality between two values.
func assert_eq(val1: Variant, val2: Variant, test_name: String) -> void:
	self.assert_true(val1 == val2, test_name + " (Expected: %s, Got: %s)" % [str(val2), str(val1)])


## Runs all square rule test cases.
func run_all_tests() -> Dictionary:
	print("--- Running Square Rules Tests ---")
	self.test_square_max_capacity_two_pieces()
	self.test_barrier_formation_and_blocking()
	self.test_secure_squares_cannot_eat()
	self.test_normal_square_eating_rule()
	return {"passed": self.passed, "failed": self.failed}


## Verifies that a square cannot accept a 3rd piece when 2 pieces are already inside.
func test_square_max_capacity_two_pieces() -> void:
	var sim = TestSimulator.new()
	var sq = sim.get_square(10) # Normal square 10
	
	var p0_0 = sim.get_piece(0, 0)
	var p0_1 = sim.get_piece(0, 1)
	var p1_0 = sim.get_piece(1, 0)
	
	# Place 2 pieces on square 10
	sq.set_piece_at_square_position(0, p0_0)
	sq.set_piece_at_square_position(1, p0_1)
	
	# Assert capacity is full (empty_position returns -1)
	self.assert_eq(sq.empty_position(), -1, "Square with 2 pieces has no empty slots")
	
	# Assert 3rd piece cannot enter square
	self.assert_true(sq.can_piece_enter(p1_0) == false, "3rd piece cannot enter a square with 2 pieces")


## Verifies that 2 pieces of the same color form a barrier blocking enemy entry.
func test_barrier_formation_and_blocking() -> void:
	var sim = TestSimulator.new()
	var sq = sim.get_square(12) # Square 12
	
	var p0_0 = sim.get_piece(0, 0)
	var p0_1 = sim.get_piece(0, 1)
	
	# Place 2 pieces of Player 0 on square 12
	sq.set_piece_at_square_position(0, p0_0)
	sq.set_piece_at_square_position(1, p0_1)
	
	# Assert square forms a barrier
	self.assert_true(sq.is_barrier(), "2 pieces of same player form a barrier")


## Verifies that on secure squares (SECURE type), different players coexist without eating.
func test_secure_squares_cannot_eat() -> void:
	var sim = TestSimulator.new()
	var secure_sq = sim.get_square(15) # Square 15 is SECURE
	
	var p0_0 = sim.get_piece(0, 0)
	var p1_0 = sim.get_piece(1, 0)
	
	# Place 1 Yellow piece on secure square 15
	secure_sq.set_piece_at_square_position(0, p0_0)
	
	# Assert Blue piece can enter secure square safely without eating Yellow
	self.assert_true(secure_sq.type == Globals.eSquareTypes.SECURE, "Square 15 is SECURE type")
	self.assert_true(secure_sq.can_piece_enter(p1_0) == true, "Enemy piece can enter secure square")


## Verifies that on normal squares, landing on an enemy piece triggers eating.
func test_normal_square_eating_rule() -> void:
	var sim = TestSimulator.new()
	var normal_sq = sim.get_square(10) # Square 10 is NORMAL
	
	var p0_0 = sim.get_piece(0, 0)
	
	# Place 1 Yellow piece on normal square 10
	normal_sq.set_piece_at_square_position(0, p0_0)
	
	# Assert square is NORMAL type
	self.assert_true(normal_sq.type == Globals.eSquareTypes.NORMAL, "Square 10 is NORMAL type")
