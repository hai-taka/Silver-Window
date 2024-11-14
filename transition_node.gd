extends GraphNode

@export var curtain_presets: Resource

const default_color = Color("c0c0c0")

var trans_dict = {
	"end card": false,
	"next script": "",
	"trans type": 1,
	"line color": default_color.to_html(),
	"fade duration": 3,
	"moon color": default_color.to_html(),
	"moon phrase": "",
	"phrase color": Color("ffffff").to_html()
}

var dialogue_connected: bool = false
const next: GraphNode = null

@onready var preset_options = %PresetOptionButton
@onready var curtain_line_color = %CurtainLineColor


# Called when the node enters the scene tree for the first time.
func _ready():
	trans_dict["trans type"] = %TransType.selected
	
	for key in curtain_presets.get_dict():
		preset_options.add_item(key)


func load_trans_dict(new_dict: Dictionary):
	trans_dict = new_dict
	%PathLineEdit.text = new_dict["next script"]
	%TransType.selected = new_dict["trans type"]
	%TransType.item_selected.emit(%TransType.selected)
	%CurtainLineColor.color = new_dict["line color"]
	%FadeDurSpinBox.value = new_dict["fade duration"]
	%EndCardCheck.button_pressed = new_dict["end card"]
	%EndCardCheck.toggled.emit(%EndCardCheck.button_pressed)
	%MoonColorButton.color = new_dict["moon color"]
	%PhraseLineEdit.text = new_dict["moon phrase"]
	%PhraseColorButton.color = new_dict["phrase color"]


func _on_fade_dur_spin_box_value_changed(value):
	trans_dict["fade duration"] = value


func _on_trans_type_item_selected(index):
	trans_dict["trans type"] = index
	
	if index == 1:
		%FadeDurHBox.hide()
		%CurtainLineHBox.show()
		reset_size()
	elif index == 2:
		%CurtainLineHBox.hide()
		%FadeDurHBox.show()
		reset_size()
	else:
		%FadeDurHBox.hide()
		%CurtainLineHBox.hide()
		reset_size()


func _on_open_button_pressed():
	$FileDialog.popup_centered()


func _on_clear_button_pressed():
	%PathLineEdit.text = ""
	trans_dict["next script"] = ""


func _on_path_line_edit_text_changed(new_text):
	trans_dict["next script"] = new_text


func _on_file_dialog_file_selected(path):
	%PathLineEdit.text = path
	%PathLineEdit.text_changed.emit(%PathLineEdit.text)


func _on_close_request():
	if not dialogue_connected:
		get_parent().position_offset_dict.erase(get_name())
		get_parent().transition_node_index -= 1
		get_parent().global_node_count -= 1
		queue_free()
	
	else:
		$"../CloseConnectedWarning".popup_centered()


func _on_resize_request(new_minsize):
	size = new_minsize


func _on_position_offset_changed():
	if get_parent() != null:
		get_parent().position_offset_dict[get_name()]["x"] = position_offset.x
		get_parent().position_offset_dict[get_name()]["y"] = position_offset.y


func _on_save_preset_pressed():
	%PresetLineEdit.clear()
	$PresetPopupPanel.popup_centered()
	%PresetLineEdit.grab_focus()


func _on_line_edit_text_submitted(new_text):
	if not curtain_presets.preset_exists(new_text):
		curtain_presets.add_preset(new_text, %CurtainLineColor.color)
		ResourceSaver.save(curtain_presets, "res://resources/Data/curtain_presets.tres")
		
		preset_options.add_item(new_text)
		preset_options.select(preset_options.get_item_count() - 1)
		$PresetPopupPanel.hide()
	
	else:
		$AcceptDialog.popup_centered()


func _on_preset_option_button_item_selected(index):
	if index == 0:
		curtain_line_color.color = default_color
		%RemovePreset.disabled = true
	else:
		var index_name: String = preset_options.get_item_text(index)
		var preset_color: Color = curtain_presets.get_color(index_name)
		
		curtain_line_color.color = preset_color
		%RemovePreset.disabled = false
	
	curtain_line_color.color_changed.emit(curtain_line_color.color)


func _on_remove_preset_pressed():
	var remove_index: int = preset_options.get_selected()
	var remove_name: String = preset_options.get_item_text(remove_index)
	
	if remove_index != 0:
		preset_options.select(0)
		preset_options.item_selected.emit(preset_options.selected)
		preset_options.remove_item(remove_index)
		
		curtain_presets.remove_preset(remove_name)
		ResourceSaver.save(curtain_presets, "res://resources/Data/curtain_presets.tres")


func _on_curtain_line_color_color_changed(color):
	trans_dict["line color"] = color.to_html()


func _on_go_to_button_pressed():
	if %PathLineEdit.text == "":
		return
	
	var graph_edit = get_parent()
	
	if graph_edit.current_file.text == "New File":
		$SaveFirstDialog.popup_centered()
		return
	
	graph_edit.save_json(false)
	await graph_edit.get_node("SaveIndicatorPanel").hidden
	
	graph_edit.load_json(%PathLineEdit.text)


func _on_new_button_pressed():
	$NewScriptFileDialog.popup_centered()


func _on_new_script_file_dialog_file_selected(path):
	DirAccess.copy_absolute("res://resources/Data/default-script.json", path)
	%PathLineEdit.text = path
	%PathLineEdit.text_changed.emit(%PathLineEdit.text)


func _on_end_card_check_toggled(button_pressed):
	if button_pressed:
		trans_dict["end card"] = true
		%OpenButton.disabled = true
		%NewButton.disabled = true
		%TransType.selected = 2
		%TransType.item_selected.emit(%TransType.get_selected())
		%TransType.disabled = true
		%HSeparator2.show()
		%EndCardVBox.show()
		reset_size()
	else:
		trans_dict["end card"] = false
		%OpenButton.disabled = false
		%NewButton.disabled = false
		%TransType.disabled = false
		%PhraseLineEdit.clear()
		%EndCardVBox.hide()
		%HSeparator2.hide()
		reset_size()


func _on_moon_color_button_color_changed(color):
	trans_dict["moon color"] = color.to_html()


func _on_phrase_line_edit_text_changed(new_text):
	trans_dict["moon phrase"] = new_text


func _on_phrase_color_button_color_changed(color):
	trans_dict["phrase color"] = color.to_html()
