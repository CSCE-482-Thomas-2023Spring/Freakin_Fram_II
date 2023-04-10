extends Node2D

# Enumerated room type based on all existing rooms in game
enum room_type {PodRoom, MaintenanceCloset, Laboratory, Navigation, Security, CrewQuarters, Communications, ReactorRoom, Bridge, CargoBay, HallwayWest, HallwayEast}
# Global Variables - always available, updated throughout play
# ==============================================================
# Story Progress - format: [event 1 status, event 2 status, event 3 status, ...]
var story = []
# Character Interaction Progress - format: conversations["CharacterName"][TalkNum] = status (0/1) of interacting with Character for instance Num
var conversations = []
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
# Reference to pause menu screen if applicable
var pause_scene
# Global path to user folder
var user_path = ProjectSettings.globalize_path("user://")

# Preload necessary scene types
var mainMenu = preload("res://Menus/MainMenu.tscn")
var pauseMenu = preload("res://Menus/PauseMenu.tscn")
var roomScenes = {}

# Function called from level to update new task status values
func update_statuses(new_statuses: Array):
	# Update task status values
	level_tasks = new_statuses
	
	# Check for untriggered story events
	check_story()
	
	# TODO: delete when done testting
	print("Story (Status):")
	print(str(story))

# Function called from character to update new conversation status values
# TODO: add characters & link, test
func update_conversation(new_conversations: Array):
	# Update conversation status values
	conversations = new_conversations
	
	# TODO: delete after development
	print("Conversations:")
	print(str(conversations))
	
	# Check for untriggered story events - TODO: add character-based events
	check_story()
	
	# TODO: delete when done testing
	print("Story (Conversations):")
	print(str(story))

# Load tasks & start menu on game start
func _ready():
	# Initialize global variables & level starting locations to default values, preload scenes
	init_scenes()
	init_globals()
	init_locations()
	init_user()
	
	# Hide pause menu button
	$MenuButton.hide()
	
	# Call title screen for Start / Continue options; initiate game based on signal
	var title_screen = mainMenu.instance()
	add_child(title_screen)
	title_screen.connect("start_game", self, "load_room", ["PodRoom", ""])
	title_screen.connect("load_game", self, "load_data")
	title_screen.connect("quit_game", self, "quit_game")
	
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

# Initialize default global variable values based on initialization json
func init_globals():
	# Open global variables' json file location
	var f = File.new()
	var full_path = global_path + "GlobalData-Initial.json"
	assert(f.file_exists(full_path), "File path " + full_path + " does not exist")
	f.open(full_path, File.READ)
	
	# Access initial global data from json
	var json = f.get_as_text()
	var global_data = parse_json(json)
	
	# Store initial global data as global variables
	level_tasks = global_data["Tasks"]
	conversations = global_data["Conversations"]
	story = global_data["Story"]

# Initialize room starting player data
func init_locations():
	# Open locations' json file location
	var f = File.new()
	var location_path = global_path + "LocationData.json"
	assert(f.file_exists(location_path), "File path " + location_path + " does not exist")
	f.open(location_path, File.READ)
	
	# Store locations to global variable
	var json = f.get_as_text()
	entry_locations = parse_json(json)

# Initialize user path directories if not already existing
func init_user():
	var dir = Directory.new()
	
	# Initialize SaveFiles folder
	if (not dir.dir_exists(user_path + "SaveFiles")):
		dir.make_dir(user_path + "SaveFiles")
	
	# Initialize GlobalData folder
	if (not dir.dir_exists(user_path + "SaveFiles/GlobalData")):
		dir.make_dir(user_path + "SaveFiles/GlobalData")
	
	# Initialize each level folder
	var level_index = 0
	while (level_index < 8):
		if (not dir.dir_exists(user_path + "SaveFiles/Level" + str(level_index))):
			dir.make_dir(user_path + "SaveFiles/Level" + str(level_index))
		
		# Initialize each task folder
		var task_index = 1
		while (task_index <= level_tasks[level_index].size()):
			if (not dir.dir_exists(user_path + "SaveFiles/Level" + str(level_index) + "/Task" + str(task_index))):
				dir.make_dir(user_path + "SaveFiles/Level" + str(level_index) + "/Task" + str(task_index))
			task_index += 1
		level_index += 1

