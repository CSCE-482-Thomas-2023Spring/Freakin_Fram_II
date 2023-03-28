extends Node

# Preload scene types before instancing them
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var terminal = preload("res://Puzzle/puzzleTerminal.tscn")
var source_path = "DefaultMessages/TaskTemplate/"

func create_box(json_path):
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(json_path)
	add_child(box)
	yield(box, "tree_exited")

func closet_door():
	print("Closet door")
	
	# Disable player movement
	$Player.disable()
	
	# Load initial dialogue
#	yield(create_box(source_path + "Interact-TaskStart.json"), "completed")
	yield(create_box("Level0/Task1/Interact-TaskStart.json"), "completed")
	
	# Load the closet_door puzzle
	var task1 = terminal.instance()
	task1._set_path("Level0/Task1/")
	add_child(task1)
	yield(task1, "tree_exited")
	
	# Delete the door after success
	$Door.queue_free()
	
	# Enable player movement
	$Player.enable()
	
func goto_closet():
	get_tree().change_scene("res://Room/closet.tscn")
	
func goto_hallway():
	get_tree().change_scene("res://Room/hallway_east.tscn")
