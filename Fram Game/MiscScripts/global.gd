extends Node

var python_dir = "./python_files/python.exe"

func _ready():
	if (OS.get_name() == "OSX" || OS.get_name() == "X11"):
		python_dir = "python3"
