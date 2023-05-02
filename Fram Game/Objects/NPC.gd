#class_name NPC
extends Area2D

# Enumerated level type based on all existing rooms in game
enum level_type {PodRoom, MaintenanceCloset, Laboratory, Navigation, Security, CrewQuarters, Communications, ReactorRoom}

# Task's global variables | **Note: Include "Char" in the start of a character's name!**
# --------------------------
# Level/Task/Status needed to set this NPC to unblocked
export(level_type) var unblock_level
export var unblock_task: int = 1
export var unblock_status: int = 3
# Level/Task/Status needed to set this NPC to completed
export(level_type) var completed_level
export var completed_task: int = 1
export var completed_status: int = 3
# Level/Task to unblock if applicable
export var open_task_on_unblock: bool = false
export(level_type) var open_level
export var open_task: int = 1
# This NPC's current dialogue status (0 = blocked, 1 = initial, 2 = returning, 3 = completed)
var status: int = 0
# Custom overlap (false = automatically scales overlap area, true = keeps manual overlap changes)
export var custom_overlap: bool = true
# NPC dialogue path ("res://SourceFiles/Level" + [level #] + "/Task" + [task #] + "/")
export var dialogue_path: String = "Level2/Sove/"

# Emit a signal when this task's status is updated
signal open_task

# Preloaded scene types
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")

# Setter / Getter Functions
# ----------------------------

# Setter function for task's completion status - called in task initialization
func set_status(new_status: int):
	status = new_status

# Getter function for task's completion status
func get_status() -> int:
	return status

# Getter function for level to open the task of
func get_level() -> int:
	return open_level

# Getter function for task to open
func get_task() -> int:
	return open_task

# Main Functions
# -----------------

# Set specific capabilities on task spawn
func _ready():
	
	# Scale interaction overlap areas to match size of collision area if applicable
	if (!custom_overlap):
		var pos = $StaticBody2D/CollisionShape.position
		var x_size = $StaticBody2D/CollisionShape.shape.extents.x
		var y_size = $StaticBody2D/CollisionShape.shape.extents.y
		$HorizontalOverlap.position = pos
		$HorizontalOverlap.shape.extents = Vector2(x_size + 10, y_size)
		$VerticalOverlap.position = pos
		$VerticalOverlap.shape.extents = Vector2(x_size, y_size + 10)

# Reusable dialogue-calling function
func dialogue(json_path):
	
	# Use default task template dialogue if this task is missing unique interaction dialogue
	var this_path = dialogue_path + json_path
	var f = File.new()
	if (not f.file_exists("res://SourceFiles/" + this_path)):
		this_path = "DefaultMessages/TaskTemplate/" + json_path
	
	# Call dialogue box
	var root = get_tree().get_root()
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(this_path)
	root.add_child(box)
	yield(box, "tree_exited")

# Add self to list of interactive objects if in range
func _on_NPC_body_entered(body):
	if body is Player:
		body.interactables.append(self)

# Remove self from list of interactive objects if out of range
func _on_NPC_body_exited(body):
	if body is Player:
		body.interactables.erase(self)

# Call task dialogue & terminal on interact based on task status
func interact():
	
	# Disable player movement
	var player = get_node("../Player")
	player.disable()
	
	# If NPC is blocked, give corresponding dialogue
	if (status == 0):
		yield(dialogue("Interact-Blocked.json"), "completed")
	
	# If NPC has not been talked to since unblocking, give main dialogue
	elif (status == 1):
		yield(dialogue("Interact-TaskStart.json"), "completed")
		set_status(2)
		
		# If NPC unblocks a task, do so - TODO: connect signal & implement
		if (open_task_on_unblock):
			emit_signal("open_task")
	
	# If task is started, continue from before
	elif (status == 2):
		yield(dialogue("Interact-Return.json"), "completed")
	
	# If task is completed, prevent access
	elif (status == 3):
		yield(dialogue("Interact-Complete.json"), "completed")
	
	# Reenable player movement
	player.enable()
