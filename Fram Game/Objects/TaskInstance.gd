extends Area2D

# Task's global variables
# --------------------------
# Task path variable ("res://SourceFiles/Level" + [level #] + "/Task" + [task #] + "/")
export var task_path: String = "DefaultMessages/TaskTemplate/"
# Current task status (0 = locked, 1 = unstarted, 2 = started, 3 = finished)
export var status: int = 0 setget set_status, get_status
# Custom overlap (false = automatically scales overlap area, true = keeps manual overlap changes)
export var custom_overlap: bool = false
# Hidden complete task (false = always interactive, true = task no longer interactive once complete)
export var hide_on_complete: bool = false
# Object collision status (true = task posesses collision, false = task can be moved through)
export var collision_enabled: bool = true

# Emit a signal when this task's status is updated
signal status_update

# Preloaded scene types
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var terminal = preload("res://Puzzle/puzzleTerminal.tscn")

# Setter function for task's completion status - called in task initialization
func set_status(new_status: int):
	status = new_status
	
	# If status is completed (3) and hide_on_complete is set, hide sprite and disable collision
	if (status == 3 and hide_on_complete):
		$Sprite.queue_free()
		# Only disable collision if not already disabled
		if (collision_enabled):
			$StaticBody2D.queue_free()
		
		# Get player and dequeue this task from interactables -> TODO: given time, rework to avoid accessing parent
		if (get_parent().has_node("Player")):
			if (get_parent().get_node("Player").get("interactables")):
				get_parent().get_node("Player").interactables.erase(self)

# Setter function for task's completion status - called at task completion
func update_status(new_status: int):
	# Set new status
	set_status(new_status)
	# Emit signal for updated status
	emit_signal("status_update")

# Getter function for task's completion status
func get_status() -> int:
	return status

# Reusable dialogue-calling function
func dialogue(json_path):
	# Use default task template dialogue if this task is missing unique interaction dialogue
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

# Reusable task-calling function
func launch_task(json_path):
	# Create task & set task variables
	var parent = get_parent()
	var task = terminal.instance()
	task._set_path(json_path)
	
	# Connect signal to task success
	task.connect("task_success", self, "update_status", [3])
	
	# Launch task and wait until task is exited
	parent.add_child(task)
	yield(task, "tree_exited")

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
	
	# If collision is disabled, delete static body
	if (not collision_enabled):
		$StaticBody2D.queue_free()

# Add self to list of interactive objects if in range
func _on_TaskArea_body_entered(body):
	# Do not allow interaction if hiding on completion
	if (status == 3 and hide_on_complete):
		return
	if body is Player:
		body.interactables.append(self)

# Remove self from list of interactive objects if out of range
func _on_TaskArea_body_exited(body):
	if body is Player:
		body.interactables.erase(self)

# Call task dialogue & terminal on interact based on task status
func interact():
	var player = get_node("../Player")
	player.disable()
	if (status == 0):
		# If task is locked, prevent access
		yield(dialogue("Interact-Blocked.json"), "completed")
	elif (status == 1):
		# If task is unstarted, start for the first time & update status to started
		update_status(2)
		yield(dialogue("Interact-TaskStart.json"), "completed")
		yield(launch_task(task_path), "completed")
	elif (status == 2):
		# If task is started, continue from before
		yield(dialogue("Interact-Return.json"), "completed")
		yield(launch_task(task_path), "completed")
		# Update task status if complete
	elif (status == 3):
		# If task is completed, prevent access
		yield(dialogue("Interact-Complete.json"), "completed")
	player.enable()
