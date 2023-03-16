extends Node2D

# Preload scene types before instancing them
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var terminal = preload("res://Puzzle/puzzleTerminal.tscn")

func create_box(json_path):
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(json_path)
	add_child(box)
	yield(box, "tree_exited")

# Call the two room-based dialogues, then open the terminal for task 1
func _ready():
	# Call initial dialogue
	yield(create_box("Level0/Room-Introduction.json"), "completed")
	
	# Wait 2 seconds, then call the second dialogue
	yield(get_tree().create_timer(2), "timeout")
	yield(create_box("Level0/ClosetDoor-Interact.json"), "completed")
	
	# Call the terminal for this task - temporarily disabled until I figure out how tasks are being input
	var task1 = terminal.instance()
	task1._set_path("Level0/Task1/")
	add_child(task1)
	yield(task1, "tree_exited")
		
	# Demonstration over; end game
	yield(get_tree().create_timer(2), "timeout")
	print("quitting")
	get_tree().quit()