# Initiate gameplay with saved data; Load Game
func load_data():
	# Open global variables' json file location
	var f = File.new()
	var full_path = user_path + "SaveFiles/GlobalData/GlobalData-Saved.json"
	assert(f.file_exists(full_path), "File path " + full_path + " does not exist")
	f.open(full_path, File.READ)
	
	# Access saved global data from json
	var json = f.get_as_text()
	var global_data = parse_json(json)
	
	# Store saved global data as global variables
	level_tasks = global_data["Tasks"]
	conversations = global_data["Conversations"]
	story = global_data["Story"]
	
	# Update current location data
	var location_data = global_data["Location"]
	current_level = location_data["RoomNum"]
	starting_location = Vector2(location_data["X"], location_data["Y"])
	
	# Load any previously started tasks from saved data to temporary data
	# ----------------------------------------------------------------------
	# Open SourceFiles directory to iterate through tasks
	var source_dir = Directory.new()
	source_dir.open(user_path + "SaveFiles")
	source_dir.list_dir_begin()
	var level_name = source_dir.get_next()
	while (level_name != ""):
		
		# Check each folder within SourceFiles for the "Level" substring
		if ((source_dir.current_is_dir()) and (level_name.substr(0, 5) == "Level")):
			# Open level directory for iteration
			var level_dir = Directory.new()
			level_dir.open(user_path + "SaveFiles/" + level_name)
			level_dir.list_dir_begin()
			var task_name = level_dir.get_next()
			while (task_name != ""):
				
				# Check each folder within level directory for the "Task" substring
				if ((level_dir.current_is_dir()) and (task_name.substr(0, 4) == "Task")):
					var this_path = user_path + "SaveFiles/" + level_name + "/" + task_name + "/"
					
					# If saved task data exists, create temp files to match
					var save_code = File.new()
					if (save_code.file_exists(this_path + "StarterCode-Saved.py")):
						
						# Open python save file & read data
						save_code.open(this_path + "StarterCode-Saved.py", File.READ)
						var code = save_code.get_as_text()
						save_code.close()
						
						# Open python temp file & store data
						var temp_code = File.new()
						temp_code.open(this_path + "StarterCode-Temp.py", File.WRITE)
						temp_code.store_string(code)
						temp_code.close()
						
						# Open task data save file & read data
						var save_data = File.new()
						save_data.open(this_path + "TaskData-Saved.json", File.READ)
						var data = parse_json(save_data.get_as_text())
						save_data.close()
						
						# Open task data temp file & store data
						var temp_data = File.new()
						temp_data.open(this_path + "TaskData-Temp.json", File.WRITE)
						temp_data.store_line(to_json(data))
						temp_data.close()
				
				# Load next task folder
				task_name = level_dir.get_next()
		
		# Load next level folder
		level_name = source_dir.get_next()
	
	# Initiate gameplay
	load_room(room_type.keys()[current_level], "")

func save_data():
	# Erase existing saved data file
	var f = File.new()
	var save_path = user_path + "SaveFiles/GlobalData/GlobalData-Saved.json"
	if (f.file_exists(save_path)):
		var dir = Directory.new()
		dir.remove(save_path)
	
	# Parse global variable and location data into a dictionary
	var new_data = {
		"Location": {
			"RoomNum": current_level,
			"X": current_scene.get_node("Player").get_position()[0],
			"Y": current_scene.get_node("Player").get_position()[1]
		},
		"Tasks": level_tasks,
		"Conversations": conversations,
		"Story": story
	}
	
	# Open a new json data file
	if (f.open(save_path, File.WRITE) != 0):
		# Error opening file
		print("ERROR: Could not save to file " + save_path)
		return
	
	# Convert the dictionary data into a json and store it
	f.store_line(to_json(new_data))
	f.close()
	
	# Save any existing temporary task data
	# ----------------------------------------------------------------------
	# Open SourceFiles directory to iterate through tasks
	var source_dir = Directory.new()
	source_dir.open(user_path + "SaveFiles")
	source_dir.list_dir_begin()
	var level_name = source_dir.get_next()
	while (level_name != ""):
		
		# Check each folder within SourceFiles for the "Level" substring
		if ((source_dir.current_is_dir()) and (level_name.substr(0, 5) == "Level")):
			# Open level directory for iteration
			var level_dir = Directory.new()
			level_dir.open(user_path + "SaveFiles/" + level_name)
			level_dir.list_dir_begin()
			var task_name = level_dir.get_next()
			while (task_name != ""):
				
				# Check each folder within level directory for the "Task" substring
				if ((level_dir.current_is_dir()) and (task_name.substr(0, 4) == "Task")):
					var this_path = user_path + "SaveFiles/" + level_name + "/" + task_name + "/"
					
					# If saved task data exists, create temp files to match
					var temp_code = File.new()
					if (temp_code.file_exists(this_path + "StarterCode-Temp.py")):
						
						# Open python temp file & read data
						temp_code.open(this_path + "StarterCode-Temp.py", File.READ)
						var code = temp_code.get_as_text()
						temp_code.close()
						
						# Open python save file & store data
						var save_code = File.new()
						save_code.open(this_path + "StarterCode-Saved.py", File.WRITE)
						save_code.store_string(code)
						save_code.close()
						
						# Open task data temp file & read data
						var temp_data = File.new()
						temp_data.open(this_path + "TaskData-Temp.json", File.READ)
						var data = parse_json(temp_data.get_as_text())
						temp_data.close()
						
						# Open task data save file & store data
						var save_data = File.new()
						save_data.open(this_path + "TaskData-Saved.json", File.WRITE)
						save_data.store_line(to_json(data))
						save_data.close()
				
				# Load next task folder
				task_name = level_dir.get_next()
		
		# Load next level folder
		level_name = source_dir.get_next()

