extends Node2D

# Task Status 2D Array - format: [Level 0: [Task 1 Status, Task 2 Status], Level 1: [Task 1 Status]] etc
var level_tasks = []

# Initialize default level task values based on level & task folders from SourceFiles
func init_tasks():
	# Open SourceFiles directory for iteration
	var source_folder = Directory.new()
	source_folder.open("res://SourceFiles")
	source_folder.list_dir_begin()
	var level_name = source_folder.get_next()
	while (level_name != ""):
		
		# Check each folder within SourceFiles for the "Level" substring
		if ((source_folder.current_is_dir()) and (level_name.substr(0, 5) == "Level")):
			var task_list = []
			# Open level directory for iteration
			var level_folder = Directory.new()
			level_folder.open("res://SourceFiles/" + level_name)
			level_folder.list_dir_begin()
			var task_name = level_folder.get_next()
			while (task_name != ""):
				
				# Check each folder within level directory for the "Task" substring
				if ((level_folder.current_is_dir()) and (task_name.substr(0, 4) == "Task")):
					var task_status = 0
					# Add this task's default status to its level's array
					task_list.append(task_status)
				task_name = level_folder.get_next()
				
			# Add this level's array of task statuses to the overarching tasks array
			level_tasks.append(task_list)
		level_name = source_folder.get_next()

# Called when the node enters the scene tree for the first time.
func _ready():
	init_tasks()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
