extends ColorRect

export var dialogPath = ""
export(float) var textSpeed = .05

var dialog

var phraseNum = 0
var finished = false

func _ready():
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
	assert(f.file_exists(dialogPath), "File path does not exist")
	
	f.open(dialogPath, File.READ)
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
