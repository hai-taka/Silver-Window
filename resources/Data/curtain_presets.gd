extends Resource

@export var line_colors: Dictionary


func _init(p_line_colors = {}):
	line_colors = p_line_colors


func add_preset(name: String, color: Color) -> void:
	if not line_colors.has(name):
		line_colors[name] = color
	else:
		print("Preset with that name already exists.")


func remove_preset(name: String) -> void:
	if line_colors.has(name):
		line_colors.erase(name)
	else:
		print("Preset with that name not found.")


func preset_exists(name: String) -> bool:
	return line_colors.has(name)


func get_color(name: String) -> Color:
	if line_colors.has(name):
		return line_colors[name]
	else:
		return Color("c0c0c0")


func get_dict() -> Dictionary:
	return line_colors.duplicate()
