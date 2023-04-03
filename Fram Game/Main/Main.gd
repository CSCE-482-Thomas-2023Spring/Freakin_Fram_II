extends Node2D

# Global Variables - always available, updated throughout play
# ==============================================================
# Task Status 2D Array - format: [[Level 0 Task 1 Status, Level 0 Task 2 Status], [Level 1 Task 1 Status]] etc
var level_tasks = []
# Level Entry Locations - format: entry_locations["NewRoom"]["SourceRoom"] = [x position, y position]
var entry_locations = {}
# Player's current room location
var current_level = 0
var starting_location = Vector2(480, 288)
# Current level scene reference
var current_scene
# Global data storage location
var global_path = "res://SourceFiles/GlobalData/"

# Preload necessary scene types
var mainMenu = preload("res://Menus/MainMenu.tscn")

# Load tasks & start menu on game start
func _ready():
	# Initialize all task statuses & level starting locations to their defaults
	init_tasks()
	init_locations()
	# Call title screen for Start / Continue options; initiate game based on signal - TODO
	var title_screen = mainMenu.instance()
	add_child(title_screen)
	title_screen.connect("start_game", self, "start_game")
	title_screen.connect("load_game", self, "load_data")
	# Fix weird VBoxContainer position bug that is very weird and sets the position to the margin instead
	title_screen.get_node("VBoxContainer").rect_position.y = 450
	current_scene = title_screen

# Initialize default level task values based on level & task folders from SourceFiles
# TODO: probably update this to pull from a json of default task statuses instead, as some will start at 1, etc.
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

# Initiate gameplay with saved data; Load Game
func load_data():
	print("Loading game data")
	# Load task status variables & player location from saved data - TODO
	# Load started puzzle task programs from saved data - TODO
	# Initiate gameplay
	start_game()

# Initiate gameplay; New Game if called directly
func start_game():
	print("Starting game")
	# Load the room designated in the global variable - TODO
	print("Previous scene: " + str(current_scene))
	current_scene.get_tree().change_scene("res://Room/PodRoom.tscn")
	print("New scene: " + str(current_scene))
	# Place the player at the location designated in the global variable - TODO
	pass

# Return the starting position of level x when coming from level y
func room_pos(level_name: String, source_name: String = "") -> Vector2:
	# Return starting location if the player is not coming from a room (y = "")
	if (source_name == ""):
		return starting_location
	# return that room's location value according to the global location array
	var this_location = entry_locations[level_name][source_name]
	return Vector2(this_location[0], this_location[1])

# Return the task status variables of level x
func room_status(level_num: int) -> Array:
	return level_tasks[level_num]
