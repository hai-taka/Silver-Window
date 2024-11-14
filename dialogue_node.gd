extends GraphNode

signal frame_preset_added(preset_name: String)
signal frame_preset_removed(preset_id: int)

signal text_preset_added(preset_name: String)
signal text_preset_removed(preset_id: int)

var margin_left
var char_size

var next: GraphNode = null
var prev: GraphNode = null
var picture_connected: bool = false
var move_connected: bool = false
var pics_to_move: Array = []
var transition_connected: bool = false
#var change_connected: bool = false
#var pics_to_change: Array = []

var sound_dict: Dictionary = {
	"change bgm": false,
	"sound path": "",
}

@onready var editor = get_parent()
@onready var test_player: AudioStreamPlayer = editor.test_player

@onready var PairedPreview = $VBoxContainer/TextureRect
@onready var PairedPreviewButton = $VBoxContainer/HBoxContainer2/CheckButton
@onready var OpenButton = $VBoxContainer/HBoxContainer/Button
@onready var ClearButton = $VBoxContainer/HBoxContainer2/ClearButton
@onready var PairedPath = $VBoxContainer/HBoxContainer/PairedPath
@onready var PairedPosX = $VBoxContainer/HBoxContainer/PairedPosX
@onready var PairedPosY = $VBoxContainer/HBoxContainer/PairedPosY
@onready var PairedAuto = $VBoxContainer/HBoxContainer2/PairedAuto
@onready var PairedAutoOptions = $VBoxContainer/HBoxContainer2/PairedAutoOptions
@onready var TWSpinBox = $VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/TextWidthSpinBox
@onready var AutoWidth = $VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/AutoWidth
@onready var DialogueTextEdit = $VBoxContainer/TextEdit
@onready var LinesBox = $VBoxContainer/MarginContainer3/HBoxContainer/LinesBox
@onready var AutoLines = $VBoxContainer/MarginContainer3/HBoxContainer/AutoLines
@onready var font = $VBoxContainer/TextEdit.get_theme_font("font")
@onready var font_size = $VBoxContainer/TextEdit.get_theme_font_size("font_size")
@onready var PosX = $VBoxContainer/MarginContainer2/HBoxContainer/PositionX
@onready var PosY = $VBoxContainer/MarginContainer2/HBoxContainer/PositionY
@onready var WipeButton = $VBoxContainer/MarginContainer3/HBoxContainer/HBoxContainer/WipeButton
@onready var NewBoxCheck = $VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck
@onready var BoxSizeX = $VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/BoxSizeX
@onready var BoxSizeY = $VBoxContainer/MarginContainer2/HBoxContainer/HBoxContainer/BoxSizeY
@onready var CenterX = $VBoxContainer/HBoxContainer6/CenterX
@onready var CenterY = $VBoxContainer/HBoxContainer6/CenterY

@onready var ExampleControl = $Control
@onready var ExampleWindow = $Control/ExampleWindow
@onready var ExampleMargin = $Control/ExampleWindow/MarginContainer
@onready var ExampleText = $Control/ExampleWindow/MarginContainer/ExampleText
@onready var ExamplePaired = $Control/ExamplePaired
@onready var ExamplePairedTexRec = $Control/ExamplePaired/TextureRect
@onready var example_font = $Control/ExampleWindow/MarginContainer/ExampleText.get_theme_font("normal_font")
@onready var example_font_size = $Control/ExampleWindow/MarginContainer/ExampleText.get_theme_font_size("normal_font_size")

@onready var ShowFrame = $VBoxContainer/HBoxContainer4/HBoxContainer/ShowFrame
@onready var FramePosX = $VBoxContainer/HBoxContainer4/FramePosX
@onready var FramePosY = $VBoxContainer/HBoxContainer4/FramePosY
@onready var FrameSizeX = $VBoxContainer/HBoxContainer5/FrameSizeX
@onready var FrameSizeY = $VBoxContainer/HBoxContainer5/FrameSizeY
@onready var SavePreset = $VBoxContainer/HBoxContainer5/HBoxContainer/SavePreset
@onready var RemovePreset = $VBoxContainer/HBoxContainer5/HBoxContainer/RemovePreset
@onready var FramePresets = $VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets
@onready var SpeakerOptions = $VBoxContainer/HBoxContainer3/SpeakerOptions
@onready var SpeakerName = $VBoxContainer/HBoxContainer3/LineEdit

@onready var IncludeSize = $VBoxContainer/HBoxContainer8/IncludeSize
@onready var SaveTextPreset = $VBoxContainer/HBoxContainer8/SaveTextPreset
@onready var RemoveTextPreset = $VBoxContainer/HBoxContainer8/RemoveTextPreset
@onready var TextPresets = $VBoxContainer/HBoxContainer8/TextPresets

