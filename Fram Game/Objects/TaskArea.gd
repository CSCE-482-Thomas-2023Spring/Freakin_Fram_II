extends Area2D

export var task_path: String = "DefaultMessages/TaskTemplate/" setget set_path
export var task_status: int = 0 setget set_status
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var terminal = preload("res://Puzzle/puzzleTerminal.tscn")

# Setter function for task's path ("res://SourceFiles/Level" + [level #] + "/Task" + [task #] + "/")
func set_path(new_path):
	task_path = new_path

# Setter function for task's completion status (0 = locked, 1 = unstarted, 2 = started, 3 = finished)
func set_status(new_status):
	task_status = new_status

# Reusable dialogue-calling function
func dialogue(json_path):
	var box = dialogueBox.instance()
	box.get_node("DialogueBox")._set_path(json_path)
	add_child(box)
	yield(box, "tree_exited")

# Reusable task-calling function
func launch_task(json_path):
	var task = terminal.instance()
	task._set_path(json_path)
	add_child(task)
	yield(task, "tree_exited")

func _ready():
	# Scale collision areas to match size of parent's rect positions
	pass

# Add self to list of interactive objects if in range
func _on_body_entered(body):
	if body is Player:
		print("Adding ", self)
		body.interactables.append(self)

# Remove self from list of interactive objects if out of range
func _on_body_exited(body):
	if body is Player:
		print("Removing ", self)
		body.interactables.erase(self)

# Call task dialogue & terminal on interact based on task status
func interact():
	var player = get_node("../../Player")
	if (task_status == 0):
		# If task is locked, prevent access
		player.disable()
		yield(dialogue(task_path + "Interact-Blocked.json"), "completed")
		player.enable()
	elif (task_status == 1):
		# If task is unstarted, start for the first time
		player.disable()
		yield(dialogue(task_path + "Interact-TaskStart.json"), "completed")
		yield(launch_task(task_path), "completed")
		player.enable()
	elif (task_status == 2):
		# If task is started, continue from before
		player.disable()
		yield(dialogue(task_path + "Interact-Return.json"), "completed")
		yield(launch_task(task_path), "completed")
		player.enable()
	elif (task_status == 3):
		# If task is completed, prevent access
		player.disable()
		yield(dialogue(task_path + "Interact-Complete.json"), "completed")
		player.enable()
