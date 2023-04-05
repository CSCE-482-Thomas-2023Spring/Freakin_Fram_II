extends Area2D

# Enumerated room type based on all existing rooms in game
# TODO: remove TestRoom after devlopment
enum room_type {PodRoom, MaintenanceCloset, Laboratory, Navigation, Security, CrewQuarters, Communications, ReactorRoom, Bridge, CargoBay, HallwayWest, HallwayEast, TestRoom}

# Settable variables for the rooms involved in navigation (this room -> target room)
export(room_type) var target_room
export(room_type) var this_room

func _on_Transition_body_entered(body):
	if body is Player:
		# Call new room from Main scene
		var target_string = room_type.keys()[target_room]
		var this_string = room_type.keys()[this_room]
		
		var root = get_tree().get_root().get_node("Main")
		if root:
			root.call_deferred("load_room", target_string, this_string)
