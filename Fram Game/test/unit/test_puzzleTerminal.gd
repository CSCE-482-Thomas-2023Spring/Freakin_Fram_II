extends GutTest

var _puzzleTerminal = load("res://Puzzle/puzzleTerminal.tscn")
var puzzleTerminal

func before_each():
	puzzleTerminal = autofree(_puzzleTerminal.instance())

func test_process_test_results_function(cases):
	pass

func test_process_test_results_stdout(cases):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
