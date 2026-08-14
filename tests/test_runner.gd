extends Node

const TestSquareRulesScript = preload("res://tests/test_square_rules.gd")
const TestGameLogicScript = preload("res://tests/test_game_logic.gd")
const TestUIScript = preload("res://tests/test_ui.gd")
const TestCoverageScript = preload("res://tests/test_coverage.gd")


## Node test runner entry point executing all test suites in headless CLI mode.
func _ready():
	call_deferred("_run_suite")


func _run_suite():
	print("\n===========================================================")
	print("               GDPARCHIS AUTOMATED TEST SUITE              ")
	print("===========================================================\n")
	
	var total_passed: int = 0
	var total_failed: int = 0
	
	# 1. Run Square Rules Suite (Capacity limit 2, Barriers, Secure Squares)
	var square_tests = TestSquareRulesScript.new()
	var res_square = square_tests.run_all_tests()
	total_passed += res_square["passed"]
	total_failed += res_square["failed"]
	print("")
	
	# 2. Run Game Logic Suite (Bonus moves, roll 5 to exit, barrier evaluation)
	var logic_tests = TestGameLogicScript.new()
	var res_logic = logic_tests.run_all_tests()
	total_passed += res_logic["passed"]
	total_failed += res_logic["failed"]
	print("")
	
	# 3. Run UI & Persistence Suite (Scenes, Settings, Game History)
	var ui_tests = TestUIScript.new()
	var res_ui = ui_tests.run_all_tests()
	total_passed += res_ui["passed"]
	total_failed += res_ui["failed"]
	print("")
	
	# 4. Compute and print GDScript coverage report
	var coverage_engine = TestCoverageScript.new()
	var coverage_score = coverage_engine.compute_and_print_coverage()
	
	# 5. Print final test suite summary banner
	print("===========================================================")
	print("                    TEST SUITE SUMMARY                     ")
	print("===========================================================")
	print("  TOTAL PASSED   : %d" % total_passed)
	print("  TOTAL FAILED   : %d" % total_failed)
	print("  FINAL COVERAGE : %.1f%%" % coverage_score)
	print("===========================================================\n")
	
	# Exit with appropriate exit code
	if total_failed == 0:
		print("SUCCESS: All tests passed!")
		get_tree().quit(0)
	else:
		print("FAILURE: %d test(s) failed!" % total_failed)
		get_tree().quit(1)
