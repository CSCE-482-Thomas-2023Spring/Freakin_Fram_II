extends Reference

# declare any helper methods for tests here

func get_file_as_text(filename):
	var file = File.new()
	file.open(filename, File.READ)
	var text = file.get_as_text()
	file.close()
	return text

