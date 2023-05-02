extends GutTest

var helper = load("res://test/helper.gd").new()
var _puzzleTerminal = load("res://Puzzle/puzzleTerminal.tscn")
var results_file = "res://test/json/results.json"
var puzzleTerminal
var results_cases = JSON.parse(helper.get_file_as_text(results_file)).result.testResults

func before_each():
	puzzleTerminal = autofree(_puzzleTerminal.instance())

func test_process_test_results_function():
	var data = puzzleTerminal.process_test_results_function(results_cases)
	var successCountString = data[0]
	var failureString = data[1]
	assert_eq(successCountString, "2/3 test cases passed")
	assert_eq(failureString, "Suggestion: try testing your function with inputs 1, 2, 3.")

func test_process_test_results_stdout():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
