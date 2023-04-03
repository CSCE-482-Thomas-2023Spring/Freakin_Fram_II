
#
#	Copyright 2018-2020, SpockerDotNet LLC.
#	https://gitlab.com/godot-stuff/gs-ecs/-/blob/master/LICENSE.md
#
#	Class: Group
#
#	Helper Class for the Developer to create a
#	collection of Systems to Run during the
#	game.
#
#	Remarks:
#
#		A Group is a way to place Systems together. This is useful
#		when you want to control what happens to a number of entities
#		without having to control each individual component on
#		the entity.
#
#	How To Use:
#
#		Place this Class, or Sub Class it onto a Parent Node. Any
#		Child Node should be a type of System.
#

class_name Group, "res://addons/gs_ecs/icons/share2.png"
extends Node

func _ready():

	var _systems = []
	for _system in get_children():
		_systems.append(_system.name.to_lower())
	ECS.add_group(self, _systems)
