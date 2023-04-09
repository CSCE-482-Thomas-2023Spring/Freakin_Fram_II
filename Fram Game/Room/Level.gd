extends Node

# Enumerated room type based on all existing rooms in game
enum room_type {PodRoom, MaintenanceCloset, Laboratory, Navigation, Security, CrewQuarters, Communications, ReactorRoom, Bridge, CargoBay, HallwayWest, HallwayEast}

# Level's global variables
# ----------------------------
# This room's room type
export(room_type) var Level
# This level's array of task statuses
var task_statuses = [] setget set_status, get_status
# Boolean indicating the initialization status of children's signal connections
var init_connections: bool = false

# Emit a signal when level's task status values have been updated
signal level_update

# Preload scene types before instancing them
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")

# Setter for level's task statuses - called by Main on creation
func set_status(new_statuses: Array):
	# Set new status values
	task_statuses = new_statuses
	# Update children's tasks
	task_update()

# Getter for level's task statuses - called by Main on level_update signal
func get_status() -> Array:
	return task_statuses

# Update individual task status - called on task interaction
func update_task_status(task_num: int, child_ref):
	# Set individual status value
	var new_status = child_ref.get_status()
	task_statuses[Level][task_num] = new_status
	# Update Main's task list
	emit_signal("level_update")
	# Update children's tasks
	task_update()

# Update at least one task status - called on character interaction - TODO: test!
func update_char_status(char_ref):
	# Update all status values
	var char_status = char_ref.get_status()
	task_statuses = char_status
	# Update Main's task list
	emit_signal("level_update")
	# Update children's tasks
	task_update()

# Initialize dummy statuses if tasks aren't initialized by main (aka run locally in editor) - not used in full game
func _ready():
	if (task_statuses == []):
		var index = 0
		while (index < 8):
			task_statuses.append([1,1,1,1,1,1,1,1,1,1])
			index += 1
		task_update()

# Reusable dialogue-calling function
func dialogue(json_path):
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(json_path)
	add_child(box)
	yield(box, "tree_exited")

# Whenever a task's status is updated, update each relevant child accordingly
func task_update():
	# Separate children into types by name - "Task" / "Character" / "Hideable"
	var children = get_children()
	for child in children:
		var child_name = child.name
		
		# If child is a task
		if (child_name.substr(0, 4) == "Task"):
			# Update task's status value
			var task_num = int(child_name.substr(4, 1))
			child.set_status(task_statuses[Level][task_num - 1])
			# Initialize task's connection
			if (not init_connections):
				child.connect("status_update", self, "update_task_status", [Level, child])
		
		# If child is a character
		elif (child_name.substr(0, 9) == "Character"):
			# Update character's status values - TODO: test & remove print (after testing)
			print("Found character " + child_name.substr(9, 1))
			child.set_status(task_statuses)
			# Initialize character's connction - TODO: test
			if (not init_connections):
				child.connect("status_update", self, "update_char_status", [child])
		
		# If child is a hideable object
		elif (child_name.substr(0, 8) == "Hideable"):
			# Check hidable object's condition
			child.check_condition(task_statuses)
	
	# Update connection initialization status on first run
	if (not init_connections):
		init_connections = true