# Return to the title screen of the game - called by pause menu
func game_title():
	# Delete any existing temporary task data
	# ----------------------------------------------------------------------
	# Open SourceFiles directory to iterate through tasks
	var source_dir = Directory.new()
	source_dir.open(user_path + "SaveFiles")
	source_dir.list_dir_begin()
	var level_name = source_dir.get_next()
	while (level_name != ""):
		
		# Check each folder within SourceFiles for the "Level" substring
		if ((source_dir.current_is_dir()) and (level_name.substr(0, 5) == "Level")):
			# Open level directory for iteration
			var level_dir = Directory.new()
			level_dir.open(user_path + "SaveFiles/" + level_name)
			level_dir.list_dir_begin()
			var task_name = level_dir.get_next()
			while (task_name != ""):
				
				# Check each folder within level directory for the "Task" substring
				if ((level_dir.current_is_dir()) and (task_name.substr(0, 4) == "Task")):
					var this_path = user_path + "SaveFiles/" + level_name + "/" + task_name + "/"
					
					# If saved task data exists, delete it
					var temp_code = File.new()
					if (temp_code.file_exists(this_path + "StarterCode-Temp.py")):
						
						# Delete both temporary files
						var dir = Directory.new()
						dir.remove(this_path + "StarterCode-Temp.py")
						dir.remove(this_path + "TaskData-Temp.json")
				
				# Load next task folder
				task_name = level_dir.get_next()
		
		# Load next level folder
		level_name = source_dir.get_next()
	
	# Close current level and reset global variables
	close_pause()
	current_scene.queue_free()
	
	# Restart game
	current_level = 0
	starting_location = Vector2(384, 304)
	_ready()

# Quit the game - called by main menu
func quit_game():
	# Exit game
	get_tree().quit()

# Load a new room with corresponding location & task status values
func load_room(room_name: String, source_room: String):
	# Ensure room transition is valid (there exists connection between source and dest rooms)
	if ((entry_locations.has(room_name)) and ((source_room == "") or entry_locations[room_name].has(source_room))):
		
		# Unhide pause menu button
		$MenuButton.show()
		
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
		
		# Update value of current room number
		current_level = room_type.get(room_name)
		
		# Check for untriggered story events
		check_story()
		
		# TODO: delete when done testing
		print("Story (Load Room):")
		print(str(story))

# Return the starting position of level x when coming from level y
func room_pos(level_name: String, source_name: String = "") -> Vector2:
	# Return starting location if the player is not coming from a room (y = "")
	if (source_name == ""):
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
	
	# Location-based events: - TODO: elaborate
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

# When menu is pressed, open menu scene over current scene
func _on_MenuButton_pressed():
	# Open pause menu and set focus
	$MenuButton.hide()
	pause_scene = pauseMenu.instance()
	add_child(pause_scene)
	pause_scene.get_node("VBoxContainer").get_node("SaveButton").grab_focus()
	
	# Pause current level scene
	remove_child(current_scene)
	
	# Connect menu button signals
	pause_scene.connect("save_game", self, "save_data")
	pause_scene.connect("quit_game", self, "game_title")
	pause_scene.connect("close_menu", self, "close_pause")

# Close pause menu - called from pause menu
func close_pause():
	# Close pause menu and redisplay button
	pause_scene.queue_free()
	$MenuButton.show()
	
	# Unpause current level scene
	add_child(current_scene)
	