@onready var ExampleName = $Control/ExampleName
@onready var ExampleFrame = $Control/ExampleFrame
@onready var ShowExampleBox = $VBoxContainer/CenterContainer/ShowExampleBox
@onready var HeadCheck = $VBoxContainer/HBoxContainer7/HeadCheck

@onready var change_bgm = %ChangeBGM
@onready var clear_sound = %ClearSound
@onready var play_button = %PlayButton
@onready var stop_button = %StopButton
@onready var open_sound = %OpenSound
@onready var sound_path = %SoundPath


func _ready():
	remove_child($Control)
	$"..".add_child(ExampleControl)
	
	ExampleWindow.global_position = Vector2(PosX.value, PosY.value)
	ExampleText.text = DialogueTextEdit.text
	ExampleText.custom_minimum_size.x = TWSpinBox.value
	char_size = example_font.get_char_size("A".to_utf8_buffer()[0], example_font_size)
	margin_left = ExampleMargin.get_theme_constant("margin_left")
	ExampleMargin.add_theme_constant_override("margin_right", margin_left + char_size.x + 9)
	ExampleWindow.reset_size()
	
	BoxSizeX.value = ExampleWindow.size.x
	BoxSizeY.value = ExampleWindow.size.y
	
	FramePosX.value = ExampleFrame.global_position.x
	FramePosY.value = ExampleFrame.global_position.y
	FrameSizeX.value = ExampleFrame.size.x
	FrameSizeY.value = ExampleFrame.size.y
	
	ExampleName.position = ExampleFrame.position - Vector2(0, ExampleName.size.y)
	
	for key in $"..".frame_preset_dict:
		FramePresets.add_item(key, $"..".frame_preset_dict[key]["id"])
	
	for key in $"..".text_preset_dict:
		TextPresets.add_item(key, $"..".text_preset_dict[key]["id"])


func set_sound_dict(key: String, new_value) -> void:
	if sound_dict.has(key):
		sound_dict[key] = new_value
	else:
		print("Key does not exist.")


func load_sound_dict(new_dict: Dictionary) -> void:
	sound_dict = new_dict.duplicate()
	change_bgm.button_pressed = new_dict["change bgm"]
	sound_path.text = new_dict["sound path"]


func _on_close_request():
	if prev != null or next != null or picture_connected or move_connected:
		$"../CloseConnectedWarning".popup_centered()
		return
	
	if HeadCheck.button_pressed:
		HeadCheck.button_pressed = false
	
	get_parent().position_offset_dict.erase(get_name())
	get_parent().dialogue_node_index -= 1
	get_parent().global_node_count -= 1
	queue_free()
	ExampleControl.queue_free()


func _on_resize_request(new_minsize):
	size = new_minsize


func _on_text_edit_text_changed():
	var old_bottom_right_pos = ExampleWindow.global_position + ExampleWindow.size
	
	ExampleText.text = DialogueTextEdit.text
	
	if AutoLines.button_pressed:
		LinesBox.value = DialogueTextEdit.get_line_count()
	
	if AutoWidth.button_pressed:
		TWSpinBox.value = example_font.get_multiline_string_size(ExampleText.text, HORIZONTAL_ALIGNMENT_LEFT, -1, example_font_size, -1, 3).x
	
	if PairedAuto.button_pressed and PairedPath.text != "":
		# Left
		if PairedAutoOptions.selected == 0:
			PosY.value = old_bottom_right_pos.y - ExampleWindow.size.y
		
		# Right
		elif PairedAutoOptions.selected == 1:
			PosX.value = old_bottom_right_pos.x - ExampleWindow.size.x
			PosY.value = old_bottom_right_pos.y - ExampleWindow.size.y
		
		# Top right
		elif PairedAutoOptions.selected == 3:
			PosX.value = old_bottom_right_pos.x - ExampleWindow.size.x
	
	PairedAuto.toggled.emit(PairedAuto.button_pressed)
	
	if (not transition_connected 
			and next != null 
			and NewBoxCheck.button_pressed 
			and not next.NewBoxCheck.button_pressed):
		
		next.NewBoxCheck.toggled.emit(next.NewBoxCheck.button_pressed)
	
	if not NewBoxCheck.button_pressed:
		NewBoxCheck.toggled.emit(NewBoxCheck.button_pressed)


func _on_show_example_box_toggled(button_pressed):
	if button_pressed:
		ExampleControl.show()
		
		PairedAuto.toggled.emit(PairedAuto.button_pressed)
		
	else:
		ExampleControl.hide()


