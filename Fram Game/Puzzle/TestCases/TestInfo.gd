extends Control

export(String) var text
export(String) var dropdown_text 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Button/VBoxContainer/Label.text = text
	$dropdown/RichTextLabel.text = dropdown_text


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func button_pressed():
	var dropdown = $dropdown
	if dropdown != null:
		dropdown.visible = !dropdown.visible
