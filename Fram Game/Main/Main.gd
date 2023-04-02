extends Node2D

# Global Variables - always available, updated throughout play
# ==============================================================
# Task Status 2D Array - format: [[Level 0 Task 1 Status, Level 0 Task 2 Status], [Level 1 Task 1 Status]] etc
var level_tasks = []
# Level Entry Location 2D Array - format: [[L0 location from L0, L0 location from L1], [L1 location from L0]] etc
var entry_locations = []
# Player's current room location
var current_level = 0
var starting_location = Vector2(0, 0)
# Current level scene reference
var current_scene

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
	pass # TODO: probably pull from a JSON

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
	current_scene.get_tree().change_scene("res://Room/cyro.tscn")
	print("New scene: " + str(current_scene))
	# Place the player at the location designated in the global variable - TODO
	pass

# Return the starting position of level x when coming from level y
func room_pos(level_num: int, source_num: int = -1) -> Vector2:
	# Return starting location if the player is not coming from a room (y = -1)
	if (source_num == -1):
		return starting_location
	# return that room's location value according to the global location array - TODO
	return starting_location

func room_status():
	pass
