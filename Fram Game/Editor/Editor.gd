extends TextEdit


# Declare member variables
var output

# Called when the node enters the scene tree for the first time.
func _ready():
	output = $"../Output/Output Text"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# parse a string from the OS.execute command and check if it is an error message
func isError(code_message):
	
	# Errors we have a description for
	var errors = [
		"TypeError",
		"SyntaxError"
	]
	
	# Create a regex
	var regex = RegEx.new()
	
	# Check for the word "File", then match any characters until the phrase ", line"
	regex.compile("File.*, line")
	var result = regex.search(code_message)
	
	var errored = ( result != null )
	var type = null
	
	# If the result is not null, then an error was found
	if errored:
	
		for error in errors:
			# Check if error is in the message
			regex.compile(error)
			result = regex.search(code_message)
			if result:
				type = error
				break
		
	return [errored, type]

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
	
	var code_output = stdout[0]
	
	print("isError: ", isError(code_output))
	
	# Change output box to the result of Python code
	output.text = code_output
