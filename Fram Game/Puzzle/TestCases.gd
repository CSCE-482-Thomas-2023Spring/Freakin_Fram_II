extends ColorRect

var TestInfo = load("res://Puzzle/TestCases/TestInfo.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(10):
		$ItemList.add_child(TestInfo.instance())
		#$ItemList.get_child(i).text = "test case " + str(i)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
