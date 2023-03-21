extends StaticBody2D

var can_interact = false

func _ready():
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Interact_body_entered(body):
	print(body, " entered Robot")


func _on_Interact_body_exited(body):
	print("Player exited Robot")