func _on_button_pressed():
	$FileDialog.popup_centered()


func _on_file_dialog_file_selected(path):
	$VBoxContainer/HBoxContainer2/ClearButton.pressed.emit()
	
	PairedPath.text = path
	PairedPreview.texture = load(path)
	
	if PairedPreviewButton.button_pressed:
		PairedPreview.show()
	
	reset_size()
	
	ExamplePairedTexRec.texture = PairedPreview.texture
	ExamplePaired.reset_size()
	
	if PairedAuto.button_pressed:
		ExampleWindow.auto_paired = true
	
	PairedAuto.toggled.emit(PairedAuto.button_pressed)
	CenterX.toggled.emit(CenterX.button_pressed)
	
	ExamplePaired.show()
	
	ShowFrame.button_pressed = false
	ShowFrame.disabled = true


func _on_check_button_toggled(button_pressed):
	if button_pressed and PairedPath.text != "":
		PairedPreview.show()
	
	else:
		PairedPreview.hide()
		reset_size()


func _on_example_window_dragged(new_position):
	PosX.value = new_position.x
	PosY.value = new_position.y
	
	ExampleWindow.position_changed.emit(new_position)


func _on_position_x_value_changed(value):
	ExampleWindow.global_position.x = value
	
	ExampleWindow.position_changed.emit(Vector2(value, ExampleWindow.global_position.y))


func _on_position_y_value_changed(value):
	ExampleWindow.global_position.y = value
	
	ExampleWindow.position_changed.emit(Vector2(ExampleWindow.global_position.x, value))


func _on_text_width_spin_box_value_changed(value):
	ExampleText.custom_minimum_size.x = value
	ExampleWindow.reset_size()
	
	CenterX.toggled.emit(CenterX.button_pressed)
	
	if PairedAuto.button_pressed:
		PairedAuto.toggled.emit(PairedAuto.button_pressed)


func _on_auto_width_toggled(button_pressed):
	if button_pressed:
		TWSpinBox.editable = false
		TWSpinBox.value = example_font.get_multiline_string_size($VBoxContainer/TextEdit.text, HORIZONTAL_ALIGNMENT_LEFT, -1, example_font_size, -1, 3).x
	
	else:
		TWSpinBox.editable = true


func _on_clear_button_pressed():
	PairedPath.text = ""
	PairedPreview.texture = null
	PairedPreview.reset_size()
	PairedPreview.hide()
	reset_size()
	
	PairedAuto.button_pressed = true
	
	ExamplePairedTexRec.texture = null
	ExamplePaired.reset_size()
	ExamplePaired.hide()
	
	ExampleWindow.auto_paired = false
	ShowFrame.disabled = false
	
	CenterX.toggled.emit(CenterX.button_pressed)


func _on_example_paired_dragged(new_position):
	PairedPosX.value = new_position.x
	PairedPosY.value = new_position.y


func _on_paired_auto_toggled(button_pressed):
	if PairedPath.text != "":
		if button_pressed:
			ExamplePaired.draggable = false
			PairedPosX.editable = false
			PairedPosY.editable = false
			PairedAutoOptions.disabled = false
			PairedAutoOptions.item_selected.emit(PairedAutoOptions.selected)
			ExampleWindow.auto_paired = true
		
		else:
			ExamplePaired.draggable = true
			PairedPosX.editable = true
			PairedPosY.editable = true
			PairedAutoOptions.disabled = true
			ExampleWindow.auto_paired = false
		
		CenterX.toggled.emit(CenterX.button_pressed)
		CenterY.toggled.emit(CenterY.button_pressed)
	
	else:
		if button_pressed:
			PairedAutoOptions.disabled = false
			PairedPosX.editable = false
			PairedPosY.editable = false
		
		else:
			PairedAutoOptions.disabled = true
			PairedPosX.editable = true
			PairedPosY.editable = true


func _on_paired_pos_x_value_changed(value):
	ExamplePaired.global_position.x = value


func _on_paired_pos_y_value_changed(value):
	ExamplePaired.global_position.y = value


func _on_example_window_position_changed(_new_position):
	if PairedAuto.button_pressed and PairedPath.text != "":
		PairedAuto.toggled.emit(PairedAuto.button_pressed)


func _on_auto_lines_toggled(button_pressed):
	if button_pressed:
		LinesBox.editable = false
		LinesBox.value = DialogueTextEdit.get_line_count()
	
	else:
		LinesBox.editable = true


