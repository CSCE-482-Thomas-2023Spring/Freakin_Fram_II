extends Area2D

export(NodePath) var node_path
export(String) var call_method
export(bool) var require_interact = true

func _on_body_entered(body):
	if body is Player:
		
		if require_interact:
			print("Adding ", self)
			body.interactables.append(self)
		else:
			print("Interacting with ", self)
			interact()

func _on_body_exited(body):
	if body is Player:
		print("Removing ", self)
		body.interactables.erase(self)

func interact():
	if get_node_or_null(node_path) != null:
		if get_node(node_path).has_method(call_method):
			get_node(node_path).call(call_method)
