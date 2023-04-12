extends TextEdit


# Declare member variables
onready var output = $"../Output/Output Text"

# Change this variable to make lines read only (bookmarked)
# Eg : [ 0, 2 ] will set lines 1 and 3 to read only
export(Array, int) var read_only_lines = [] setget readonly_set, readonly_get

export var disabled = false setget disable_set

# Setter for read only lines
func readonly_set(var new_lines):
	read_only_lines = new_lines
	set_read_only_lines()

# Update and return the read only line array
func readonly_get():
	# Create a new array for readonly lines
	var new_rdonly = []
	
	# Iterate through each line of code in the TextEdit
	var index = 0
	while (index < get_line_count()):
		# Check if this line is marked as readonly
		if (is_line_set_as_bookmark(index)):
			# Add this line to the readonly array if marked as such
			new_rdonly.append(index)
		index += 1
	
	# Replace & return resulting array
	read_only_lines = new_rdonly
	return read_only_lines

func disable_set(new_value):
	disabled = new_value
	if disabled == true:
		# mark as read only
		self.readonly = true
	else:
		self.readonly = false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# --- replace initial prompt here ---
	set_read_only_lines()

# Catches any input before the GUI
func _input(event):
	
	if (!has_focus()):
		return
		
	# Allow any mouse or mouse motion event
	if event is InputEventMouseButton or event is InputEventMouseMotion or event.is_action("Arrow Keys"):
		return
	
	# Prevent action if selection contains a read only line
	if self.is_selection_active():
		var start_line = self.get_selection_from_line()
		var end_line = self.get_selection_to_line()
		for line in range(start_line, end_line + 1):
			if self.is_line_set_as_bookmark(line):
				# Void the event
				self.accept_event()
				self.deselect()
				
	# Currently prevented actions are Backspace and Enter
	# Go to Project Settings and Input Map Tab to change
	if is_read_only():
		var current_line = self.cursor_get_line()
		var column = self.cursor_get_column()
		var length = self.get_line(current_line).length()
		
		# Allow the user to press enter iff cursor is at the end of the last line of the editor
		if column != length:
			pass
		elif current_line+1 != self.get_line_count():
			pass
		elif event.is_action("Enter"):
			print("input allowed")
			return
			
		# Accept the event before the GUI, effectively voiding it
		self.accept_event()
	
	# Prevent delete key if line is above a read only line
	if event.is_action("Delete"):
		var next_line = self.cursor_get_line() + 1
		var column = self.cursor_get_column()
		var length = self.get_line(next_line - 1).length()
		
		if !self.is_line_set_as_bookmark(next_line):
			pass
		elif column != length:
			pass
		else:
			self.accept_event()
			
		return
	
	# Prevent a writiable line from collapsing onto a read only line
	if (event.is_action("Backspace")):
		var current_line = self.cursor_get_line()
		var column = self.cursor_get_column()
		
		# Let backspace through if at the first line
		if (current_line == 0):
			return
			
		# Check if line above is read only
		if (self.is_line_set_as_bookmark(current_line - 1)):
			# Check if cursor is at the beginning of the line
			if (column == 0):
				self.accept_event()

func _unhandled_input(event):
	if event.is_action("Delete"):
		print(event.as_text())

func set_read_only_lines():
	for line in read_only_lines:
		self.set_line_as_bookmark(line, true)

func is_read_only():
	var current_line_number = self.cursor_get_line()
	return self.is_line_set_as_bookmark(current_line_number)
	
# parse a string from the OS.execute command and check if it is an error message
func is_error(code_message):
	
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

func executeUserCode():
	if (disabled):
		return
	
	var code_text = get_text()
	var python_dir = "./python_files/python.exe"
	if (OS.get_name() == "OSX" || OS.get_name() == "X11"):
		python_dir = "python3"
	var code_path = ProjectSettings.globalize_path("user://userCode.py")
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
	
	print("is_error: ", is_error(code_output))
	
	# Change output box to the result of Python code
#	if (setText):
	output.text = code_output
	return code_output

#func _on_Button_pressed():
#	print("Setting output")
#	executeUserCode(true)