func _on_lines_box_value_changed(value):
	ExampleText.custom_minimum_size.y = value * (example_font.get_height(example_font_size) + ExampleWindow.get_theme_constant("line_separation", "RichTextLabel"))
	ExampleWindow.reset_size()
	
	CenterY.toggled.emit(CenterY.button_pressed)
	
	if PairedAuto.button_pressed:
		PairedAuto.toggled.emit(PairedAuto.button_pressed)


func _on_new_box_check_toggled(button_pressed):
	var before_bottom_right_pos: Vector2
	var current_node = prev
	
	while current_node.NewBoxCheck.button_pressed == false:
		current_node = current_node.prev
	
	var old_box_node = current_node
	
	if button_pressed:
		WipeButton.button_pressed = true
		WipeButton.disabled = true
		SpeakerName.editable = true
		SpeakerOptions.disabled = false
		ShowFrame.disabled = false
		SavePreset.disabled = false
		RemovePreset.disabled = false
		FramePresets.disabled = false
		PairedPreviewButton.disabled = false
		PairedAuto.disabled = false
		PairedAutoOptions.disabled = false
		CenterX.disabled = false
		CenterY.disabled = false
		IncludeSize.disabled = false
		SaveTextPreset.disabled = false
		RemoveTextPreset.disabled = false
		TextPresets.disabled = false
		AutoLines.disabled = false
		AutoWidth.disabled = false
		ShowExampleBox.disabled = false
		OpenButton.disabled = false
		ClearButton.disabled = false
		PosX.editable = true
		PosY.editable = true
		change_bgm.disabled = false
		
		if (
				next != null 
				and not transition_connected 
				and not next.NewBoxCheck.button_pressed
		):
			
			next.NewBoxCheck.toggled.emit(next.NewBoxCheck.button_pressed)
	
	# Reuse old text box, just update text.
	else:
		ClearButton.pressed.emit()
		WipeButton.disabled = false
		SpeakerName.text = ""
		SpeakerName.editable = false
		SpeakerOptions.disabled = true
		ShowFrame.button_pressed = false
		ShowFrame.disabled = true
		SavePreset.disabled = true
		RemovePreset.disabled = true
		FramePresets.disabled = true
		PairedPreviewButton.disabled = true
		PairedAuto.disabled = true
		CenterX.disabled = true
		CenterY.disabled = true
		IncludeSize.disabled = true
		SaveTextPreset.disabled = true
		RemoveTextPreset.disabled = true
		TextPresets.disabled = true
		AutoLines.button_pressed = true
		AutoLines.disabled = true
		AutoWidth.button_pressed = true
		AutoWidth.disabled = true
		ShowExampleBox.button_pressed = false
		ShowExampleBox.disabled = true
		OpenButton.disabled = true
		ClearButton.disabled = true
		PosX.editable = false
		PosY.editable = false
		PairedAutoOptions.disabled = true
		change_bgm.button_pressed = false
		change_bgm.disabled = true
	
	before_bottom_right_pos = Vector2(old_box_node.PosX.value, old_box_node.PosY.value) + Vector2(old_box_node.BoxSizeX.value, old_box_node.BoxSizeY.value)
	
	old_box_node.AutoWidth.button_pressed = true
	old_box_node.AutoWidth.disabled = false
	old_box_node.AutoLines.button_pressed = true
	old_box_node.AutoLines.disabled = false
	
	current_node = old_box_node.next
	var available_lines: int = 0
	
	while (
			current_node != null 
			and get_tree().get_nodes_in_group("dialogue_nodes").has(current_node) 
			and not current_node.NewBoxCheck.button_pressed
	):
		#print("available lines before: " + str(available_lines))
		if current_node.TWSpinBox.value > old_box_node.TWSpinBox.value:
			old_box_node.TWSpinBox.value = current_node.TWSpinBox.value
			old_box_node.AutoWidth.button_pressed = false
			old_box_node.AutoWidth.disabled = true
			old_box_node.TWSpinBox.editable = false
		
		if not current_node.WipeButton.button_pressed:
			if available_lines < current_node.LinesBox.value:
				old_box_node.LinesBox.value += current_node.LinesBox.value - available_lines
				available_lines = 0
				old_box_node.AutoLines.button_pressed = false
				old_box_node.AutoLines.disabled = true
				old_box_node.LinesBox.editable = false
			else:
				available_lines -= current_node.LinesBox.value
		
		else:
			if current_node.LinesBox.value > old_box_node.LinesBox.value:
				old_box_node.LinesBox.value = current_node.LinesBox.value
				old_box_node.AutoLines.button_pressed = false
				old_box_node.AutoLines.disabled = true
				old_box_node.LinesBox.editable = false
			else:
				available_lines = old_box_node.LinesBox.value - current_node.LinesBox.value
		#print("available lines after: " + str(available_lines))
		current_node = current_node.next
	
	if old_box_node.PairedAuto.button_pressed and old_box_node.PairedPath.text != "":
		# Left
		if old_box_node.PairedAutoOptions.selected == 0:
			old_box_node.PosY.value = before_bottom_right_pos.y - old_box_node.BoxSizeY.value
		
		# Right
		elif old_box_node.PairedAutoOptions.selected == 1:
			old_box_node.PosX.value = before_bottom_right_pos.x - old_box_node.BoxSizeX.value
			old_box_node.PosY.value = before_bottom_right_pos.y - old_box_node.BoxSizeY.value
		
		# Top right
		elif old_box_node.PairedAutoOptions.selected == 3:
			old_box_node.PosX.value = before_bottom_right_pos.x - old_box_node.BoxSizeX.value


