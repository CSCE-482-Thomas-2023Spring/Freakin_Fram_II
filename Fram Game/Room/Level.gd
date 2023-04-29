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

# Setter for level's task statuses - called by Main on creation & story update
func set_status(new_statuses: Array):
	# Set new status values
	task_statuses = new_statuses
	# Update children's tasks
	task_update()
	
	print("Level Tasks:")
	var index = 0
	while(index < 8):
		print("Level " + str(index) + ": " + str(task_statuses[index]))
		index += 1

# Getter for level's task statuses - called by Main on level_update signal
func get_status() -> Array:
	return task_statuses

# Update individual task status - called on task interaction
func update_task_status(task_num: int, child_ref):
	# Set individual status value
	var new_status = child_ref.get_status()
	task_statuses[Level][task_num - 1] = new_status
	# Update Main's task list
	emit_signal("level_update")
	# Update children's tasks
	task_update()

# Open target task status - called on main character dialogue
func char_open_task(char_ref):
	# Update corresponding level task
	var open_level = char_ref.get_level()
	var open_task = char_ref.get_task() - 1
	task_statuses[open_level][open_task] = 1
	
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
	var root = get_tree().get_root()
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(json_path)
	root.add_child(box)
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
				child.connect("status_update", self, "update_task_status", [task_num, child])
		
		# If child is a character
		elif (child_name.substr(0, 4) == "Char"):
			
			# Unblock character if applicable
			if (child.get_status() == 0):
				var unblock_level = child.unblock_level
				var unblock_task = child.unblock_task - 1
				var unblock_status = child.unblock_status
				if (task_statuses[unblock_level][unblock_task] == unblock_status):
					child.set_status(1)
			
			# Set character as completed if applicable
			var completed_level = child.completed_level
			var completed_task = child.completed_task - 1
			var completed_status = child.completed_status
			if (task_statuses[completed_level][completed_task] == completed_status):
				child.set_status(3)
			
			# Initialize character's connections
			if (not init_connections):
				child.connect("open_task", self, "char_open_task", [child])
				
				# TODO: add connection to update character's interaction status if spoken to once
		
		# If child is a hideable object
		elif (child_name.substr(0, 8) == "Hideable"):
			# Check hidable object's condition
			child.check_condition(task_statuses)
	
	# Update connection initialization status on first run
	if (not init_connections):
		init_connections = true
