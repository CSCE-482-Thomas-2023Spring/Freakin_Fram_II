tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("ECS", "res://addons/gs_ecs/ecs.gd")
	
	
func _exit_tree():
	remove_autoload_singleton("ECS")
