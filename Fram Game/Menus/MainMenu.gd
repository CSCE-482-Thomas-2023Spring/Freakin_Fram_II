extends Control

# Signal Variables for Main
signal start_game
signal load_game
signal quit_game
signal delete_game

# Path for confirmation menu
var confirm_menu = preload("res://Menus/ConfirmMenu.tscn")

# Global path to user folder
var user_path = ProjectSettings.globalize_path("user://")

func _ready():
	# Set focus on buttons to enable keyboard/controller input
	$VBoxContainer/StartButton.grab_focus()
	
	# Delete continue & delete save buttons if no save file is detected
	var f = File.new()
	if (not f.file_exists(user_path + "SaveFiles/GlobalData/GlobalData-Saved.json")):
		$VBoxContainer/ContinueButton.queue_free()
		$VBoxContainer/DeleteButton.queue_free()

func _on_StartButton_pressed():
	# Notify Main to start the game anew
	emit_signal("start_game")

func _on_ContinueButton_pressed():
	# Notify Main to start the game loading from saved data
	emit_signal("load_game")

func _on_DeleteButton_pressed():
	# Open confirmation menu and connect result
	var confirmation = confirm_menu.instance()
	confirmation.connect("yes_result", self, "delete_save")
	add_child(confirmation)
	
	# Disable the rest of the menu until a selection is made
	$VBoxContainer/StartButton.disabled = true
	$VBoxContainer/ContinueButton.disabled = true
	$VBoxContainer/DeleteButton.disabled = true
	$VBoxContainer/QuitButton.disabled = true
	yield(confirmation, "tree_exited")
	$VBoxContainer/StartButton.disabled = false
	$VBoxContainer/ContinueButton.disabled = false
	$VBoxContainer/DeleteButton.disabled = false
	$VBoxContainer/QuitButton.disabled = false

# Called on confirmation of quitting the game
func delete_save():
	# Signal Main to delete existing save data from the user folder
	emit_signal("delete_game")
	
	# Delete continue & delete save buttons once save data is deleted
	$VBoxContainer/ContinueButton.queue_free()
	$VBoxContainer/DeleteButton.queue_free()

func _on_QuitButton_pressed():
	# Notify Main to quit the game and delete temporary data
	emit_signal("quit_game")
