extends GraphNode

var pic_connected: bool = false
var pic_node: GraphNode = null:
	set(value):
		pic_node = value
		set_change_dict("pic", value)
		if value != null:
			set_change_dict("pic name", value.get_name())

var dialogue_connected: bool = false
var dialogue_node: GraphNode = null

var change_dict: Dictionary = {
	"change node name": "",
	"pic": null,
	"pic name": "",
	"new path": "",
	"delay before": 0,
	"delay after": 0,
}

@onready var path_line_edit = %PathLineEdit
@onready var delay_before = %DelayBefore
@onready var delay_after = %DelayAfter


func _ready():
	set_change_dict("change node name", get_name())
	set_change_dict("pic", pic_node)


func set_change_dict(key: String, new_value):
	if change_dict.has(key):
		change_dict[key] = new_value
	else:
		print("Key does not exist.")


func load_change_dict(new_dict: Dictionary) -> void:
	change_dict = new_dict.duplicate
	path_line_edit.text = new_dict["new path"]
	delay_before.value = new_dict["delay before"]
	delay_after.value = new_dict["delay after"]


func _on_close_request():
	if not pic_connected and not dialogue_connected:
		get_parent().position_offset_dict.erase(get_name())
		get_parent().change_node_index -= 1
		get_parent().global_node_count -= 1
		queue_free()
	
	else:
		$"../CloseConnectedWarning".popup_centered()


func _on_position_offset_changed():
	if get_parent() != null:
		get_parent().position_offset_dict[get_name()]["x"] = position_offset.x
		get_parent().position_offset_dict[get_name()]["y"] = position_offset.y


func _on_resize_request(new_minsize):
	size = new_minsize


func _on_clear_button_pressed():
	path_line_edit.text = ""
	path_line_edit.text_changed.emit(path_line_edit.text)


func _on_open_button_pressed():
	$FileDialog.popup_centered()


func _on_file_dialog_file_selected(path):
	path_line_edit.text = path
	path_line_edit.text_changed.emit(path_line_edit.text)


func _on_path_line_edit_text_changed(new_text):
	set_change_dict("new path", new_text)


func _on_delay_before_value_changed(value):
	set_change_dict("delay before", value)


func _on_delay_after_value_changed(value):
	set_change_dict("delay after", value)
