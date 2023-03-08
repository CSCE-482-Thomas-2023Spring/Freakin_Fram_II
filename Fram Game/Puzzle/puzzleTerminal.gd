extends Node2D

# Path variables
# Source Path: "res://SourceFiles/Level" + [level #] + "/Task" + [task #] + "/" + [specific file]
export var source_path = "Level0/Task1/" setget _set_path, _get_path
var python_dir = "./python_files/python.exe" # python executable
var test_code_file = "user://testCode.py" # the test script
var test_code_file_g = ProjectSettings.globalize_path(test_code_file)
var godot_user_path_g = ProjectSettings.globalize_path("user://")
onready var test_task_path = ProjectSettings.globalize_path("res://SourceFiles/" + source_path + "TaskData.json")

# Setter/Getter for task path
func _set_path(new_val: String) -> void:
	source_path = new_val
func _get_path() -> String:
	return source_path

# Variable declarations for internal use
var successes = 0
var caseCount = 0
var dialogueBox = preload("res://DialogueBox/DialogueBox.tscn")
var pause = false
	
# Called when the node enters the scene tree for the first time.
func _ready():
	# display initial source code as read from corresponding file in path
	var sourceCode = File.new()
	sourceCode.open("res://SourceFiles/" + source_path + "StarterCode.py", File.READ)
	$Editor.get_node("VBoxContainer").get_node("Input").text = sourceCode.get_as_text()
	sourceCode.close()
	
	# insert readonly lines as read from source data json
	var sourceData = File.new()
	sourceData.open("res://SourceFiles/" + source_path + "TaskData.json", File.READ)
	var readOnlyLines = JSON.parse(sourceData.get_as_text()).result["readOnly"]
	$Editor.get_node("VBoxContainer").get_node("Input").readonly_set(readOnlyLines)
	
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
	var dialog = dialogueBox.instance()
	dialog.get_node("DialogueBox")._set_path(source_path + "Introduction.json")
	add_child(dialog)
	pause_editor(dialog)

func pause_editor(instance):
	# Pause all editor functionality while dialogue is present
	pause = true
	$Editor.get_tree().paused = true
	while (is_instance_valid(instance)):
		yield(get_tree().create_timer(.2), "timeout")
	$Editor.get_tree().paused = false
	pause = false

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
	$Editor/VBoxContainer/Input.executeUserCode()
	
	# Parse information from 
	var jsonTestFile = File.new()
	jsonTestFile.open("res://SourceFiles/" + source_path + "TaskData.json", File.READ)
	var testData = JSON.parse(jsonTestFile.get_as_text()).result # this is the parsed test json
	jsonTestFile.close()
	var stdout = []
	var exit_code = OS.execute(python_dir, [test_code_file_g, test_task_path, python_dir, godot_user_path_g], true, stdout, true)	
	print(stdout)
	var file = File.new()
	file.open("res://results.json", File.READ)
	var results = JSON.parse(file.get_as_text()).result # this is the parsed test results json
	file.close()
	
	
	# EXAMPLE FOR EMILY
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
		var dialog = dialogueBox.instance()
		dialog.get_node("DialogueBox")._set_path(source_path + "Success.json")
		add_child(dialog)
		pause_editor(dialog)
		while (pause):
			yield(get_tree().create_timer(.2), "timeout")
		queue_free()
	#else: # Path: n/a, but will display in-editor dialogue in the future
	#	var dialog = dialogueBox.instance()
	#	dialog.get_node("DialogueBox")._set_path(source_path + "Success.json")
	#	add_child(dialog)
	#	pause_editor(dialog)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

