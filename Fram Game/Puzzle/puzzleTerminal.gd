extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var python_dir = "./python_files/python.exe"
var code_path = "user://testCode.py"
var user_code_path = "user://code.py"
var user_code_path_g = ProjectSettings.globalize_path(user_code_path)
var code_path_g = ProjectSettings.globalize_path(code_path)
var test_puzzle_path = ProjectSettings.globalize_path("res://Puzzle/TestCases/testPuzzle1.json")
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$Editor/VBoxContainer/Output/Button.connect("pressed", self, "on_button_pressed")
	var file = File.new()
	file.open("res://PythonScripts/testCode.py", File.READ)
	var testCode = file.get_as_text()
	file.close()
	
	var userTestCode = File.new()
	userTestCode.open(code_path, File.WRITE)
	userTestCode.store_string(testCode)
	userTestCode.close()

func on_button_pressed():
	$Editor/VBoxContainer/Input.executeUserCode()
	var stdout = []
	var exit_code = OS.execute(python_dir, [code_path_g, test_puzzle_path, python_dir, user_code_path_g], true, stdout, true)
	var file = File.new()
	file.open("res://results.json", File.READ)
	var results = file.get_as_text()
	file.close()
	
	print(results)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
