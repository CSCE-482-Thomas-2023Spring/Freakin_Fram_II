extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Right Button
func _on_ButtonR_pressed():
	self.visible = !self.visible

# Left button
func _on_ButtonL_pressed():
	self.visible = !self.visible