func _on_paired_auto_options_item_selected(index):
	ExampleWindow.auto_type = index
	
	if index == 0: # Left
		PairedPosX.value = PosX.value - ExampleWindow.paired_offset.x - ExamplePaired.size.x
		PairedPosY.value = PosY.value + ExampleWindow.size.y - ExamplePaired.size.y
	elif index == 1: # Right
		PairedPosX.value = PosX.value + ExampleWindow.size.x + ExampleWindow.paired_offset.x
		PairedPosY.value = PosY.value + ExampleWindow.size.y - ExamplePaired.size.y
	elif index == 2: # Top left
		PairedPosX.value = PosX.value
		PairedPosY.value = PosY.value - ExampleWindow.paired_offset.y - ExamplePaired.size.y
	elif index == 3: # Top right
		PairedPosX.value = PosX.value + ExampleWindow.size.x - ExamplePaired.size.x
		PairedPosY.value = PosY.value - ExampleWindow.paired_offset.y - ExamplePaired.size.y
	
	CenterX.toggled.emit(CenterX.button_pressed)
	CenterY.toggled.emit(CenterY.button_pressed)
	
	if TextPresets.selected != 0:
		TextPresets.item_selected.emit(TextPresets.selected)


func _on_example_window_resized():
	BoxSizeX.value = ExampleWindow.size.x
	BoxSizeY.value = ExampleWindow.size.y
	CenterX.toggled.emit(CenterX.button_pressed)
	CenterY.toggled.emit(CenterY.button_pressed)
	
	ExampleWindow.dragged.emit(ExampleWindow.global_position)


func _on_show_frame_toggled(button_pressed):
	if FramePresets.selected == 0:
		if button_pressed:
			ExampleFrame.show()
			ExampleName.show()
			FramePosX.editable = true
			FramePosY.editable = true
			FrameSizeX.editable = true
			FrameSizeY.editable = true
		else:
			ExampleFrame.hide()
			ExampleName.hide()
			FramePosX.editable = false
			FramePosY.editable = false
			FrameSizeX.editable = false
			FrameSizeY.editable = false
	else:
		if button_pressed:
			ExampleFrame.show()
			ExampleName.show()
		else:
			ExampleFrame.hide()
			ExampleName.hide()


func _on_line_edit_text_changed(new_text):
	#print("changed")
	ExampleName.text = new_text
	ExampleName.reset_size()
	
	ExampleFrame.transform_changed.emit()


func _on_example_frame_dragged(new_position):
	FramePosX.value = new_position.x
	FramePosY.value = new_position.y
	
	ExampleFrame.transform_changed.emit()


func _on_speaker_options_item_selected(_index):
	ExampleFrame.transform_changed.emit()


func _on_frame_pos_x_value_changed(value):
	ExampleFrame.position.x = value
	
	ExampleFrame.transform_changed.emit()


func _on_frame_pos_y_value_changed(value):
	ExampleFrame.position.y = value
	
	ExampleFrame.transform_changed.emit()


func _on_frame_size_x_value_changed(value):
	ExampleFrame.size.x = value
	
	ExampleFrame.transform_changed.emit()


func _on_frame_size_y_value_changed(value):
	ExampleFrame.size.y = value
	
	ExampleFrame.transform_changed.emit()


func _on_example_frame_transform_changed():
	if SpeakerOptions.selected == 0:
		ExampleName.position = ExampleFrame.position - Vector2(0, ExampleName.size.y)
	elif SpeakerOptions.selected == 1:
		ExampleName.position = ExampleFrame.position + Vector2(0, ExampleFrame.size.y)
	elif SpeakerOptions.selected == 2:
		ExampleName.position = ExampleFrame.position + Vector2(-(ExampleName.size.x + 10), (ExampleFrame.size.y / 2) - (ExampleName.size.y / 2))
	elif SpeakerOptions.selected == 3:
		ExampleName.position = ExampleFrame.position + Vector2(ExampleFrame.size.x + 10, (ExampleFrame.size.y / 2) - (ExampleName.size.y / 2))


