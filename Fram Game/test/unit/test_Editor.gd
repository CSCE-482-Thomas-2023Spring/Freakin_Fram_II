extends GutTest

var _editor = load("res://Editor/Editor.gd")
var editor

var read_only_lines = [[1, 2, 3], [4, 5, 6]]

func before_each():
	editor = _editor.new()

func test_readonly_set(p=use_parameters(read_only_lines)):
	editor.set_text("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
	editor.readonly_set(p)
	assert_eq(editor.read_only_lines, p)
	
func test_readonly_get(p=use_parameters(read_only_lines)):
	editor.set_text("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
	editor.readonly_set(p)
	assert_eq(editor.readonly_get(), p)




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
