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
	
func goto_cryo():
	get_tree().change_scene("res://Room/cyro.tscn")

func goto_lab():
	get_tree().change_scene("res://Room/lab.tscn")

func goto_reactor():
	get_tree().change_scene("res://Room/reactor.tscn")

func goto_quarters():
	get_tree().change_scene("res://Room/quarters.tscn")
#
#func goto_cryo():
#	get_tree().change_scene("res://Room/cyro.tscn")
