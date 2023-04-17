extends ColorRect

var TestInfo = load("res://Puzzle/TestCases/TestInfo.tscn")
var Dropdown = load("res://Puzzle/TestCases/dropdown.tscn")

# Called when the node enters the scene tree for the first time.
var cases = {}

func case_pressed(case):
	if case in cases:
		$VBoxContainer.remove_child(cases[case])
		cases.erase(case)
		return
	var ind = case.get_index()
	var dropdown = Dropdown.instance()
	dropdown.get_node("RichTextLabel").text = case.dropdown_text
	$VBoxContainer.add_child(dropdown)
	$VBoxContainer.move_child(dropdown, ind+1)
	dropdown.visible = true
	cases[case] = dropdown

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
	
	new_case.get_node("Button").connect("pressed", self, "case_pressed", [new_case])
	
	$VBoxContainer.add_child(new_case)
	

func _ready():
	for i in range(10):
		add_case("test case " + str(i), true, "1, 2, 3", "howdy", "bruh")
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
