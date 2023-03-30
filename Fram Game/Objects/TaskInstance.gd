extends Area2D

export var task_path: String = "DefaultMessages/TaskTemplate/" setget set_path
export var status: int = 0 setget set_status
export var custom_overlap: bool = false
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var terminal = preload("res://Puzzle/puzzleTerminal.tscn")

# Setter function for task's path ("res://SourceFiles/Level" + [level #] + "/Task" + [task #] + "/")
func set_path(new_path):
	task_path = new_path

# Setter function for task's completion status (0 = locked, 1 = unstarted, 2 = started, 3 = finished)
func set_status(new_status):
	status = new_status

# Reusable dialogue-calling function
func dialogue(json_path):
	# Use default task template dialogue if this task is missing unique interaction dialogue
	var this_path = task_path + json_path
	var f = File.new()
	if (not f.file_exists(this_path)):
		this_path = "DefaultMessages/TaskTemplate/" + json_path
	
	# Call dialgoue box
	var parent = get_parent()
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(this_path)
	parent.add_child(box)
	yield(box, "tree_exited")

# Reusable task-calling function
func launch_task(json_path):
	var completed = false
	var parent = get_parent()
	var task = terminal.instance()
	task._set_path(json_path)
	task.connect("task_success", self, "task_complete")
	parent.add_child(task)
	yield(task, "tree_exited")

# When a task is completed, update status accordingly
func task_complete():
	status = 3;

# Scale interaction overlap areas to match size of collision area
func _ready():
	if (!custom_overlap):
		var pos = $StaticBody2D/CollisionShape.position
		var x_size = $StaticBody2D/CollisionShape.shape.extents.x
		var y_size = $StaticBody2D/CollisionShape.shape.extents.y
		$HorizontalOverlap.position = pos
		$HorizontalOverlap.shape.extents = Vector2(x_size + 10, y_size)
		$VerticalOverlap.position = pos
		$VerticalOverlap.shape.extents = Vector2(x_size, y_size + 10)

# Add self to list of interactive objects if in range
func _on_TaskArea_body_entered(body):
	if body is Player:
		print("Adding ", self)
		body.interactables.append(self)

# Remove self from list of interactive objects if out of range
func _on_TaskArea_body_exited(body):
	if body is Player:
		print("Removing ", self)
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
		status = 2
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
