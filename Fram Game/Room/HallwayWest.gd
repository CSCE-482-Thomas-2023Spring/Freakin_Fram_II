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
	
func goto_hallway():
	get_tree().change_scene("res://Room/HallwayEast.tscn")

func goto_security():
	get_tree().change_scene("res://Room/Security.tscn")

func goto_bridge():
	get_tree().change_scene("res://Room/Bridge.tscn")

func goto_cargo():
	get_tree().change_scene("res://Room/CargoBay.tscn")