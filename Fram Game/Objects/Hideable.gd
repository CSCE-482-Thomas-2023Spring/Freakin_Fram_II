extends Node2D

# Enumerated type for levels 0-7
enum level_num {PodRoom, MaintenanceCloset, Laboratory, Navigation, Security, CrewQuarters, Communications, ReactorRoom}

# The level task which triggers this object to hide upon completion
export(level_num) var condition_level
export var condition_task: int = 1

# On status update by level, remove this object if its condition is met
func check_condition(current_status: Array):
	# Check if the set conditions are valid
	if (not current_status.size() >= condition_level + 1):
		print("ERROR: Hideable object " + name + ": level " + level_num.keys()[condition_level] + " does not exist in status array")
		return
	if (not current_status[condition_level].size() >= condition_task):
		print("ERROR: Hideable object " + name + ": task #" + str(condition_task) + " does not exist in status array")
		return
	if (condition_task < 1):
		print("ERROR: Hideable object " + name + " task number " + str(condition_task) + " is out of range")
		return
	
	# Remove this object from level if the condition has been met
	if (current_status[condition_level][condition_task - 1] == 3):
		queue_free()
