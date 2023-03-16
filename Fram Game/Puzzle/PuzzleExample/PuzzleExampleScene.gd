extends Node2D

# Preload scene types before instancing them
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var terminal = preload("res://Puzzle/puzzleTerminal.tscn")

# Call the two room-based dialogues, then open the terminal for task 1
func _ready():
	# Call initial dialogue
#	var spawn_dialog = dialogueBox.instance()
#	spawn_dialog.get_node("DialogueBox")._set_path("Level0/Room-Introduction.json")
#	add_child(spawn_dialog)
#	while (is_instance_valid(spawn_dialog)):
#		yield(get_tree().create_timer(.2), "timeout")
	
	# After a moment, call the second dialogue
#	yield(get_tree().create_timer(2), "timeout")

	var interact_dialog = dialogueBox.instance()
	interact_dialog.get_node("DialogueBox")._set_path("Level0/ClosetDoor-Interact.json")
	add_child(interact_dialog)
	yield(interact_dialog, "tree_exited")
	
	# Call the terminal for this task - temporarily disabled until I figure out how tasks are being input
	var task1 = terminal.instance()
	task1._set_path("Level0/Task1/")
	add_child(task1)
	
	# Demonstration over; end game
	while (is_instance_valid(task1)):
		yield(get_tree().create_timer(.2), "timeout")
	yield(get_tree().create_timer(2), "timeout")
	get_tree().quit()
