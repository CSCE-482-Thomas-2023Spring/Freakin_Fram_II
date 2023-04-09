extends Control

# Signal Variables for Main
signal start_game
signal load_game

func _ready():
	# Set focus on buttons to enable keyboard/controller input
	$VBoxContainer/StartButton.grab_focus()
	
	# Delete continue button if no save file is detected
	var f = File.new()
	if (not f.file_exists("res://SourceFiles/GlobalData/GlobalData-Saved.json")):
		$VBoxContainer/ContinueButton.queue_free()

func _on_StartButton_pressed():
	# Notify Main to start the game anew
	emit_signal("start_game")

func _on_ContinueButton_pressed():
	# Notify Main to start the game loading from saved data
	emit_signal("load_game")

func _on_OptionsButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()
