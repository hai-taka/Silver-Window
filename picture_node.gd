extends GraphNode

signal position_changed(new_position : Vector2)

@export var first_pic_presets: Resource

var start_connected: bool = false
var start_node: GraphNode = null:
	set(value):
		if (
				value != null
				and not value.HeadCheck.toggled.is_connected(_on_start_node_head_check_toggled)
		):
			value.HeadCheck.toggled.connect(_on_start_node_head_check_toggled)
		elif value == null:
			start_node.HeadCheck.toggled.disconnect(_on_start_node_head_check_toggled)
		
		start_node = value
		if start_node != null and start_node == get_parent().head:
			%FirstPicVBox.show()
			$VBoxContainer/HSeparator4.show()
		else:
			%FirstPicVBox.hide()
			%TopLine.clear()
			%TopLine2.clear()
			%BottLine.clear()
			%BottLine2.clear()
			$VBoxContainer/HSeparator4.hide()
			reset_size()

var end_connected: bool = false
var end_node: GraphNode = null
var move_connected: bool = false
var move_controller: GraphNode = null:
	set(value):
		move_controller = value
		if move_controller != null:
			move_controller.new_pos_x.value = PosXSpinBox.value
			move_controller.new_pos_y.value = PosYSpinBox.value
		else:
			ExamplePictureContainer.global_position = Vector2(PosXSpinBox.value, PosYSpinBox.value)

var first_pic_dict = {
	"top 1": "",
	"top 2": "",
	"bott 1": "",
	"bott 2": "",
	"color": Color.WHITE.to_html(),
}
var sound_dict = {
	"play sound": false,
	"await sound": true,
	"new track": false,
	"sound path": "",
}

@onready var editor = get_parent()
@onready var test_player: AudioStreamPlayer = editor.test_player
@onready var play_button = %PlayButton
@onready var stop_button = %StopButton

@onready var PicturePath = $VBoxContainer/HBoxContainer2/PicturePath
@onready var PreviewRect = $VBoxContainer/PreviewRect
@onready var PreviewButton = $VBoxContainer/CenterContainer2/HBoxContainer/PreviewButton
@onready var SizeXSpinBox = $VBoxContainer/HBoxContainer3/SizeXSpinBox
@onready var SizeYSpinBox = $VBoxContainer/HBoxContainer3/SizeYSpinBox
@onready var PosXSpinBox = $VBoxContainer/HBoxContainer/PosXSpinBox
@onready var PosYSpinBox = $VBoxContainer/HBoxContainer/PosYSpinBox
@onready var CenterXCheck = $VBoxContainer/HBoxContainer/CenterXCheck
@onready var CenterYCheck = $VBoxContainer/HBoxContainer/CenterYCheck
@onready var ClearButton = $VBoxContainer/CenterContainer2/HBoxContainer/ClearButton
@onready var FadeInDuration = $VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInDuration
@onready var FadeInColor = $VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInColor
@onready var FadeInSolid = $VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInSolid
@onready var FadeOutDuration = $VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutDuration
@onready var FadeOutColor = $VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutColor
@onready var FadeOutSolid = $VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutSolid
@onready var await_sound = %AwaitSound
@onready var open_sound = %OpenSound
@onready var sound_path = %SoundPath
@onready var clear_sound = %ClearSound
@onready var play_sound = %PlaySound
@onready var new_track = %NewTrack
@onready var sfx_button = %SFXButton

@onready var ExamplePictureWindow = $ExamplePictureWindow
@onready var ExamplePictureContainer = $ExamplePictureWindow/PictureContainer
@onready var ExamplePictureRect = $ExamplePictureWindow/PictureContainer/PictureRect
@onready var example_border_width_left = $ExamplePictureWindow/PictureContainer.get_theme_stylebox("panel").border_width_left
@onready var example_border_width_top = $ExamplePictureWindow/PictureContainer.get_theme_stylebox("panel").border_width_top
@onready var example_border_width_right = $ExamplePictureWindow/PictureContainer.get_theme_stylebox("panel").border_width_right
@onready var example_border_width_bottom = $ExamplePictureWindow/PictureContainer.get_theme_stylebox("panel").border_width_bottom


