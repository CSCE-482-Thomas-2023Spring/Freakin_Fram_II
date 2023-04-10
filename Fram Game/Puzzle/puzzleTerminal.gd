extends Node

# Path variables
# Source Path: "res://SourceFiles/Level" + [level #] + "/Task" + [task #] + "/"
export var source_path = "DefaultMessages/TaskTemplate/" setget _set_path
export var puzzle_success: bool = false setget ,get_status
var python_dir = "./python_files/python.exe" # python executable
var test_code_file = "user://testCode.py" # the test script
var test_code_file_g = ProjectSettings.globalize_path(test_code_file)
var godot_user_path_g = ProjectSettings.globalize_path("user://")
onready var test_task_path = ProjectSettings.globalize_path("res://SourceFiles/" + source_path + "TaskData-Initial.json")
signal task_success

var tutorials = ["level0.png", "level1.png", "level3.png", "level4.png", "level5.png"]
var curr_tutorial = 2
var main_tutorial = 2 # this is the tutorial relevant to the current level

# Setter for task path
func _set_path(new_val: String) -> void:
	source_path = new_val

# Getter for puzzle success status
func get_status() -> bool:
	return puzzle_success

# Variable declarations for internal use
var successes = 0
var caseCount = 1
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var pause = false

func update_tutorial(ind):
	$Tutorial/TutorialText.bbcode_text = "[img=500]res://Puzzle/Tutorials/" + tutorials[ind] + "[/img]"

# Call a dialogue tree from input file location
func create_box(json_path):
	# if this dialogue box does not exist for this task, use the default
	var this_path = source_path + json_path
	var f = File.new()
	if (not f.file_exists("res://SourceFiles/" + this_path)):
		this_path = "DefaultMessages/TaskTemplate/" + json_path
	
	# call a dialogue tree from input file location
	var dialog = dialogueBox.instance()
	dialog.get_node("DialogueBox")._set_path(this_path)
	add_child(dialog)
	yield(pause_editor(dialog), "completed")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Hide pause button
	if (get_tree().get_root().has_node("Main")):
		get_tree().get_root().get_node("Main").get_node("MenuButton").hide()
	
	# load the current tutorial
	update_tutorial(curr_tutorial)
	
	# display initial source code as read from corresponding file in path
	var sourceCode = File.new()
	sourceCode.open("res://SourceFiles/" + source_path + "StarterCode-Initial.py", File.READ)
	$Editor.get_node("VBoxContainer").get_node("Input").text = sourceCode.get_as_text()
	sourceCode.close()
	
	# insert readonly lines as read from source data json
	var sourceData = File.new()
	sourceData.open("res://SourceFiles/" + source_path + "TaskData-Initial.json", File.READ)
	var readOnlyLines = JSON.parse(sourceData.get_as_text()).result["readOnly"]
	$Editor.get_node("VBoxContainer").get_node("Input").readonly_set(readOnlyLines)
	
	# fetch prompt and set the text
	var promptText = File.new()
	promptText.open("res://SourceFiles/" + source_path + "Prompt.txt", File.READ)
	$Prompt.text = promptText.get_as_text()
	promptText.close()
  
	# Check if temporary save data exists
	var temp_code = File.new()
	if (temp_code.file_exists("res://SourceFiles/" + source_path + "/StarterCode-Temp.py")):
		
		# Update displayed code to match temporary code
		temp_code.open("res://SourceFiles/" + source_path + "StarterCode-Temp.py", File.READ)
		$Editor.get_node("VBoxContainer").get_node("Input").text = temp_code.get_as_text()
		temp_code.close()
		
		# Update readonly lines to match temporary lines
		var temp_data = File.new()
		temp_data.open("res://SourceFiles/" + source_path + "TaskData-Temp.json", File.READ)
		readOnlyLines = JSON.parse(temp_data.get_as_text()).result["readOnly"]
		$Editor.get_node("VBoxContainer").get_node("Input").readonly_set(readOnlyLines)
		temp_data.close()
	
	# _ready copies the test script from PythonScripts to user://
	var file = File.new()
	file.open("res://PythonScripts/testCode.py", File.READ)
	var testCode = file.get_as_text()
	file.close()
	
	var userTestCode = File.new()
	userTestCode.open(test_code_file, File.WRITE)
	userTestCode.store_string(testCode)
	userTestCode.close()
	
	# Display initial task-introduction dialogue
	yield(create_box("Introduction.json"), "completed")

# Pause all editor functionality while dialogue is present	
func pause_editor(instance):
	$Editor/VBoxContainer/Input.disabled = true
	yield(instance, "tree_exited")
	$Editor/VBoxContainer/Input.disabled = false

func process_test_results_function(cases):
	successes = 0
	caseCount = len(cases)
	var failureInput = null
	var successCountString = ""
	var failureString = ""
	for result in cases:
		if result.passed:
			successes += 1
		else:
			failureInput = result.input
	
	successCountString = "{0}/{1} test cases passed".format([successes, len(cases)])
	if failureInput != null:
		var paramString = ""
		# the parameters to a function are stored as a list inside the test json
		for i in range(len(failureInput)-1):
			paramString = paramString + str(failureInput[i]) + ", "
		
		paramString = paramString + str(failureInput[len(failureInput)-1])
		failureString = "Suggestion: try testing your function with inputs " + paramString + "."
	
	return [successCountString, failureString]

