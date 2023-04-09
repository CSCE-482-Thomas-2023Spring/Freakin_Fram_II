extends Node2D

# Global Variables - always available, updated throughout play
# ==============================================================
# Story Progress - format: [event 1 status, event 2 status, event 3 status, ...]
var story = []
# Task Status 2D Array - format: [[Level 0 Task 1 Status, Level 0 Task 2 Status], [Level 1 Task 1 Status]] etc
var level_tasks = [] setget update_statuses
# Level Entry Locations - format: entry_locations["NewRoom"]["SourceRoom"] = [x position, y position]
var entry_locations = {}
# Player's current room location
var current_level = 0
var starting_location = Vector2(384, 304)
# Current level scene reference
var current_scene
# Global data storage location
var global_path = "res://SourceFiles/GlobalData/"

# Preload necessary scene types
var mainMenu = preload("res://Menus/MainMenu.tscn")
var roomScenes = {}

# Function called from level to update new task status values
func update_statuses(new_statuses: Array):
	# Update task status values
	level_tasks = new_statuses
	
	# Check for untriggered story events
	check_story()

# Load tasks & start menu on game start
func _ready():
	# Initialize task statuses & level starting locations to default values, preload scenes
	init_scenes()
	init_tasks()
	init_locations()
	init_story()
	
	# Call title screen for Start / Continue options; initiate game based on signal
	var title_screen = mainMenu.instance()
	add_child(title_screen)
	title_screen.connect("start_game", self, "load_room", ["PodRoom", ""])
	title_screen.connect("load_game", self, "load_data")
	
	# Fix weird VBoxContainer position bug that is very weird and sets the position to the margin instead
	title_screen.get_node("VBoxContainer").rect_position.y = 450
	current_scene = title_screen

# Initialize preloaded scene variables for use in room-changing
func init_scenes():
	roomScenes["PodRoom"] = preload("res://Room/PodRoom.tscn")
	roomScenes["MaintenanceCloset"] = preload("res://Room/MaintenanceCloset.tscn")
	roomScenes["Laboratory"] = preload("res://Room/Laboratory.tscn")
	roomScenes["Navigation"] = preload("res://Room/Navigation.tscn")
	roomScenes["Security"] = preload("res://Room/Security.tscn")
	roomScenes["CrewQuarters"] = preload("res://Room/CrewQuarters.tscn")
	roomScenes["Communications"] = preload("res://Room/Communications.tscn")
	roomScenes["ReactorRoom"] = preload("res://Room/ReactorRoom.tscn")
	roomScenes["Bridge"] = preload("res://Room/Bridge.tscn")
	roomScenes["CargoBay"] = preload("res://Room/CargoBay.tscn")
	roomScenes["HallwayWest"] = preload("res://Room/HallwayWest.tscn")
	roomScenes["HallwayEast"] = preload("res://Room/HallwayEast.tscn")
	roomScenes["TestRoom"] = preload("res://Room/TestRoom.tscn") # TODO: remove after development

# Initialize default level task values based on task initialization json
func init_tasks():
	# Open locations' json file location
	var f = File.new()
	var tasks_path = global_path + "Initialize-Tasks.json"
	assert(f.file_exists(tasks_path), "File path " + tasks_path + " does not exist")
	f.open(tasks_path, File.READ)
	
	# Store locations to global variable
	var json = f.get_as_text()
	level_tasks = parse_json(json)
	
	print("Initial Tasks:")
	var index = 0
	while(index < 8):
		print("Level " + str(index) + ": " + str(level_tasks[index]))
		index += 1

# Initialize room starting player data
func init_locations():
	# Open locations' json file location
	var f = File.new()
	var location_path = global_path + "Initialize-Locations.json"
	assert(f.file_exists(location_path), "File path " + location_path + " does not exist")
	f.open(location_path, File.READ)
	
	# Store locations to global variable
	var json = f.get_as_text()
	entry_locations = parse_json(json)

# Initialize starting story progress data
func init_story():
	# Initialize story progress array to all incomplete values - TODO: update number of story events
	var index = 0
	while (index < 50):
		story.append(0)
		index += 1

# Initiate gameplay with saved data; Load Game
func load_data():
	# Load task status variables & player location from saved data - TODO
	var start_room = "TestRoom" # TODO: pull value from saved data
	
	# Load started puzzle task programs from saved data - TODO
	
	# Initiate gameplay
	load_room(start_room, "")

# Load a new room with corresponding location & task status values
func load_room(room_name: String, source_room: String):
	# Ensure room transition is valid (there exists connection between source and dest rooms)
	# TODO: remove TestRoom after development
	if ((entry_locations.has(room_name) or (room_name == "TestRoom")) and ((source_room == "") or source_room == "TestRoom" or entry_locations[room_name].has(source_room))):
		
		# Load room scene
		var new_room = roomScenes[room_name].instance()
		
		# Set player position within room if applicable
		var player_location = room_pos(room_name, source_room)
		new_room.get_node("Player").position = player_location
		
		# Set status of tasks within room
		new_room.set_status(level_tasks)
		
		# Connect to room's signal for updating task status
		new_room.connect("level_update", self, "update_statuses", [new_room.get_status()])
		
		# Finish transition to room
		add_child(new_room)
		current_scene.queue_free()
		current_scene = new_room
		
		# Check for untriggered story events
		check_story()