func _ready():
	remove_child($ExamplePictureWindow)
	$"..".add_child(ExamplePictureWindow)
	
	SizeXSpinBox.value = ExamplePictureContainer.size.x
	SizeYSpinBox.value = ExamplePictureContainer.size.y
	PosXSpinBox.value = ExamplePictureContainer.global_position.x
	PosYSpinBox.value = ExamplePictureContainer.global_position.y
	
	for key in first_pic_presets.get_dict():
		%ColorPresets.add_item(key)


func load_first_pic_dict(new_dict: Dictionary) -> void:
	first_pic_dict = new_dict.duplicate()
	%TopLine.text = new_dict["top 1"]
	%TopLine.text_changed.emit(%TopLine.text)
	%TopLine2.text = new_dict["top 2"]
	%BottLine.text = new_dict["bott 1"]
	%BottLine.text_changed.emit(%BottLine.text)
	%BottLine2.text = new_dict["bott 2"]
	%ColorButton.color = new_dict["color"]


func set_dict(dict: Dictionary, key: String, new_value) -> void:
	if dict.has(key):
		dict[key] = new_value
	else:
		print("Key does not exist within dictionary.")


func load_sound_dict(new_dict: Dictionary) -> void:
	sound_dict = new_dict.duplicate()
	play_sound.button_pressed = new_dict["play sound"]
	play_sound.toggled.emit(play_sound.button_pressed)
	await_sound.button_pressed = new_dict["await sound"]
	sound_path.text = new_dict["sound path"]
	new_track.button_pressed = new_dict["new track"]


func _on_close_request():
	if start_connected or end_connected or move_connected:
		$"../CloseConnectedWarning".popup_centered()
		return
	
	get_parent().position_offset_dict.erase(get_name())
	get_parent().picture_node_index -= 1
	get_parent().global_node_count -= 1
	queue_free()
	ExamplePictureWindow.queue_free()


func _on_resize_request(new_minsize):
	size = new_minsize


func _on_open_button_pressed():
	$FileDialog.popup_centered()


func _on_file_dialog_file_selected(path):
	ClearButton.pressed.emit()
	ExamplePictureRect.custom_minimum_size = Vector2(0, 0)
	
	PicturePath.text = path
	
	if path != "":
		PreviewRect.texture = load(path)
	
	if PreviewButton.button_pressed:
		PreviewRect.show()
	
	reset_size()
	
	ExamplePictureRect.texture = PreviewRect.texture
	ExamplePictureContainer.reset_size()
	SizeXSpinBox.value = ExamplePictureContainer.size.x
	SizeYSpinBox.value = ExamplePictureContainer.size.y
	
	CenterXCheck.toggled.emit(CenterXCheck.button_pressed)
	CenterYCheck.toggled.emit(CenterYCheck.button_pressed)


func _on_show_example_box_toggled(button_pressed):
	if button_pressed:
		ExamplePictureWindow.show()
	else:
		ExamplePictureWindow.hide()


func _on_preview_button_toggled(button_pressed):
	if button_pressed and PicturePath.text != "":
		PreviewRect.show()
	else:
		PreviewRect.hide()
		reset_size()


func _on_clear_button_pressed():
	PicturePath.text = ""
	PreviewRect.texture = null
	PreviewRect.reset_size()
	PreviewRect.hide()
	reset_size()
	
	ExamplePictureRect.texture = null
	ExamplePictureRect.custom_minimum_size = Vector2(200, 200)
	ExamplePictureContainer.reset_size()
	
	SizeXSpinBox.value = ExamplePictureContainer.size.x
	SizeYSpinBox.value = ExamplePictureContainer.size.y
	
	CenterXCheck.toggled.emit(CenterXCheck.button_pressed)
	CenterYCheck.toggled.emit(CenterYCheck.button_pressed)


