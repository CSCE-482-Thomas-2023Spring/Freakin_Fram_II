extends GutTest

var helper = load("res://test/helper.gd").new()
var _puzzleTerminal = load("res://Puzzle/puzzleTerminal.tscn")
var results_file = "res://test/files/examples/results.json"
var puzzleTerminal
var results_cases = JSON.parse(helper.get_file_as_text(results_file)).result.testResults

func before_each():
	puzzleTerminal = autofree(_puzzleTerminal.instance())

func test_process_test_results_function():
	pass

func test_process_test_results_stdout():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