# Return the starting position of level x when coming from level y
func room_pos(level_name: String, source_name: String = "") -> Vector2:
	# Return starting location if the player is not coming from a room (y = "")
	if (source_name == "" or source_name == "TestRoom"): # TODO: remove TestRoom after development
		return starting_location
	
	# return that room's location value according to the global location array
	var this_location = entry_locations[level_name][source_name]
	return Vector2(this_location[0], this_location[1])

# Overhead story progress-checking function: triggers story events and unlocks tasks in order
func check_story():
	# Wait a moment before triggering events
	yield(get_tree().create_timer(0.1), "timeout")
	
	# Immediate task-solving triggers & updates:
	# -----------------------------------------------
	# Level 0 (Pod Room) task triggers
	var level_status = level_tasks[0]
	if (level_status[0] == 3 and level_tasks[1][0] == 0):
		# When Level 0 Task 1 is completed, unblock Level 1 Task 1
		level_tasks[1][0] = 1
		current_scene.set_status(level_tasks)
		return
	
	# Level 1 (Maintenance Closet) task triggers
	level_status = level_tasks[1]
	if (level_status[0] == 3 and level_tasks[1][1] == 0):
		# When Level 1 Task 1 is completed, unblock Level 1 Task 2
		level_tasks[1][1] = 1
		current_scene.set_status(level_tasks)
		return
	if (level_status[1] == 3 and level_tasks[2][0] == 0):
		# When Level 1 Task 2 is completed, unblock Level 2 Task 1
		level_tasks[2][0] = 1
		level_tasks[2][1] = 1
		level_tasks[2][2] = 1
		level_tasks[2][3] = 1
		level_tasks[2][4] = 1
		level_tasks[2][5] = 1
		current_scene.set_status(level_tasks)
		return
	
	# Level 2 (Laboratory) task triggers - TODO: update as necessary
	level_status = level_tasks[2]
	if (level_status[0] == 3 and level_status[1] == 3 and level_status[2] == 3 and level_status[3] == 3 and level_status[4] == 3 and level_status[5] == 3 and level_tasks[2][6] == 0):
		# When Level 2 Tasks 6 are completed, unblock Level 2 Task 7
		level_tasks[2][6] = 1
		current_scene.set_status(level_tasks)
		return
	if (level_status[6] == 3 and level_tasks[3][0] == 0):
		# When Level 2 Task 7 is completed, unblock Level 3 Task 1
		level_tasks[3][0] = 1
		current_scene.set_status(level_tasks)
		return
	
	# Level 3 (Navigation) task triggers
	level_status = level_tasks[3]
	if (level_status[0] == 3 and level_tasks[4][0] == 0):
		# When Level 3 Task 1 is completed, unblock Level 4 Task 1
		level_tasks[4][0] = 1
		current_scene.set_status(level_tasks)
		return
	
	# Level 4 (Security) task triggers
	level_status = level_tasks[4]
	if (level_status[0] == 3 and level_tasks[4][1] == 0):
		# When Level 4 Task 1 is completed, unblock Level 4 Task 2
		level_tasks[4][1] = 1
		current_scene.set_status(level_tasks)
		return
	if (level_status[0] == 3 and level_tasks[5][0] == 0):
		# When Level 4 Task 2 is completed, unblock Level 5 Task 1
		level_tasks[5][0] = 1
		current_scene.set_status(level_tasks)
		return
	
	# Level 5 (Crew Quarters) task triggers
	level_status = level_tasks[5]
	if (level_status[0] == 3 and level_tasks[5][1] == 0):
		# When Level 5 Task 1 is completed, unblock Level 5 Task 2
		level_tasks[5][1] = 1
		current_scene.set_status(level_tasks)
		return
	if (level_status[0] == 3 and level_tasks[6][0] == 0):
		# When Level 5 Task 2 is completed, unblock Level 6 Task 1
		level_tasks[6][0] = 1
		current_scene.set_status(level_tasks)
		return
	
	# Level 6 (Communications) task triggers
	level_status = level_tasks[6]
	if (level_status[0] == 3 and level_tasks[6][1] == 0):
		# When Level 6 Task 1 is completed, unblock Level 6 Task 2
		level_tasks[6][1] = 1
		current_scene.set_status(level_tasks)
		return
	if (level_status[0] == 3 and level_tasks[7][0] == 0):
		# When Level 6 Task 2 is completed, unblock Level 7 Task 1
		level_tasks[7][0] = 1
		current_scene.set_status(level_tasks)
		return
	
	# Level 7 (Reactor Room) task triggers
	level_status = level_tasks[7]
	
	# Location-based events: - TODO: elaborate & make updates to current_level in load_room function
	# ----------------------------------------
	# Pod Room events
	if (current_level == 0):
		# Trigger first cutscene: Ingrid wakes Player from cryosleep
		if (story[0] == 0):
			# TODO: event
			story[0] = 1
			check_story()
			return
	
	# Maintenance Closet events
	if (current_level == 1):
		pass
	
	# Laboratory events
	if (current_level == 2):
		pass
	
	# Navigation events
	if (current_level == 3):
		pass
	
	# Security events
	if (current_level == 4):
		pass
	
	# Crew Quarters events
	if (current_level == 5):
		pass
	
	# Communications events
	if (current_level == 6):
		pass
	
	# Reactor Room events
	if (current_level == 7):
		pass
	
	# Bridge events
	if (current_level == 8):
		pass
	
	# Cargo Bay events
	if (current_level == 9):
		pass
	
	# West Hallway events
	if (current_level == 10):
		pass
	
	# East Hallway events
	if (current_level == 11):
		pass
