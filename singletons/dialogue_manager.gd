extends Node

var dialogue_script = {}
var dialogue_script_file_path = ""


func _ready():
	pass
	#dialogue_script = load_json_file(dialogue_script_file_path)


func change_script(path: String):
	dialogue_script_file_path = path
	dialogue_script = load_json_file(path)


func load_json_file(path: String):
	if FileAccess.file_exists(path):
		var json_file = FileAccess.open(path, FileAccess.READ)
		var parsed = JSON.parse_string(json_file.get_as_text())
		
		if parsed is Dictionary:
			return parsed
		
		else:
			print("Error: Parsed result not dictionary.")
		
	else:
		print("Error: File does not exist: " + path)
