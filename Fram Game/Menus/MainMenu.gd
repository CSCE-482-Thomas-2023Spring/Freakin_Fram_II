extends Control

# Signal Variables for Main
signal start_game
signal load_game

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/StartButton.grab_focus()

func _on_StartButton_pressed():
	# Notify Main to start the game anew
	emit_signal("start_game")
	#get_tree().change_scene("res://Room/cyro.tscn")

func _on_ContinueButton_pressed():
	# Notify Main to start the game loading from saved data
	emit_signal("load_game")

func _on_OptionsButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()