func _on_save_preset_pressed():
	$PopupPanel/LineEdit.clear()
	$PopupPanel.popup_centered()
	$PopupPanel/LineEdit.grab_focus()


func _on_line_edit_text_submitted(new_text):
	if $"..".frame_preset_dict.has(new_text):
		$"../DuplicatePresetWarning".popup_centered()
		return
	
	if ShowFrame.button_pressed:
		$"..".frame_preset_dict[new_text] = {
			"name": SpeakerName.text,
			"speaker option": SpeakerOptions.selected,
			"id": $"..".frame_preset_id,
			"pos x": FramePosX.value,
			"pos y": FramePosY.value,
			"size x": FrameSizeX.value,
			"size y": FrameSizeY.value
		}
	elif PairedPath.text != "":
		$"..".frame_preset_dict[new_text] = {
			"name": SpeakerName.text,
			"speaker option": SpeakerOptions.selected,
			"id": $"..".frame_preset_id,
			"paired path": PairedPath.text,
			"paired auto": PairedAuto.button_pressed
		}
		if PairedAuto.button_pressed:
			$"..".frame_preset_dict[new_text]["auto option"] = PairedAutoOptions.selected
		else:
			$"..".frame_preset_dict[new_text]["paired pos x"] = PairedPosX.value
			$"..".frame_preset_dict[new_text]["paired pos y"] = PairedPosY.value
	
	else:
		$"../NoFrameNoPortrait".popup_centered()
		return
	
	FramePresets.add_item(new_text, $"..".frame_preset_id)
	FramePresets.select(FramePresets.get_item_index($"..".frame_preset_id))
	FramePresets.item_selected.emit(FramePresets.get_selected())
	$"..".frame_preset_id += 1
	
	$PopupPanel.hide()
	frame_preset_added.emit(new_text)


func _on_remove_preset_pressed():
	if FramePresets.selected != 0:
		var removed_id = FramePresets.get_item_id(FramePresets.get_selected())
		
		$"..".frame_preset_dict.erase(FramePresets.get_item_text(FramePresets.get_selected()))
		FramePresets.remove_item(FramePresets.get_selected())
		FramePresets.select(0)
		FramePresets.item_selected.emit(0)
		
		frame_preset_removed.emit(removed_id)


func _on_frame_presets_item_selected(index):
	if index != 0:
		SpeakerName.text = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["name"]
		SpeakerName.text_changed.emit(SpeakerName.text)
		SpeakerOptions.selected = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["speaker option"]
		
		SpeakerName.editable = false
		SpeakerOptions.disabled = true
		
		# Preset for frame
		if $"..".frame_preset_dict[FramePresets.get_item_text(index)].has("pos x"):
			FramePosX.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["pos x"]
			FramePosY.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["pos y"]
			FrameSizeX.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["size x"]
			FrameSizeY.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["size y"]
			
			$VBoxContainer/HBoxContainer2/ClearButton.pressed.emit()
			ShowFrame.button_pressed = true
		
		# Preset for paired image
		else:
			$FileDialog.file_selected.emit($"..".frame_preset_dict[FramePresets.get_item_text(index)]["paired path"])
			PairedAuto.button_pressed = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["paired auto"]
			OpenButton.disabled = true
			
			if $"..".frame_preset_dict[FramePresets.get_item_text(index)].has("auto option"):
				PairedAutoOptions.selected = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["auto option"]
				PairedAutoOptions.item_selected.emit(PairedAutoOptions.selected)
			
			else:
				PairedPosX.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["paired pos x"]
				PairedPosY.value = $"..".frame_preset_dict[FramePresets.get_item_text(index)]["paired pos y"]
	
	else:
		SpeakerName.editable = true
		SpeakerOptions.disabled = false
		OpenButton.disabled = false
		
		SpeakerName.text = ""
		$VBoxContainer/HBoxContainer2/ClearButton.pressed.emit()


