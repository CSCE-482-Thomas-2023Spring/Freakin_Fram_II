extends Area2D

# Enumerated room type based on all existing rooms in game
enum room_type {PodRoom, MaintenanceCloset, Laboratory, Navigation, Security, CrewQuarters, Communications, ReactorRoom, Bridge, CargoBay, HallwayWest, HallwayEast}

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

		# Change room label in main.tscn to reflect new room
		var roomLabel = root.get_node("RoomLabel")
		print("Target Room: ", room_type.keys()[target_room])
		roomLabel.text = room_type.keys()[target_room]
