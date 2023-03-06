extends ColorRect

export var dialogPath = "TestDialogue.json" setget _set_path, _get_path
export(float) var textSpeed = .05

func _set_path(new_val: String) -> void:
	dialogPath = new_val

func _get_path() -> String:
	return dialogPath

var dialog
var dialogPathFull

var phraseNum = 0
var finished = false

func _ready():
	dialogPathFull = "res://GameDialogue/" + dialogPath
	$Timer.wait_time = textSpeed
	$Indicator/AnimationPlayer.play("DialogueIndicatorBounce")
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()

func _process(_delta):
	$Indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			nextPhrase()

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

func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		print(phraseNum)
		queue_free()
		return
	
	finished = false;
	
	$Nametag.bbcode_text = dialog[phraseNum]["Name"]
	$DialogueText.bbcode_text = dialog[phraseNum]["Text"]
	
	$DialogueText.visible_characters = 0
	
	while $DialogueText.visible_characters < len($DialogueText.text):
		$DialogueText.visible_characters += 1
		
		$Timer.start()
		yield($Timer, "timeout")
	
	finished = true
	phraseNum += 1
	return
