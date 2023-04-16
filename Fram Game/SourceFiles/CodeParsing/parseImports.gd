extends Reference
class_name ParseImport

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var import_whitelist = ["math", "functions"]
var import_blacklist = ["sys"]
var imports = []
var invalid_import = ""
var file = ""

func _init(file):
	self.file = file
	getAllImports()

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
		

func getAllImports():
	var my_file = File.new()
	my_file.open(file, File.READ)
	var all_imports = []
	while not my_file.eof_reached():
		var curr_imports = determineImport(my_file.get_line())
		all_imports.append_array(curr_imports)
	my_file.close()
	imports = all_imports
	return imports
	
func validateWithWhitelist():
	for module in imports:
		if not (module in import_whitelist):
			invalid_import = module
			return false
	return true
	
func validateWithBlacklist():
	for module in imports:
		if module in import_blacklist:
			invalid_import = module
			return false
	return true
	


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
