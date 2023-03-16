extends ColorRect

# Export variables
export var dialogPath = "TestDialogue.json" setget _set_path, _get_path
export(float) var textSpeed = .025

# Set/Get functions for dialogPath for access by instances in scripts
func _set_path(new_val: String) -> void:
	dialogPath = new_val
func _get_path() -> String:
	return dialogPath

# Variable declarations for internal use
var dialog
var dialogPathFull
var phraseNum = 0
var finished = false

# Initializes variables & begins display w/ first phrase
func _ready():
	dialogPathFull = "res://SourceFiles/" + dialogPath
	$Timer.wait_time = textSpeed
	$Indicator/AnimationPlayer.play("DialogueIndicatorBounce")
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()

# Every tick, accept input if the text display is finishd
func _process(_delta):
	$Indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			nextPhrase()

# Get this conversation's full dialogue from a json file and return it as an array
func getDialog() -> Array:
	var f = File.new()
	assert(f.file_exists(dialogPathFull), "File path " + dialogPathFull + " does not exist")
	
	f.open(dialogPathFull, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []

# Displays next line of dialogue
func nextPhrase() -> void:
	# Ends scene if dialogue is complete
	if phraseNum >= len(dialog):
#		print(phraseNum)
		get_parent().queue_free()
		return
	
	finished = false;
	
	$Nametag.bbcode_text = dialog[phraseNum]["Name"]
	$DialogueText.bbcode_text = dialog[phraseNum]["Text"]
	
	# Slowly displays each character in the line of dialogue according to textSpeed
	$DialogueText.visible_characters = 0
	while $DialogueText.visible_characters < len($DialogueText.text):
		$DialogueText.visible_characters += 1
		
		$Timer.start()
		yield($Timer, "timeout")
	
	finished = true
	phraseNum += 1
	return