func _on_center_x_toggled(button_pressed):
	if button_pressed:
		var old_pos = ExampleWindow.global_position
		
		ExampleWindow.center_x = true
		PosX.editable = false
		
		if PairedPath.text == "":
			ExampleWindow.global_position.x = (get_viewport().get_visible_rect().size.x - ExampleWindow.size.x) / 2
		
		elif PairedAuto.button_pressed == false:
			ExampleWindow.global_position.x = (get_viewport().get_visible_rect().size.x - ExampleWindow.size.x) / 2
		
		elif PairedAutoOptions.selected == 0:
			ExampleWindow.global_position.x = (get_viewport().get_visible_rect().size.x - (ExampleWindow.size.x + ExampleWindow.paired_offset.x + ExamplePaired.size.x)) / 2 + ExamplePaired.size.x + ExampleWindow.paired_offset.x
		
		elif PairedAutoOptions.selected == 1:
			ExampleWindow.global_position.x = (get_viewport().get_visible_rect().size.x - (ExampleWindow.size.x + ExampleWindow.paired_offset.x + ExamplePaired.size.x)) / 2
		
		else:
			ExampleWindow.global_position.x = (get_viewport().get_visible_rect().size.x - ExampleWindow.size.x) / 2
		
		if ExampleWindow.global_position != old_pos:
			ExampleWindow.dragged.emit(ExampleWindow.global_position)
	
	else:
		ExampleWindow.center_x = false
		PosX.editable = true


func _on_head_check_toggled(button_pressed):
	if button_pressed:
		get_parent().head = self
	else:
		get_parent().head = null
	
	get_parent().head_changed.emit()


func _on_save_text_preset_pressed():
	$TextPresetPopup/TextPresetLineEdit.clear()
	$TextPresetPopup.popup_centered()
	$TextPresetPopup/TextPresetLineEdit.grab_focus()


func _on_remove_text_preset_pressed():
	if TextPresets.selected != 0:
		var removed_id = TextPresets.get_item_id(TextPresets.get_selected())
		
		$"..".text_preset_dict.erase(TextPresets.get_item_text(TextPresets.get_selected()))
		TextPresets.remove_item(TextPresets.get_selected())
		TextPresets.select(0)
		TextPresets.item_selected.emit(0)
		
		text_preset_removed.emit(removed_id)


func _on_text_presets_item_selected(index):
	if index != 0:
		var preset_pos_x = $"..".text_preset_dict[TextPresets.get_item_text(index)]["pos x"]
		var preset_pos_y = $"..".text_preset_dict[TextPresets.get_item_text(index)]["pos y"]
		var preset_size_x = $"..".text_preset_dict[TextPresets.get_item_text(index)]["size x"]
		var preset_size_y = $"..".text_preset_dict[TextPresets.get_item_text(index)]["size y"]
		var preset_bottom_right_pos = Vector2(preset_pos_x, preset_pos_y) + Vector2(preset_size_x, preset_size_y)
		
		if PairedAuto.button_pressed and PairedPath.text != "":
			# Left
			if PairedAutoOptions.selected == 0:
				PosX.value = preset_pos_x
				PosY.value = preset_bottom_right_pos.y - ExampleWindow.size.y
			
			# Right
			elif PairedAutoOptions.selected == 1:
				PosX.value = preset_bottom_right_pos.x - ExampleWindow.size.x
				PosY.value = preset_bottom_right_pos.y - ExampleWindow.size.y
			
			# Top left
			elif PairedAutoOptions.selected == 2:
				PosX.value = preset_pos_x
				PosY.value = preset_pos_y
			
			# Top right
			elif PairedAutoOptions.selected == 3:
				PosX.value = preset_bottom_right_pos.x - ExampleWindow.size.x
				PosY.value = preset_pos_y
		
		else:
			PosX.value = preset_pos_x
			PosY.value = preset_pos_y
		
		CenterX.button_pressed = false
		CenterY.button_pressed = false
		CenterX.disabled = true
		CenterY.disabled = true
		ExampleWindow.draggable = false
		
		if $VBoxContainer/HBoxContainer8/IncludeSize.button_pressed == true:
			LinesBox.value = $"..".text_preset_dict[TextPresets.get_item_text(index)]["lines"]
			TWSpinBox.value = $"..".text_preset_dict[TextPresets.get_item_text(index)]["text width"]
			
			AutoLines.disabled = true
			LinesBox.editable = false
			AutoWidth.disabled = true
			TWSpinBox.editable = false
		
		PosX.editable = false
		PosY.editable = false
	
	else:
		if CenterX.button_pressed == false:
			PosX.editable = true
		if CenterY.button_pressed == false:
			PosY.editable = true
		
		CenterX.disabled = false
		CenterY.disabled = false
		ExampleWindow.draggable = true
		
		if AutoLines.button_pressed == false:
			LinesBox.editable = true
		else:
			AutoLines.button_pressed = false
			AutoLines.button_pressed = true
			
		AutoLines.disabled = false
		
		if AutoWidth.button_pressed == false:
			TWSpinBox.editable = true
		else:
			AutoWidth.button_pressed = false
			AutoWidth.button_pressed = true
			
		AutoWidth.disabled = false


