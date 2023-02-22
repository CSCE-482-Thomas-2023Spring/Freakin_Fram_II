extends TextEdit


# Declare member variables
var output

# Called when the node enters the scene tree for the first time.
func _ready():
	output = $"../Output/Output Text"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button_pressed():
	var code_text = get_text()
	var python_dir = "./python_files/python.exe"
	if (OS.get_name() == "OSX" || OS.get_name() == "X11"):
		python_dir = "python3"
	var code_path = ProjectSettings.globalize_path("user://code.py")
	var stdout = []
	
	# Open and write to code.py to pass to python.exe
	var file = File.new()
	file.open(code_path, File.WRITE)
	file.store_string(code_text)
	file.close()
	
	# Pass code.py to python and put returns into stdout array
	var exit_code = OS.execute(python_dir, [code_path], true, stdout, true)
	print(stdout, " \nexit_code: ", exit_code)
	
	# Change output box to the result of Python code
	output.text = stdout[0]
