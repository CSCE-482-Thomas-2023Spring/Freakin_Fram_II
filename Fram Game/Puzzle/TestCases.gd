extends ColorRect

var TestInfo = load("res://Puzzle/TestCases/TestInfo.tscn")
var Dropdown = load("res://Puzzle/TestCases/dropdown.tscn")

# Called when the node enters the scene tree for the first time.
onready var vbox = $ScrollContainer/VBoxContainer

func case_pressed(case):
	var ind = case.get_index()
	var dropdown = vbox.get_child(ind+1)
	dropdown.visible = not dropdown.visible

func add_case(case_name, passed, input, expected, user_output):
	var new_case = TestInfo.instance()
	new_case.get_node("Button/VBoxContainer/Label").text = case_name
	new_case.get_node("Button/pass").visible = false
	new_case.get_node("Button/fail").visible = false
	if passed:
		new_case.get_node("Button/pass").visible = true
	else:
		new_case.get_node("Button/fail").visible = true
	
	var input_text = "Input: " + input
	var user_out_text = "Your output: " + user_output
	var expected_output_text = "Expected: " + expected
	var dropdown_text = input_text + "\n" + user_out_text + "\n" + expected_output_text + "\n"
	new_case.dropdown_text = dropdown_text
	
	var dropdown = Dropdown.instance()
	dropdown.get_node("RichTextLabel").text = new_case.dropdown_text
	dropdown.visible = false
	
	new_case.get_node("Button").connect("pressed", self, "case_pressed", [new_case])
	
	vbox.add_child(new_case)
	vbox.add_child(dropdown)
	

func _ready():
	for i in range(20):
		add_case("test case " + str(i), true, "1, 2, 3", "howdy", "bruh")
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
