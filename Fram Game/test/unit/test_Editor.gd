extends GutTest

var _editor = load("res://Editor/Editor.tscn")
var editor

var read_only_lines = [[1, 2, 3], [4, 5, 6]]
var code

func before_each():
	editor = autofree(_editor.instance()).get_node("VBoxContainer/Input")
	editor._ready()
	if OS.get_name() == "X11" or OS.get_name() == "OSX":
		code = [["print('test')", "test\n"], ["x = True\nprint(x)", "True\n"]]
	else:
		code = [["print('test')", "test\r\n"], ["x = True\nprint(x)", "True\r\n"]]

func test_readonly_set(p=use_parameters(read_only_lines)):
	editor.set_text("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
	editor.readonly_set(p)
	assert_eq(editor.read_only_lines, p)
	
func test_readonly_get(p=use_parameters(read_only_lines)):
	editor.set_text("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
	editor.readonly_set(p)
	assert_eq(editor.readonly_get(), p)

func test_executeUserCode(p=use_parameters(code)):
	editor.set_text(p[0])
	assert_eq(editor.executeUserCode(), p[1])



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