func process_test_results_stdout(cases):
	successes = 0
	caseCount = len(cases)
	var failureInput = null
	var successCountString = ""
	var failureString = ""
	for result in cases:
		if result.passed:
			successes += 1
			
	successCountString = "{0}/{1} test cases passed".format([successes, len(cases)])
	return successCountString

func on_button_pressed():
	
	# Prevent execution of editor if disabled
	if ($Editor/VBoxContainer/Input.disabled):
		return
	$Editor/VBoxContainer/Input.executeUserCode()
	
	# Parse information from 
	var jsonTestFile = File.new()
	jsonTestFile.open("res://SourceFiles/" + source_path + "TaskData-Initial.json", File.READ)
	var testData = JSON.parse(jsonTestFile.get_as_text()).result # this is the parsed test json
	jsonTestFile.close()
	var stdout = []
	var exit_code = OS.execute(python_dir, [test_code_file_g, test_task_path, python_dir, godot_user_path_g], true, stdout, true)	
	print(stdout)
	var file = File.new()
	file.open("user://results.json", File.READ)
	var results = JSON.parse(file.get_as_text()).result # this is the parsed test results json
	file.close()
	
	
	# EXAMPLE FOR EMILY (use later to print suggestions based on error types)
	if not results.has('error'):
		var successCountString = ""
		var failureString = ""
		if testData.data.useFunction:
			var data = process_test_results_function(results.testResults)
			successCountString = data[0]
			failureString = data[1]
			print(successCountString)
			print(failureString)
		elif testData.data.usestdout:
			successCountString = process_test_results_stdout(results.testResults)
			print(successCountString)
	
	# Set dialogue for end-of-task success & close terminal as needed
	if (successes == caseCount):
		yield(create_box("Success.json"), "completed")
		emit_signal("task_success")
		
		# Display pause button once again
		if (get_tree().get_root().has_node("Main")):
			get_tree().get_root().get_node("Main").get_node("MenuButton").show()
		
		# Delete self
		queue_free()
		
	#else: # Path: n/a, but will display in-editor dialogue in the future
	#	var dialog = dialogueBox.instance()
	#	dialog.get_node("DialogueBox")._set_path(source_path + "Success.json")
	#	add_child(dialog)
	#	yield(pause_editor(dialog), "completed")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



# Call tutorial menu
func tutorial_button_pressed():
	$Tutorial.visible = not $Tutorial.visible

# Index displayed tutorial to the right
func tutorial_right_pressed():
	curr_tutorial = (curr_tutorial + 1) % len(tutorials)
	update_tutorial(curr_tutorial)

# Index displayed tutorial to the left
func tutorial_left_pressed():
	curr_tutorial = (curr_tutorial - 1) % len(tutorials)
	update_tutorial(curr_tutorial)

# Index displayed tutorial to the most relevant one to this puzzle
func tutorial_main_pressed():
	curr_tutorial = main_tutorial
	update_tutorial(curr_tutorial)

# Save current task progress to temporary file and exit terminal
func _on_ExitButton_pressed():
	# Delete this task's existing temporary py file
	var f_py = File.new()
	var temp_py = "res://SourceFiles/" + source_path + "/StarterCode-Temp.py"
	if (f_py.file_exists(temp_py)):
		var dir = Directory.new()
		dir.remove(temp_py)
	
	# Create a new temporary py file to write to
	if (f_py.open(temp_py, File.WRITE) != 0):
		# Error opening file
		print("ERROR: Could not save to temporary py file " + temp_py)
		return
	
	# Store new python data
	f_py.store_string($Editor/VBoxContainer/Input.get_text())
	f_py.close()
	
	# Delete this task's existing temporary readonly line file
	var f_rdonly = File.new()
	var temp_rdonly = "res://SourceFiles/" + source_path + "/TaskData-Temp.json"
	if (f_rdonly.file_exists(temp_rdonly)):
		var dir = Directory.new()
		dir.remove(temp_rdonly)
	
	# Create a new temporary readonly line file to write to
	if (f_rdonly.open(temp_rdonly, File.WRITE) != 0):
		# Error opening file
		print("ERROR: Could not save to temporary readonly file " + temp_rdonly)
		return
	
	# Access initial source data for certain elements of the new task data
	var sourceData = File.new()
	sourceData.open("res://SourceFiles/" + source_path + "TaskData-Initial.json", File.READ)
	var old_data = JSON.parse(sourceData.get_as_text()).result["data"]
	var old_cases = JSON.parse(sourceData.get_as_text()).result["cases"]
	sourceData.close()
	
	# Set up new readonly line data
	var new_rdonly = {
		"readOnly": $Editor/VBoxContainer/Input.readonly_get(),
		"data": old_data,
		"cases" : old_cases
	}
	
	# Store new readonly line data
	f_rdonly.store_line(to_json(new_rdonly))
	f_rdonly.close()
	
	# Display pause button once again
	if (get_tree().get_root().has_node("Main")):
		get_tree().get_root().get_node("Main").get_node("MenuButton").show()
	
	# Close terminal
	queue_free()
