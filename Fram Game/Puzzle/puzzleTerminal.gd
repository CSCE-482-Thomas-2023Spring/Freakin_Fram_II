extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"




	
func checkWork():
	var file = File.new()
	file.open("res://Puzzle/TestCases/test.json", file.READ)
	var jsonText = file.get_as_text()
	var testCases = JSON.parse(jsonText).result
	var cases = testCases["cases"][0]
	print(cases)
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	checkWork() # Replace with function body.
	$Editor/VBoxContainer/Input._on_Button_pressed()
	#TODO: somehow call _on_Button_pressed() with the parameters of input, and get the output

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
