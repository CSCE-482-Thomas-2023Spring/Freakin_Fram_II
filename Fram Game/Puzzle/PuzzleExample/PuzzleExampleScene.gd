extends Node2D

# Preload scene types before instancing them
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var terminal = preload("res://Puzzle/puzzleTerminal.tscn")

# Call the two room-based dialogues, then open the terminal for puzzle 1
func _ready():
	#$PuzzleTerminal.visible = false # Temporary workaround; remove later
	# Call initial dialogue
	#var spawn_dialog = dialogueBox.instance()
	#spawn_dialog.get_node("DialogueBox")._set_path("Level0/Room-Introduction.json")
	#add_child(spawn_dialog)
	#while (is_instance_valid(spawn_dialog)):
	#	yield(get_tree().create_timer(.2), "timeout")
	
	# After a moment, call the second dialogue
	yield(get_tree().create_timer(2), "timeout")
	var interact_dialog = dialogueBox.instance()
	interact_dialog.get_node("DialogueBox")._set_path("Level0/ClosetDoor-Interact.json")
	add_child(interact_dialog)
	while (is_instance_valid(interact_dialog)):
		yield(get_tree().create_timer(.2), "timeout")
	
	# Call the terminal for this puzzle - temporarily disabled until I figure out how puzzles are being input
	var puzzle1 = terminal.instance()
	puzzle1._set_path("Level0/Puzzle1/")
	add_child(puzzle1)
	
	## Temporary workaround to the above issue
	#$PuzzleTerminal.visible = true
	#$PuzzleTerminal.get_tree().paused = true
	#var intro_dialog = dialogueBox.instance()
	#intro_dialog.get_node("DialogueBox")._set_path("Level0/Puzzle1-Introduction.json")
	#add_child(intro_dialog)
	#while (is_instance_valid(intro_dialog)):
	#	yield(get_tree().create_timer(.2), "timeout")
	#$PuzzleTerminal.get_tree().paused = false
	
	# Demonstration over; end game
	while (is_instance_valid(puzzle1)):
		yield(get_tree().create_timer(.2), "timeout")
	yield(get_tree().create_timer(2), "timeout")
	get_tree().quit()