func _on_text_preset_line_edit_text_submitted(new_text):
	if $"..".text_preset_dict.has(new_text):
		$"../DuplicatePresetWarning".popup_centered()
		return
	
	$"..".text_preset_dict[new_text] = {
		"id": $"..".text_preset_id, 
		"pos x": PosX.value, 
		"pos y": PosY.value, 
		"size x": BoxSizeX.value, 
		"size y": BoxSizeY.value, 
		"lines": LinesBox.value, 
		"text width": TWSpinBox.value
	}
	
	TextPresets.add_item(new_text, $"..".text_preset_id)
	TextPresets.select(TextPresets.get_item_index($"..".text_preset_id))
	TextPresets.item_selected.emit(TextPresets.get_selected())
	$"..".text_preset_id += 1
	
	$TextPresetPopup.hide()
	text_preset_added.emit(new_text)


func _on_include_size_toggled(button_pressed):
	var index = TextPresets.selected
	
	if index != 0:
		if button_pressed:
			
			LinesBox.value = $"..".text_preset_dict[TextPresets.get_item_text(index)]["lines"]
			TWSpinBox.value = $"..".text_preset_dict[TextPresets.get_item_text(index)]["text width"]
			
			AutoLines.disabled = true
			LinesBox.editable = false
			AutoWidth.disabled = true
			TWSpinBox.editable = false
			
			PosX.editable = false
		
		else:
			AutoLines.disabled = false
			AutoWidth.disabled = false
			
			if AutoLines.button_pressed == false:
				LinesBox.editable = true
			else:
				AutoLines.button_pressed = false
				AutoLines.button_pressed = true
			
			if AutoWidth.button_pressed == false:
				TWSpinBox.editable = true
			else:
				AutoWidth.button_pressed = false
				AutoWidth.button_pressed = true
				
				PosX.editable = false


func _on_center_y_toggled(button_pressed):
	if button_pressed:
		var old_pos = ExampleWindow.global_position
		
		ExampleWindow.center_y = true
		PosY.editable = false
		
		#ExampleWindow.global_position.y = (get_viewport().get_visible_rect().size.y - ExampleWindow.size.y) / 2
		if PairedPath.text == "":
			ExampleWindow.global_position.y = (get_viewport().get_visible_rect().size.y - ExampleWindow.size.y) / 2
		
		elif PairedAuto.button_pressed == false:
			ExampleWindow.global_position.y = (get_viewport().get_visible_rect().size.y - ExampleWindow.size.y) / 2
		
		elif PairedAutoOptions.selected == 2 or PairedAutoOptions.selected == 3:
			ExampleWindow.global_position.y = (get_viewport().get_visible_rect().size.y - (ExampleWindow.size.y + ExampleWindow.paired_offset.y + ExamplePaired.size.y)) / 2 + ExamplePaired.size.y + ExampleWindow.paired_offset.y
		
		else:
			ExampleWindow.global_position.y = (get_viewport().get_visible_rect().size.y - ExampleWindow.size.y) / 2
		
		if ExampleWindow.global_position != old_pos:
			ExampleWindow.dragged.emit(ExampleWindow.global_position)
	
	else:
		ExampleWindow.center_y = false
		PosY.editable = true


func _on_wipe_button_toggled(_button_pressed):
	NewBoxCheck.toggled.emit(NewBoxCheck.button_pressed)


func _on_position_offset_changed():
	if get_parent() != null:
		get_parent().position_offset_dict[get_name()]["x"] = position_offset.x
		get_parent().position_offset_dict[get_name()]["y"] = position_offset.y


func _on_example_frame_resized():
	FrameSizeX.value = ExampleFrame.size.x
	FrameSizeY.value = ExampleFrame.size.y


func _on_change_bgm_toggled(button_pressed):
	set_sound_dict("change bgm", button_pressed)
	
	if button_pressed:
		clear_sound.disabled = false
		play_button.disabled = false
		stop_button.disabled = false
		open_sound.disabled = false
	else:
		clear_sound.disabled = true
		play_button.disabled = true
		stop_button.disabled = true
		open_sound.disabled = true


func _on_clear_sound_pressed():
	set_sound_dict("sound path", "")
	sound_path.clear()


func _on_play_button_pressed():
	if sound_path.text != "":
		test_player.stream = load(sound_path.text)
		test_player.play()


func _on_stop_button_pressed():
	if test_player.playing:
		test_player.stop()


func _on_open_sound_pressed():
	$SoundFileDialog.popup_centered()


func _on_sound_file_dialog_file_selected(path):
	set_sound_dict("sound path", path)
	sound_path.text = path