func _on_center_x_check_toggled(button_pressed):
	if button_pressed:
		var old_pos = ExamplePictureContainer.global_position
		
		ExamplePictureContainer.center_x = true
		PosXSpinBox.editable = false
		ExamplePictureContainer.global_position.x = (get_viewport().get_visible_rect().size.x - ExamplePictureContainer.size.x) / 2
		
		if ExamplePictureContainer.global_position != old_pos:
			position_changed.emit(ExamplePictureContainer.global_position)
	
	else:
		ExamplePictureContainer.center_x = false
		PosXSpinBox.editable = true


func _on_position_changed(new_position):
	PosXSpinBox.value = new_position.x
	PosYSpinBox.value = new_position.y


func _on_picture_container_dragged(new_position):
	if move_connected and move_controller != null:
		move_controller.new_pos_x.value = new_position.x
		move_controller.new_pos_y.value = new_position.y
	
	else:
		position_changed.emit(new_position)


func _on_pos_x_spin_box_value_changed(value):
	ExamplePictureContainer.global_position.x = value


func _on_pos_y_spin_box_value_changed(value):
	ExamplePictureContainer.global_position.y = value


func _on_margin_check_toggled(button_pressed):
	var graph_edit = get_parent()
	
	if button_pressed:
		graph_edit.left_margin_spin_box.value = PosXSpinBox.value
		graph_edit.right_margin_spin_box.value = get_viewport().get_visible_rect().size.x - PosXSpinBox.value - SizeXSpinBox.value
		graph_edit.align = true
		
	else:
		graph_edit.left_margin_spin_box.value = 20
		graph_edit.right_margin_spin_box.value = 20
		graph_edit.align = false


func _on_node_selected():
	if $VBoxContainer/HBoxContainer3/MarginCheck.button_pressed:
		$VBoxContainer/HBoxContainer3/MarginCheck.toggled.emit(true)


func _on_center_y_check_toggled(button_pressed):
	if button_pressed:
		var old_pos = ExamplePictureContainer.global_position
		
		ExamplePictureContainer.center_y = true
		PosYSpinBox.editable = false
		ExamplePictureContainer.global_position.y = (get_viewport().get_visible_rect().size.y - ExamplePictureContainer.size.y) / 2
		
		if ExamplePictureContainer.global_position != old_pos:
			position_changed.emit(ExamplePictureContainer.global_position)
	
	else:
		ExamplePictureContainer.center_y = false
		PosYSpinBox.editable = true


func _on_fade_in_check_toggled(button_pressed):
	if button_pressed:
		FadeInDuration.editable = true
		FadeInColor.disabled = false
		FadeInSolid.disabled = false
	
	else:
		FadeInDuration.editable = false
		FadeInColor.disabled = true
		FadeInSolid.disabled = true


func _on_fade_out_check_toggled(button_pressed):
	if button_pressed:
		FadeOutDuration.editable = true
		FadeOutColor.disabled = false
		FadeOutSolid.disabled = false
	
	else:
		FadeOutDuration.editable = false
		FadeOutColor.disabled = true
		FadeOutSolid.disabled = true


func _on_position_offset_changed():
	if get_parent() != null:
		get_parent().position_offset_dict[get_name()]["x"] = position_offset.x
		get_parent().position_offset_dict[get_name()]["y"] = position_offset.y


func _on_picture_container_resized():
	SizeXSpinBox.value = ExamplePictureContainer.size.x
	SizeYSpinBox.value = ExamplePictureContainer.size.y
	CenterXCheck.toggled.emit(CenterXCheck.button_pressed)
	CenterYCheck.toggled.emit(CenterYCheck.button_pressed)


func _on_start_node_head_check_toggled(button_pressed):
	if button_pressed:
		%FirstPicVBox.show()
		$VBoxContainer/HSeparator4.show()
	else:
		%FirstPicVBox.hide()
		%TopLine.clear()
		%TopLine2.clear()
		%BottLine.clear()
		%BottLine2.clear()
		$VBoxContainer/HSeparator4.hide()
		reset_size()


