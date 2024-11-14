extends Resource

@export var text_colors: Dictionary


func _init(p_text_colors = {}):
	text_colors = p_text_colors


func add_preset(name: String, color: Color) -> void:
	if not text_colors.has(name):
		text_colors[name] = color
	else:
		print("Preset with that name already exists.")


func remove_preset(name: String) -> void:
	if text_colors.has(name):
		text_colors.erase(name)
	else:
		print("Preset with that name not found.")


func preset_exists(name: String) -> bool:
	return text_colors.has(name)


func get_color(name: String) -> Color:
	if text_colors.has(name):
		return text_colors[name]
	else:
		return Color("c0c0c0")


func get_dict() -> Dictionary:
	return text_colors.duplicate()
