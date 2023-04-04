extends Node

# Enumerated room type based on all existing rooms in game
enum room_type {PodRoom, MaintenanceCloset, Laboratory, Navigation, Security, CrewQuarters, Communications, ReactorRoom, Bridge, CargoBay, HallwayWest, HallwayEast}

# Global variables: this room's type & respective source file path
export(room_type) var Level
var source_path = ""
var init_connections: bool = false

# Preload scene types before instancing them
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")

# Reusable dialogue-calling function
func dialogue(json_path):
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(json_path)
	add_child(box)
	yield(box, "tree_exited")

# Initialize values on level creation
func _ready():
	# Set level task values - TODO
	source_path = "Level" + str(Level)
	print("Room's source path: " + source_path)
	# Set current task values & initalize connections of all task & character children
	yield(task_update(), "completed")
	init_connections = true

# Whenever a task's status is updated, update each relevant child accordingly - TODO
func task_update():
	# Separate children by name - find "Task" and "Character" children
	var children = get_children()
	for child in children:
		var child_name = child.name
		if ((child_name.substr(0, 4) == "Task") or (child_name.substr(0, 9) == "Character")):
			# Update task or character's status value - TODO
			print("Relevant child found: " + child_name)
			# If child connections have not been initialized, initialize them - TODO
			if (not init_connections):
				pass
