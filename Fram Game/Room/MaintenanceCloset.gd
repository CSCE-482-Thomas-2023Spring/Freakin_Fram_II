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

func robot_interact():
	print("Robot interacted")
	$Player.disable()
	yield(create_box(source_path + "Interact-TaskStart.json"), "completed")
	$Player.enable()
	
func power_box_interact():
	print("Power box interacted")
	$Player.disable()
	yield(create_box(source_path + "Interact-Blocked.json"), "completed")
	
	$Player.enable()
