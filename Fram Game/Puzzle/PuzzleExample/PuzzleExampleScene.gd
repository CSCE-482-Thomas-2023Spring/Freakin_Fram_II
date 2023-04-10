extends Node2D

# Preload scene types before instancing them
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var terminal = preload("res://Puzzle/puzzleTerminal.tscn")
export(bool) var test_dialogue = false

# reusable function for loading a dialogue tree
func create_box(json_path):
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(json_path)
	add_child(box)
	yield(box, "tree_exited")

# reusable function for loading a Python task
func create_task(json_path):
	var task = terminal.instance()
	task._set_path(json_path)
	add_child(task)
	yield(task, "tree_exited")

# Call the two room-based dialogues, then open the terminal for task 1
func _ready():
	if (test_dialogue):
		# Call initial dialogue
		yield(create_box("Level0/Room-Introduction.json"), "completed")
		
		# Wait 2 seconds, then call the second dialogue
		yield(get_tree().create_timer(2), "timeout")
		yield(create_box("Level0/Task1/Interact-TaskStart.json"), "completed")
	
	# Call the terminal for this task
	yield(create_task("Level0/Task1/"), "completed")
		
	# Demonstration over; end game
	yield(get_tree().create_timer(2), "timeout")
	print("quitting")
	get_tree().quit()
