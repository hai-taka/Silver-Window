extends GraphNode

var pic_connected: bool = false:
	set(value):
		pic_connected = value
		control_picture.disabled = !value
		if control_picture.disabled:
			control_picture.button_pressed = false

var pic_node: GraphNode = null:
	set(value):
		pic_node = value
		move_dict["pic"] = value
		if value != null:
			move_dict["pic name"] = value.get_name()

var dialogue_connected: bool = false
var dialogue_node: GraphNode = null

var move_dict: Dictionary = {
	"move node name": null,
	"pic": null,
	"pic name": null,
	"new pos x": null,
	"new pos y": null,
	"move type": null,
	"new path": "",
	"delay before": 0,
	"delay after": 0,
	"sound dict": {
		"play sound": false,
		"new track": false,
		"sound path": "",
	},
}

@onready var editor = get_parent()
@onready var test_player = editor.test_player
@onready var sfx_button = %SFXButton
@onready var play_button = %PlayButton
@onready var stop_button = %StopButton

@onready var new_pos_x = $VBoxContainer/HBoxContainer/NewPosX
@onready var new_pos_y = $VBoxContainer/HBoxContainer/NewPosY
@onready var move_type = $VBoxContainer/HBoxContainer2/MoveTypeOptions
@onready var control_picture = %ControlPicture
@onready var path_line_edit = %PathLineEdit
@onready var delay_before = %DelayBefore
@onready var delay_after = %DelayAfter
@onready var preview_rect = %PreviewRect
@onready var preview_check = %PreviewCheck
@onready var play_sound = %PlaySound
@onready var new_track = %NewTrack
@onready var sound_path = %SoundPath
@onready var clear_sound = %ClearSound
@onready var open_sound = %OpenSound


# Called when the node enters the scene tree for the first time.
func _ready():
	move_dict["move node name"] = get_name()
	move_dict["pic"] = pic_node
	move_dict["new pos x"] = new_pos_x.value
	move_dict["new pos y"] = new_pos_y.value
	move_dict["move type"] = move_type.selected


func _on_close_request():
	if not pic_connected and not dialogue_connected:
		get_parent().position_offset_dict.erase(get_name())
		get_parent().move_node_index -= 1
		get_parent().global_node_count -= 1
		queue_free()
	
	else:
		$"../CloseConnectedWarning".popup_centered()


func _on_resize_request(new_minsize):
	size = new_minsize


func set_move_dict(key: String, new_value):
	if move_dict.has(key):
		move_dict[key] = new_value
	else:
		print("Key does not exist.")


func load_move_dict(new_dict: Dictionary) -> void:
	#move_dict = new_dict.duplicate
	path_line_edit.text = new_dict["new path"]
	path_line_edit.text_changed.emit(path_line_edit.text)
	delay_before.value = new_dict["delay before"]
	delay_after.value = new_dict["delay after"]
	load_sound_dict(new_dict["sound dict"])


func set_sound_dict(key: String, new_value) -> void:
	var sound_dict = move_dict["sound dict"]
	if sound_dict.has(key):
		sound_dict[key] = new_value
	else:
		print("Key does not exist.")


func load_sound_dict(new_dict: Dictionary) -> void:
	move_dict["sound dict"] = new_dict.duplicate()
	play_sound.button_pressed = new_dict["play sound"]
	play_sound.toggled.emit(play_sound.button_pressed)
	sound_path.text = new_dict["sound path"]
	new_track.button_pressed = new_dict["new track"]


func _on_new_pos_x_value_changed(value):
	set_move_dict("new pos x", value)
	if control_picture.button_pressed:
		pic_node.ExamplePictureContainer.global_position.x = value


func _on_new_pos_y_value_changed(value):
	set_move_dict("new pos y", value)
	if control_picture.button_pressed:
		pic_node.ExamplePictureContainer.global_position.y = value


func _on_control_picture_toggled(button_pressed):
	if button_pressed:
		if pic_node.move_controller != null:
			pic_node.move_controller.control_picture.button_pressed = false
		
		pic_node.move_controller = self
	else:
		pic_node.move_controller = null


func _on_move_type_options_item_selected(index):
	set_move_dict("move type", index)
	
	if index == 3:
		new_pos_x.editable = false
		new_pos_y.editable = false
	else:
		new_pos_x.editable = true
		new_pos_y.editable = true


func _on_position_offset_changed():
	if get_parent() != null:
		get_parent().position_offset_dict[get_name()]["x"] = position_offset.x
		get_parent().position_offset_dict[get_name()]["y"] = position_offset.y


func _on_clear_button_pressed():
	path_line_edit.text = ""
	path_line_edit.text_changed.emit(path_line_edit.text)
	preview_rect.texture = null
	preview_rect.reset_size()
	preview_rect.hide()
	reset_size()


func _on_open_button_pressed():
	$FileDialog.popup_centered()


func _on_path_line_edit_text_changed(new_text):
	set_move_dict("new path", new_text)


func _on_file_dialog_file_selected(path):
	path_line_edit.text = path
	path_line_edit.text_changed.emit(path_line_edit.text)
	preview_rect.texture = load(path)
	if preview_check.button_pressed:
		preview_rect.show()


func _on_delay_before_value_changed(value):
	set_move_dict("delay before", value)


func _on_delay_after_value_changed(value):
	set_move_dict("delay after", value)


func _on_preview_check_toggled(button_pressed):
	if button_pressed:
		if preview_rect.texture != null:
			preview_rect.show()
	else:
		preview_rect.hide()
		reset_size()


func _on_play_sound_toggled(button_pressed):
	set_sound_dict("play sound", button_pressed)
	
	if button_pressed:
		clear_sound.disabled = false
		open_sound.disabled = false
		new_track.disabled = false
		sfx_button.disabled = false
		play_button.disabled = false
		stop_button.disabled = false
		
	else:
		clear_sound.disabled = true
		open_sound.disabled = true
		new_track.disabled = true
		sfx_button.disabled = true
		play_button.disabled = true
		stop_button.disabled = true


func _on_clear_sound_pressed():
	set_sound_dict("sound path", "")
	sound_path.clear()


func _on_new_track_toggled(button_pressed):
	set_sound_dict("new track", button_pressed)
	sfx_button.button_pressed = not button_pressed


func _on_open_sound_pressed():
	$SoundFileDialog.popup_centered()


func _on_sound_file_dialog_file_selected(path):
	set_sound_dict("sound path", path)
	sound_path.text = path


func _on_play_button_pressed():
	if sound_path.text != "":
		test_player.stream = load(sound_path.text)
		test_player.play()


func _on_stop_button_pressed():
	if test_player.playing:
		test_player.stop()


func _on_sfx_button_toggled(button_pressed):
	new_track.button_pressed = not button_pressed
