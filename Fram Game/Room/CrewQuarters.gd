extends Node

# Preload scene types before instancing them
export var task_path: String = "DefaultMessages/TaskTemplate/"
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var terminal = preload("res://Puzzle/puzzleTerminal.tscn")

func dialogue(json_path):
	$Player.disable()
	
	var this_path = task_path + json_path
	var f = File.new()
	if (not f.file_exists("res://SourceFiles/" + this_path)):
		this_path = "DefaultMessages/TaskTemplate/" + json_path
	
	# Call dialgoue box
	var parent = get_parent()
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(this_path)
	parent.add_child(box)
	yield(box, "tree_exited")
	
	$Player.enable()

func check_bed():
	yield(dialogue("Interact-Blocked.json"), "completed")
