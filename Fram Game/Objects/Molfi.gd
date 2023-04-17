#class_name NPC
extends Area2D

#-------------------MODIFIED FROM TASKINSTANCE--------------------#

# Task's global variables
# --------------------------
# Task path variable ("res://SourceFiles/Level" + [level #] + "/Task" + [task #] + "/")
export var dialogue_path: String = "Level2/Sove/"
# Current task status (0 = locked, 1 = unstarted, 2 = started, 3 = finished)
export var status: int = 0 setget set_status, get_status
# Custom overlap (false = automatically scales overlap area, true = keeps manual overlap changes)
export var custom_overlap: bool = true
# Hidden complete task (false = always interactive, true = task no longer interactive once complete)
export var hide_on_complete: bool = false
# Object collision status (true = task posesses collision, false = task can be moved through)
export var collision_enabled: bool = true
# Associated task's room path
export var room_path: String = "Laboratory";
# Associated task's room path
export var task_num: int = 1;

# Emit a signal when this task's status is updated
signal status_update

# Preloaded scene types
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")

# get associated task's node
onready var task_node = null
onready var navigation_node = null

func _on_navigation_ready():
	task_node = navigation_node.get_node("Task" + str(task_num))

# Set specific capabilities on task spawn
func _ready():
	
	
	#get_parent().connect("ready", self, "_on_child_ready") 		# for intance setup
	navigation_node = get_node("../")
	navigation_node.connect("ready", self, "_on_navigation_ready")
	
	# Scale interaction overlap areas to match size of collision area if applicable
	if (!custom_overlap):
		var pos = $StaticBody2D/CollisionShape.position
		var x_size = $StaticBody2D/CollisionShape.shape.extents.x
		var y_size = $StaticBody2D/CollisionShape.shape.extents.y
		$HorizontalOverlap.position = pos
		$HorizontalOverlap.shape.extents = Vector2(x_size + 10, y_size)
		$VerticalOverlap.position = pos
		$VerticalOverlap.shape.extents = Vector2(x_size, y_size + 10)
	
	# If collision is disabled, delete static body
	if (not collision_enabled):
		$StaticBody2D.queue_free()

# Setter function for task's completion status - called in task initialization
func set_status(new_status: int):
	status = new_status
	
	# If status is completed (3) and hide_on_complete is set, hide sprite and disable collision
	if (status == 3 and hide_on_complete):
		if (has_node("Sprite")):
			$Sprite.queue_free()
		# Only disable collision if not already disabled
		if (collision_enabled):
			if (has_node("StaticBody2D")):
				$StaticBody2D.queue_free()
		
		# Get player and dequeue this task from interactables -> TODO: given time, rework to avoid accessing parent
		if (get_parent().has_node("Player")):
			if (get_parent().get_node("Player").get("interactables")):
				get_parent().get_node("Player").interactables.erase(self)

# Setter function for task's completion status - called at task completion
func update_status(new_status: int = -1):
	# Set new status according to assoc. task, if no arg. provided
	if new_status == -1:
		new_status = task_node.get_status()  # replace with assoc. task
		set_status(new_status)
	# Else, set the assoc. task's status to whatever was given (should only be for 1 -> 2)
	else:
		task_node.set_status(new_status) # path to assoc. task
		set_status(new_status)
	# Emit signal for updated status
	emit_signal("status_update")

# Getter function for task's completion status
func get_status() -> int:
	return status

# Reusable dialogue-calling function
func dialogue(json_path):
	# Use default task template dialogue if this task is missing unique interaction dialogue
	var this_path = dialogue_path + json_path
	print("PATH: ", this_path)
	var f = File.new()
	if (not f.file_exists("res://SourceFiles/" + this_path)):
		this_path = "DefaultMessages/TaskTemplate/" + json_path
	print("PATH: ", this_path)
	
	# Call dialogue box
	var root = get_tree().get_root()
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(this_path)
	root.add_child(box)
	yield(box, "tree_exited")


# Add self to list of interactive objects if in range
func _on_NPC_body_entered(body):
	# Do not allow interaction if hiding on completion
	if (status == 3 and hide_on_complete):
		return
	if body is Player:
		body.interactables.append(self)

# Remove self from list of interactive objects if out of range
func _on_NPC_body_exited(body):
	if body is Player:
		body.interactables.erase(self)

# Call task dialogue & terminal on interact based on task status
func interact():
	update_status(-1)
	var player = get_node("../Player")
	player.disable()
	if (status == 0):
		# If task is locked, prevent access
		yield(dialogue("Interact-Blocked.json"), "completed")
	elif (status == 1):
		# If task is unstarted, start for the first time & update status to started
		update_status(1)	# Update the status of the task related to this NPC!
		yield(dialogue("Interact-TaskStart.json"), "completed")
	elif (status == 2):
		# If task is started, continue from before
		yield(dialogue("Interact-Return.json"), "completed")
		# Update task status if complete
	elif (status == 3):
		# If task is completed, prevent access
		yield(dialogue("Interact-Complete.json"), "completed")
	player.enable()