func _on_top_line_text_changed(new_text):
	first_pic_dict["top 1"] = new_text
	
	if new_text != "":
		%TopLine2.editable = true
	else:
		%TopLine2.clear()
		%TopLine2.editable = false


func _on_top_line_2_text_changed(new_text):
	first_pic_dict["top 2"] = new_text


func _on_bott_line_text_changed(new_text):
	first_pic_dict["bott 1"] = new_text
	
	if new_text != "":
		%BottLine2.editable = true
	else:
		%BottLine2.clear()
		%BottLine2.editable = false


func _on_bott_line_2_text_changed(new_text):
	first_pic_dict["bott 2"] = new_text


func _on_color_button_color_changed(color):
	%ColorPresets.selected = 0
	first_pic_dict["color"] = color.to_html()


func _on_save_button_pressed():
	%PresetLineEdit.clear()
	$PresetPopupPanel.popup_centered()
	%PresetLineEdit.grab_focus()


func _on_preset_line_edit_text_submitted(new_text):
	if not first_pic_presets.preset_exists(new_text):
		first_pic_presets.add_preset(new_text, %ColorButton.color)
		ResourceSaver.save(first_pic_presets, "res://resources/Data/first_pic_label_presets.tres")
		
		%ColorPresets.add_item(new_text)
		%ColorPresets.select(%ColorPresets.get_item_count() - 1)
		$PresetPopupPanel.hide()
	
	else:
		$AcceptDialog.popup_centered()


func _on_remove_button_pressed():
	var remove_index: int = %ColorPresets.get_selected()
	var remove_name: String = %ColorPresets.get_item_text(remove_index)
	
	if remove_index != 0:
		%ColorPresets.select(0)
		%ColorPresets.item_selected.emit(%ColorPresets.selected)
		%ColorPresets.remove_item(remove_index)
		
		first_pic_presets.remove_preset(remove_name)
		ResourceSaver.save(first_pic_presets, "res://resources/Data/first_pic_label_presets.tres")


func _on_color_presets_item_selected(index):
	if index == 0:
		%ColorButton.color = Color.WHITE
	else:
		var index_name: String = %ColorPresets.get_item_text(index)
		var preset_color: Color = first_pic_presets.get_color(index_name)
		
		%ColorButton.color = preset_color
		#%ColorButton.color_changed.emit(%ColorButton.color)
		first_pic_dict["color"] = preset_color.to_html()


func _on_play_sound_toggled(button_pressed):
	set_dict(sound_dict, "play sound", button_pressed)
	
	if button_pressed:
		clear_sound.disabled = false
		await_sound.disabled = false
		open_sound.disabled = false
		new_track.disabled = false
		sfx_button.disabled = false
		play_button.disabled = false
		stop_button.disabled = false
	else:
		clear_sound.disabled = true
		await_sound.disabled = true
		open_sound.disabled = true
		new_track.disabled = true
		sfx_button.disabled = true
		play_button.disabled = true
		stop_button.disabled = true


func _on_open_sound_pressed():
	$SoundFileDialog.popup_centered()


func _on_sound_file_dialog_file_selected(path):
	set_dict(sound_dict, "sound path", path)
	sound_path.text = path


func _on_clear_sound_pressed():
	set_dict(sound_dict, "sound path", "")
	sound_path.clear()
	#await_sound.button_pressed = false
	#await_sound.toggled.emit(await_sound.button_pressed)


func _on_await_sound_toggled(button_pressed):
	set_dict(sound_dict, "await sound", button_pressed)


func _on_new_track_toggled(button_pressed):
	set_dict(sound_dict, "new track", button_pressed)
	sfx_button.button_pressed = not button_pressed


func _on_stop_button_pressed():
	if test_player.playing:
		test_player.stop()


func _on_play_button_pressed():
	if sound_path.text != "":
		test_player.stream = load(sound_path.text)
		test_player.play()


func _on_sfx_button_toggled(button_pressed):
	new_track.button_pressed = not button_pressed
