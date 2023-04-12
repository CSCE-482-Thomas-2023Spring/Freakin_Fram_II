extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var import_whitelist = []
var import_blacklist = []

func removeCommas(line):
	var regex = RegEx.new()
	regex.compile(",")
	return regex.sub(line, "", true)

func determineImport(line):
	var words = removeCommas(line).lstrip(" ").lstrip("	").split(" ")
	var imports = []
	
	if len(words) <= 1:
		return []
	
	#import a, b, c case
	if words[0] == "import":
		for i in range(1, len(words)):
			if words[i] == "as": break
			imports.append(words[i])
	#from <module> import <functions> case
	elif words[0] == "from":
		imports.append(words[1])
		
	return imports
		

func getAllImports(file):
	var my_file = File.new()
	my_file.open(file, File.READ)
	var all_imports = []
	while not my_file.eof_reached():
		var curr_imports = determineImport(my_file.get_line())
		all_imports.append_array(curr_imports)
	my_file.close()
	return all_imports
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
