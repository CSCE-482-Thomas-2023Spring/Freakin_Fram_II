extends Node2D

# Signal Variables for calling menu
signal yes_result

func _ready():
	# Set focus on buttons to enable keyboard/controller input
	$VBoxContainer/Yes.grab_focus()

func _on_Yes_pressed():
	# Tell calling menu the result is a confirmation
	emit_signal("yes_result")
	queue_free()

func _on_No_pressed():
	# Close menu
	queue_free()
