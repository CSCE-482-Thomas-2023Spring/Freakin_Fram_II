extends Node2D

# Signal variables for interaction with Main
signal save_game
signal quit_game
signal close_menu

# When the save button is pressed, tell Main to save the game
func _on_SaveButton_pressed():
	emit_signal("save_game")

# When the quit button is pressed, tell Main to return to the title screen
func _on_QuitButton_pressed():
	emit_signal("quit_game")

# Close this menu when pressed
func _on_CloseButton_pressed():
	emit_signal("close_menu")
