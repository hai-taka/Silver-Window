extends GraphEdit

signal head_changed()
signal recent_files_updated

@export var file_tracker: Resource
@export var editor_theme: Resource

@export var window_stylebox: StyleBoxFlat = null
@export var window_theme: Theme = null
@export var name_label_settings: LabelSettings = null
@export var speaker_frame_stylebox: StyleBoxFlat = null
@export var wipe_stylebox: StyleBoxFlat = null
@export var silver_location_stylebox: StyleBoxFlat = null
@export var silver_location_label_settings: LabelSettings = null
@export var twenty_five_location_line: StyleBoxLine = null
@export var twenty_five_label_settings: LabelSettings = null

var global_node_count = 0
var node_offset = Vector2(60, 0)

var dialogue_node = preload("res://dialogue_node.tscn")
var dialogue_node_index = 0
var dialogue_node_pos = Vector2(20, 120)

var picture_node = preload("res://picture_node.tscn")
var picture_node_index = 0
var picture_node_pos = Vector2(20, 760)

var move_node = preload("res://move_node.tscn")
var move_node_index = 0

var transition_node = preload("res://transition_node.tscn")
var transition_node_index = 0

#var change_node = preload("res://change_node.tscn")
#var change_node_index = 0

var position_offset_dict = {}
var selected_nodes = []
var location_dict = {
	"show": true,
	"type": 0,
	"loc 1": "Location",
	"loc 2": "",
	"loc 3": "",
	"loc 4": "",
	"chapter": "Chapter",
}

var bg_dict = {
	"type": 0,
	"solid color": Color("000000").to_html(),
	"top color": Color("000000").to_html(),
	"top offset": 21,
	"bott color": Color("000000").to_html(),
	"bott offset": 91,
	"path": "",
	"animation": 0,
	"anim color": Color("000000ff").to_html(),
	"line color 1": Color("000000ff").to_html(),
	"line color 2": Color("000000ff").to_html(),
	"line color 3": Color("000000ff").to_html(),
	"line color 4": Color("000000ff").to_html(),
	"ripple delay": 6,
}
var initial_bg_dict: Dictionary = bg_dict.duplicate()

var drag_position = null
var json_string

var frame_preset_dict = {}
var frame_preset_id = 1

var text_preset_dict = {}
var text_preset_id = 1

var head = null
var pos_counter = 1
var right_click_location = null

var align = false
var default_margins = {
	"left": 20,
	"right": 20,
	"top": 100,
	"bottom": 20,
}
var top_margin: int = default_margins["top"]
var bottom_margin: int = default_margins["bottom"]
var left_margin: int = default_margins["left"]
var right_margin: int = default_margins["right"]

@onready var default_border_color: Color = window_stylebox.border_color
@onready var default_border_width: int = window_stylebox.border_width_top
@onready var default_frame_color: Color = speaker_frame_stylebox.border_color
@onready var default_frame_width: int = speaker_frame_stylebox.border_width_top
@onready var default_name_color: Color = name_label_settings.font_color
@onready var default_wipe_color: Color = wipe_stylebox.border_color
@onready var default_loc_bg_color: Color = silver_location_stylebox.bg_color
@onready var default_loc_text_color: Color = (
		silver_location_label_settings.font_color
)
@onready var default_twenty_five_line_color: Color = (
		twenty_five_location_line.color
)
@onready var default_twenty_five_text_color: Color = (
		twenty_five_label_settings.font_color
)
@onready var default_box_bg_color: Color = window_stylebox.bg_color
@onready var default_text_color: Color = window_theme.get_color("default_color", "RichTextLabel")
@onready var default_cursor_color: Color = Color("b1b1b1")

@onready var zoom_hbox = get_zoom_hbox()
@onready var current_file = %CurrentFile
@onready var full_screen_toggle = %FullScreenToggle
@onready var run_json_button = %RunJSONButton
@onready var border_color_hbox = %BorderColorHBox
@onready var hbox_container_3 = %HBoxContainer3
@onready var border_width_hbox = %BorderWidthHBox
@onready var border_color_button = %BorderColorButton
@onready var border_width_spinbox = %BorderWidthSpinBox
@onready var frame_color_hbox = %FrameColorHBox
@onready var frame_color_button = %FrameColorButton
@onready var name_color_hbox = %NameColorHBox
@onready var name_color_button = %NameColorButton
@onready var frame_width_hbox = %FrameWidthHBox
@onready var frame_width_spinbox = %FrameWidthSpinBox
@onready var wipe_color_hbox = %WipeColorHBox
@onready var wipe_color_button = %WipeColorButton
@onready var box_bg_panel = %BoxBGPanel
@onready var box_bg_color = %BoxBGColor
@onready var text_color_panel = %TextColorPanel
@onready var text_color = %TextColor
@onready var cursor_color_panel = %CursorColorPanel
@onready var cursor_color = %CursorColor

@onready var silver_loc_bg_hbox = %SilverLocBgHBox
@onready var silver_loc_bg_color = %SilverLocBgColor
@onready var silver_loc_text_hbox = %SilverLocTextHBox
@onready var silver_loc_text_color = %SilverLocTextColor
@onready var twenty_five_line_color = %TwentyFiveLineColor
@onready var twenty_five_text_color = %TwentyFiveTextColor

@onready var spacer_control = %SpacerControl
@onready var editor_theme_hbox = %EditorThemeHBox
@onready var theme_option_button = %ThemeOptionButton

@onready var location_button = %LocationButton
@onready var location_panel = %LocationPanel
@onready var margins_button = %MarginsButton
@onready var margins_panel = %MarginsPanel
@onready var pair_tb = %PairTB
@onready var pair_lr = %PairLR

@onready var background_button = %BackgroundButton
@onready var background_panel = %BackgroundPanel
@onready var bg_type = %BGType
@onready var solid_color_h_box = %SolidColorHBox
@onready var solid_color = %SolidColor
@onready var grad_color_v_box = %GradColorVBox
@onready var grad_top_color = %GradTopColor
@onready var grad_bott_color = %GradBottColor
@onready var texture_v_box = %TextureVBox
@onready var bg_path = %BGPath
@onready var bg_animation = %BGAnimation
@onready var anim_color_h_box = %AnimColorHBox
@onready var anim_color = %AnimColor
@onready var line_color_v_box = %LineColorVBox
@onready var line_color_1 = %LineColor1
@onready var line_color_2 = %LineColor2
@onready var line_color_3 = %LineColor3
@onready var line_color_4 = %LineColor4
@onready var grad_top_offset = %GradTopOffset
@onready var grad_top_slider = %GradTopSlider
@onready var grad_bott_offset = %GradBottOffset
@onready var grad_bott_slider = %GradBottSlider
@onready var ripple_delay_h_box = %RippleDelayHBox
@onready var ripple_delay = %RippleDelay

@onready var top_margin_spin_box = %TopMargin
@onready var bottom_margin_spin_box = %BottomMargin
@onready var left_margin_spin_box = %LeftMargin
@onready var right_margin_spin_box = %RightMargin

@onready var test_player = $EditorAudioPlayer


func _ready():
	OS.low_processor_usage_mode = true
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	zoom_hbox.reparent(hbox_container_3, false)
	zoom_hbox.add_theme_constant_override("separation", 5)
	full_screen_toggle.reparent(zoom_hbox, false)
	margins_button.reparent(zoom_hbox, false)
	run_json_button.reparent(zoom_hbox, false)
	
	var hbox_container_4 = HBoxContainer.new()
	hbox_container_3.add_child(hbox_container_4)
	hbox_container_4.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox_container_4.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox_container_4.add_theme_constant_override("separation", 15)
	
	location_button.reparent(hbox_container_4, false)
	background_button.reparent(hbox_container_4, false)
	border_color_hbox.reparent(hbox_container_4, false)
	#border_width_hbox.reparent(hbox_container_4, false)
	box_bg_panel.reparent(hbox_container_4, false)
	text_color_panel.reparent(hbox_container_4, false)
	cursor_color_panel.reparent(hbox_container_4, false)
	wipe_color_hbox.reparent(hbox_container_4, false)
	name_color_hbox.reparent(hbox_container_4, false)
	frame_color_hbox.reparent(hbox_container_4, false)
	#frame_width_hbox.reparent(hbox_container_4, false)
	
	top_margin_spin_box.value = default_margins["top"]
	bottom_margin_spin_box.value = default_margins["bottom"]
	left_margin_spin_box.value = default_margins["left"]
	right_margin_spin_box.value = default_margins["right"]
	$MarginLines.position = Vector2(left_margin, top_margin)
	$MarginLines.size = (get_viewport().get_visible_rect().size 
			- $MarginLines.position - Vector2(right_margin, bottom_margin))
	
	border_color_button.color = window_stylebox.border_color
	border_width_spinbox.value = window_stylebox.border_width_top
	frame_color_button.color = speaker_frame_stylebox.border_color
	frame_width_spinbox.value = speaker_frame_stylebox.border_width_top
	name_color_button.color = name_label_settings.font_color
	wipe_color_button.color = wipe_stylebox.border_color
	box_bg_color.color = window_stylebox.bg_color
	text_color.color = window_theme.get_color("default_color", "RichTextLabel")
	cursor_color.color = Color("b1b1b1")
	
	silver_loc_bg_color.color = silver_location_stylebox.bg_color
	silver_loc_text_color.color = silver_location_label_settings.font_color
	twenty_five_line_color.color = twenty_five_location_line.color
	twenty_five_text_color.color = twenty_five_label_settings.font_color
	
	for theme_name in editor_theme.theme_dict.keys():
		theme_option_button.add_item(theme_name)


func set_bg_dict(key: String, new_value) -> void:
	if bg_dict.has(key):
		bg_dict[key] = new_value
	else:
		print("Key does not exist.")


func load_bg_dict(new_dict: Dictionary) -> void:
	bg_dict = new_dict.duplicate()
	bg_type.selected = new_dict["type"]
	bg_type.item_selected.emit(bg_type.selected)
	solid_color.color = new_dict["solid color"]
	grad_top_color.color = new_dict["top color"]
	grad_top_offset.value = new_dict["top offset"]
	grad_bott_color.color = new_dict["bott color"]
	grad_bott_offset.value = new_dict["bott offset"]
	bg_path.text = new_dict["path"]
	bg_animation.selected = new_dict["animation"]
	bg_animation.item_selected.emit(bg_animation.selected)
	anim_color.color = new_dict["anim color"]
	line_color_1.color = new_dict["line color 1"]
	line_color_2.color = new_dict["line color 2"]
	line_color_3.color = new_dict["line color 3"]
	line_color_4.color = new_dict["line color 4"]
	ripple_delay.value = new_dict["ripple delay"]


func add_to_recent_files(new_item: String) -> void:
	if new_item == "New File":
		return
	
	if file_tracker.recent_files.has(new_item):
		file_tracker.recent_files.erase(new_item)
	
	elif file_tracker.recent_files.size() == 10:
		file_tracker.recent_files.pop_back()
	
	file_tracker.recent_files.push_front(new_item)
	ResourceSaver.save(file_tracker, "res://resources/Data/visual_editor_recent_files.tres")
	
	recent_files_updated.emit()


func reset_colors_widths():
	border_color_button.color = default_border_color
	border_color_button.color_changed.emit(border_color_button.color)
	border_width_spinbox.value = default_border_width
	frame_color_button.color = default_frame_color
	frame_color_button.color_changed.emit(frame_color_button.color)
	frame_width_spinbox.value = default_frame_width
	name_color_button.color = default_name_color
	name_color_button.color_changed.emit(name_color_button.color)
	wipe_color_button.color = default_wipe_color
	box_bg_color.color = default_box_bg_color
	box_bg_color.color_changed.emit(box_bg_color.color)
	text_color.color = default_text_color
	text_color.color_changed.emit(text_color.color)
	cursor_color.color = default_cursor_color
	
	silver_loc_bg_color.color = default_loc_bg_color
	silver_loc_text_color.color = default_loc_text_color
	twenty_five_line_color.color = default_twenty_five_line_color
	twenty_five_text_color.color = default_twenty_five_text_color


func clear_nodes():
	clear_connections()
	get_tree().call_group("graph_nodes", "queue_free")
	current_file.text = "New File"
	head = null
	dialogue_node_index = 0
	dialogue_node_pos = Vector2(20, 120)
	picture_node_index = 0
	picture_node_pos = Vector2(20, 620)
	move_node_index = 0
	transition_node_index = 0
	#change_node_index = 0
	global_node_count = 0
	pos_counter = 1
	
	frame_preset_dict.clear()
	frame_preset_id = 1
	
	text_preset_dict.clear()
	text_preset_id = 1
	
	position_offset_dict.clear()
	
	reset_colors_widths()
	
	get_tree().call_group("location_line_edits", "clear")
	%Location1.text = "Location"
	%Location1.text_changed.emit(%Location1.text)
	%Chapter.text = "Chapter"
	%Chapter.text_changed.emit(%Chapter.text)
	%ShowLocation.button_pressed = true
	%LocationType.selected = 0
	%LocationType.item_selected.emit(%LocationType.selected)
	
	load_bg_dict(initial_bg_dict)
	
	%ShowMargins.button_pressed = false
	pair_lr.button_pressed = false
	pair_tb.button_pressed = false
	left_margin_spin_box.value = default_margins["left"]
	right_margin_spin_box.value = default_margins["right"]
	top_margin_spin_box.value = default_margins["top"]
	bottom_margin_spin_box.value = default_margins["bottom"]


func save(path : String, thing_to_save):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(thing_to_save)
	
	$SaveIndicatorPanel/SaveProgressBar.fill_bar(0.25)


func load_json_file(path: String):
	if FileAccess.file_exists(path):
		var json_file = FileAccess.open(path, FileAccess.READ)
		var parsed = JSON.parse_string(json_file.get_as_text())
		
		if parsed is Dictionary:
			return parsed
		
		else:
			print("Error: Parsed result not dictionary.")
			return null
		
	else:
		print("Error: File does not exist.")
		return null


func new_dialogue_node(use_start_pos: bool = false, start_pos: Vector2 = Vector2(0, 0)):
	# Instance dialogue node.
	var dialogue_node_instance = dialogue_node.instantiate()
	
	dialogue_node_instance.connect("dragged", _on_dialogue_node_instance_dragged)
	dialogue_node_instance.connect("frame_preset_added", _on_dialogue_node_instance_frame_preset_added)
	dialogue_node_instance.connect("frame_preset_removed", _on_dialogue_node_instance_frame_preset_removed)
	dialogue_node_instance.connect("text_preset_added", _on_dialogue_node_instance_text_preset_added)
	dialogue_node_instance.connect("text_preset_removed", _on_dialogue_node_instance_text_preset_removed)
	
	var pos
	var center_pos = (get_viewport().get_visible_rect().size / 2.0) - (dialogue_node_instance.size / 2.0)
	var pos_one =  center_pos - (Vector2(dialogue_node_instance.size.x / 2.0 + 30, 20) * zoom)
	var pos_two =  center_pos + (Vector2(dialogue_node_instance.size.x / 2.0 + 30, -20) * zoom)
	var pos_three =  center_pos - (Vector2(dialogue_node_instance.size.x / 2.0 + 30, -20) * zoom)
	var pos_four =  center_pos + (Vector2(dialogue_node_instance.size.x / 2.0 + 30, 20) * zoom)
	
	if use_start_pos:
		pos = start_pos
	
	elif pos_counter == 1:
		pos = pos_one
		pos_counter += 1
	
	elif pos_counter == 2:
		pos = pos_two
		pos_counter += 1
	
	elif pos_counter == 3:
		pos = pos_three
		pos_counter += 1
	
	elif pos_counter == 4:
		pos = pos_four
		pos_counter = 1
	
	dialogue_node_instance.position_offset = (scroll_offset / zoom) + (pos / zoom)
	
	add_child(dialogue_node_instance)
	
	var stylebox = dialogue_node_instance.ExampleWindow.stylebox
	var paired_stylebox = dialogue_node_instance.ExamplePaired.stylebox
	stylebox.border_color = border_color_button.color
	stylebox.set_border_width_all(border_width_spinbox.value)
	stylebox.bg_color = box_bg_color.color
	paired_stylebox.border_color = border_color_button.color
	paired_stylebox.set_border_width_all(border_width_spinbox.value)
	
	if dialogue_node_index == 0:
		dialogue_node_instance.get_node("VBoxContainer/HBoxContainer7/HeadCheck").button_pressed = true
	
	elif head != null:
		dialogue_node_instance.get_node("VBoxContainer/HBoxContainer7/HeadCheck").disabled = true
	
	dialogue_node_index += 1
	global_node_count += 1
	
	var pos_off = {}
	pos_off["x"] = dialogue_node_instance.position_offset.x
	pos_off["y"] = dialogue_node_instance.position_offset.y
	position_offset_dict[dialogue_node_instance.get_name()] = pos_off
	#position_offset_dict[dialogue_node_instance.get_name()]["x"] = dialogue_node_instance.position_offset.x
	#position_offset_dict[dialogue_node_instance.get_name()]["y"] = dialogue_node_instance.position_offset.y


func _on_dialogue_node_instance_dragged(from, to):
	if from == dialogue_node_pos:
		dialogue_node_pos = to


func _on_connection_request(from_node, from_port, to_node, to_port):
	var FromNode = get_node(str(from_node))
	var ToNode = get_node(str(to_node))
	
	# No self-connections
	if from_node == to_node:
		return
	
	elif ToNode != head:
		# Dialogue to Dialogue connecton
		if get_tree().get_nodes_in_group("dialogue_nodes").has(FromNode) and \
			get_tree().get_nodes_in_group("dialogue_nodes").has(ToNode):
			
			var next_array = []
			for node in get_tree().get_nodes_in_group("dialogue_nodes"):
				if node.next != null:
					next_array.append(node.next)
			
			if FromNode.next == null and !next_array.has(ToNode):
				connect_node(from_node, from_port, to_node, to_port)
				FromNode.next = ToNode
				ToNode.prev = FromNode
				
				ToNode.get_node("VBoxContainer/HBoxContainer7/HeadCheck").disabled = true
				ToNode.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").disabled = false
		
		# Don't allow Picture to Picture connection
		elif get_tree().get_nodes_in_group("picture_nodes").has(FromNode) and \
			get_tree().get_nodes_in_group("picture_nodes").has(ToNode):
				
				return
		
		# Allow Dialogue to Picture
		elif get_tree().get_nodes_in_group("dialogue_nodes").has(FromNode) and \
			get_tree().get_nodes_in_group("picture_nodes").has(ToNode):
				
				if ToNode.start_connected == false:
					connect_node(from_node, from_port, to_node, to_port)
					ToNode.start_connected = true
					ToNode.start_node = FromNode
					FromNode.picture_connected = true
		
		# Allow Picture to Dialogue
		elif get_tree().get_nodes_in_group("picture_nodes").has(FromNode) and \
			get_tree().get_nodes_in_group("dialogue_nodes").has(ToNode):
				
				if FromNode.start_connected and FromNode.end_connected == false:
					var dialogue_array = []
					var current = FromNode.start_node
					
					while current.next != null:
						dialogue_array.append(current.next)
						current = current.next
					
					if dialogue_array.has(ToNode):
						connect_node(from_node, from_port, to_node, to_port)
						FromNode.end_connected = true
						FromNode.end_node = ToNode
						ToNode.picture_connected = true
		
		# Allow Picture to Move
		elif get_tree().get_nodes_in_group("picture_nodes").has(FromNode) and \
			get_tree().get_nodes_in_group("move_nodes").has(ToNode):
				
				if FromNode.start_connected:
					connect_node(from_node, from_port, to_node, to_port)
					ToNode.pic_connected = true
					ToNode.pic_node = FromNode
					FromNode.move_connected = true
		
		# Allow Move to Dialogue
		elif get_tree().get_nodes_in_group("move_nodes").has(FromNode) and \
			get_tree().get_nodes_in_group("dialogue_nodes").has(ToNode):
				
				if FromNode.pic_connected and not FromNode.dialogue_connected:
					for dict in ToNode.pics_to_move:
						if dict["pic"] == FromNode.pic_node:
							return
					
					var current = FromNode.pic_node.start_node
					var end = FromNode.pic_node.end_node
					var dialogue_array = []
					
					while current.next != null and not current.transition_connected:
						if end != null and current.next == end:
							break
						
						dialogue_array.append(current.next)
						current = current.next
					
					if not dialogue_array.has(ToNode):
						return
					
					connect_node(from_node, from_port, to_node, to_port)
					FromNode.dialogue_connected = true
					FromNode.dialogue_node = ToNode
					ToNode.move_connected = true
					ToNode.pics_to_move.append(FromNode.move_dict)
		
		# Allow Dialogue to Transition
		elif get_tree().get_nodes_in_group("dialogue_nodes").has(FromNode) and \
				get_tree().get_nodes_in_group("transition_nodes").has(ToNode):

			if FromNode.next == null and not ToNode.dialogue_connected:
				connect_node(from_node, from_port, to_node, to_port)
				FromNode.next = ToNode
				FromNode.transition_connected = true
				ToNode.dialogue_connected = true


func _on_disconnection_request(from_node, from_port, to_node, to_port):
	var FromNode = get_node(str(from_node))
	var ToNode = get_node(str(to_node))
	
	# Dialogue to Dialogue
	if get_tree().get_nodes_in_group("dialogue_nodes").has(FromNode) and \
		get_tree().get_nodes_in_group("dialogue_nodes").has(ToNode):
		
		disconnect_node(from_node, from_port, to_node, to_port)
		ToNode.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").button_pressed = true
		ToNode.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").disabled = true
		
		FromNode.next = null
		ToNode.prev = null
		
		if head == null:
			ToNode.get_node("VBoxContainer/HBoxContainer7/HeadCheck").disabled = false
	
	# Dialogue to Picture
	elif get_tree().get_nodes_in_group("dialogue_nodes").has(FromNode) and \
		get_tree().get_nodes_in_group("picture_nodes").has(ToNode):
			
			disconnect_node(from_node, from_port, to_node, to_port)
			ToNode.start_connected = false
			ToNode.start_node = null
			FromNode.picture_connected = false
	
	# Picture to Dialogue
	elif get_tree().get_nodes_in_group("picture_nodes").has(FromNode) and \
		get_tree().get_nodes_in_group("dialogue_nodes").has(ToNode):
			
			disconnect_node(from_node, from_port, to_node, to_port)
			FromNode.end_connected = false
			FromNode.end_node = null
			ToNode.picture_connected = false
	
	# Picture to Move
	elif get_tree().get_nodes_in_group("picture_nodes").has(FromNode) and \
		get_tree().get_nodes_in_group("move_nodes").has(ToNode):
			
			if not ToNode.dialogue_connected:
				disconnect_node(from_node, from_port, to_node, to_port)
				FromNode.move_connected = false
				ToNode.pic_connected = false
				ToNode.pic_node = null
	
	# Move to Dialogue
	elif get_tree().get_nodes_in_group("move_nodes").has(FromNode) and \
		get_tree().get_nodes_in_group("dialogue_nodes").has(ToNode):
			
			disconnect_node(from_node, from_port, to_node, to_port)
			FromNode.dialogue_connected = false
			FromNode.dialogue_node = null
			ToNode.move_connected = false
			ToNode.pics_to_move.erase(FromNode.move_dict)
	
	# Dialogue to Transition
	elif get_tree().get_nodes_in_group("dialogue_nodes").has(FromNode) and \
				get_tree().get_nodes_in_group("transition_nodes").has(ToNode):
			
			disconnect_node(from_node, from_port, to_node, to_port)
			FromNode.next = null
			FromNode.transition_connected = false
			ToNode.dialogue_connected = false


func save_json(save_as: bool = true):
	var connection_list = get_connection_list()
	var current_node = head
	var linked_list = []
	var node_dict = {}
	var picture_dict = {}
	var move_node_counter = 0
	
	# Warning if no head exists
	if head == null:
		$NoHeadDialog.popup_centered()
		return
	
	# Generate picture dict
	for i in connection_list.size():
		var from_node = get_node(str(connection_list[i].from))
		var to_node = get_node(str(connection_list[i].to))
		var from_node_id = str(from_node)
		var to_node_id = str(to_node)
		
		if from_node_id.contains("Picture"):
			if not picture_dict.has(from_node):
				picture_dict[from_node] = {"from": null, "to": to_node}
			
			else:
				picture_dict[from_node]["to"] = to_node
		
		if to_node_id.contains("Picture"):
			if not picture_dict.has(to_node):
				picture_dict[to_node] = {"from": from_node, "to": null}
			
			else:
				picture_dict[to_node]["from"] = from_node
	
	# Generate linked list starting from head
	while current_node.next != null:
		linked_list.append(current_node)
		current_node = current_node.next
	
	linked_list.append(current_node)
	
	# Count connected move nodes
	for node in linked_list:
		if get_tree().get_nodes_in_group("dialogue_nodes").has(node):
			move_node_counter += node.pics_to_move.size()
	
	if linked_list.size() == 0:
		$SaveErrorDialog.popup_centered()
		return
	
	# Warning if unconnected nodes detected
	elif linked_list.size() < (get_tree().get_nodes_in_group("dialogue_nodes").size()
					+ get_tree().get_nodes_in_group("transition_nodes").size()) \
			or picture_dict.size() < get_tree().get_nodes_in_group("picture_nodes").size() \
			or move_node_counter < get_tree().get_nodes_in_group("move_nodes").size():
		$UnconnectedNodesDialog.popup_centered()
		await $UnconnectedNodesDialog.confirmed
	
	# Save loop
	for i in linked_list.size():
		var node = linked_list[i]
		var type
		
		if get_tree().get_nodes_in_group("transition_nodes").has(node):
			type = "transition"
		
		elif node.get_node("VBoxContainer/TextEdit").text != "":
			type = "text"
		
		else:
			type = "blank"
		
		if type == "transition":
			node_dict[str(i)] = {
				"type": "transition",
				"trans dict": node.trans_dict.duplicate(),
			}
		
		elif type == "blank":
			node_dict[str(i)] = {"type": "blank"}
		
		elif type == "text":
			var new_box = node.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").button_pressed
			var speaker_name = node.get_node("VBoxContainer/HBoxContainer3/LineEdit").text
			var speaker_option = node.get_node("VBoxContainer/HBoxContainer3/SpeakerOptions").selected
			var text = node.get_node("VBoxContainer/TextEdit").text
			var auto_width = node.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/AutoWidth").button_pressed
			var width = node.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/TextWidthSpinBox").value
			var lines = node.get_node("VBoxContainer/MarginContainer3/HBoxContainer/LinesBox").value
			var auto_lines = node.get_node("VBoxContainer/MarginContainer3/HBoxContainer/AutoLines").button_pressed
			var text_preset_selected = node.get_node("VBoxContainer/HBoxContainer8/TextPresets").selected
			var include_size = node.get_node("VBoxContainer/HBoxContainer8/IncludeSize").button_pressed
			
			if !new_box:
				var wipe = node.get_node("VBoxContainer/MarginContainer3/HBoxContainer/HBoxContainer/WipeButton").button_pressed
				var old_box_index = i - 1
				
				while node_dict[str(old_box_index)]["new"] == false:
					old_box_index -= 1
					
				if width > node_dict[str(old_box_index)]["width"]:
					node_dict[str(old_box_index)]["width"] = width
					node_dict[str(old_box_index)]["auto_width"] = false
				
				if lines > node_dict[str(old_box_index)]["lines"] and wipe:
					node_dict[str(old_box_index)]["lines"] = lines
					node_dict[str(old_box_index)]["auto_lines"] = false
				
				#if !wipe and node_dict[str(old_box_index)]["auto_lines"]:
				#	node_dict[str(old_box_index)]["lines"] = node_dict[str(old_box_index)]["lines"] + lines
				#	node_dict[str(old_box_index)]["auto_lines"] = false
				
				node_dict[str(i)] = {
					"type": type,
					"new": new_box,
					"name": speaker_name,
					"speaker option": speaker_option,
					"text": text,
					"width": width,
					"auto_width": auto_width,
					"wipe": wipe
				}
			
			else:
				var dialogue_center_x = node.get_node("VBoxContainer/HBoxContainer6/CenterX").button_pressed
				var dialogue_center_y = node.get_node("VBoxContainer/HBoxContainer6/CenterY").button_pressed
				var pos_x = node.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionX").value
				var pos_y = node.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionY").value
				var paired
				
				if node.get_node("VBoxContainer/HBoxContainer/PairedPath").text != "":
					paired = true
				
				else:
					paired = false
				
				if paired:
					var path = node.get_node("VBoxContainer/HBoxContainer/PairedPath").text
					var paired_auto = node.get_node("VBoxContainer/HBoxContainer2/PairedAuto").button_pressed
					var paired_auto_option = node.get_node("VBoxContainer/HBoxContainer2/PairedAutoOptions").selected
					var paired_pos_x = node.get_node("VBoxContainer/HBoxContainer/PairedPosX").value
					var paired_pos_y = node.get_node("VBoxContainer/HBoxContainer/PairedPosY").value
					var frame_preset = node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_item_id(node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_selected())
					
					node_dict[str(i)] = {
						"type": type,
						"new": new_box,
						"name": speaker_name,
						"speaker option": speaker_option,
						"text": text,
						"width": width,
						"auto_width": auto_width,
						"lines": lines,
						"auto_lines": auto_lines,
						"dialogue center x": dialogue_center_x,
						"dialogue center y": dialogue_center_y,
						"pos x": pos_x,
						"pos y": pos_y,
						"paired": paired,
						"paired_auto": paired_auto,
						"paired auto option": paired_auto_option,
						"path": path,
						"paired pos x": paired_pos_x,
						"paired pos y": paired_pos_y,
						"text preset selected": text_preset_selected,
						"include size": include_size
					}
					
					node_dict[str(i)]["frame preset"] = frame_preset
					
				else:
					var show_frame = node.get_node("VBoxContainer/HBoxContainer4/HBoxContainer/ShowFrame").button_pressed
					
					node_dict[str(i)] = {
						"type": type,
						"new": new_box,
						"name": speaker_name,
						"speaker option": speaker_option,
						"text": text,
						"width": width,
						"auto_width": auto_width,
						"lines": lines,
						"auto_lines": auto_lines,
						"dialogue center x": dialogue_center_x,
						"dialogue center y": dialogue_center_y,
						"pos x": pos_x,
						"pos y": pos_y,
						"paired": paired,
						"show frame": show_frame,
						"text preset selected": text_preset_selected,
						"include size": include_size
					}
					
					if show_frame:
						var frame_preset = node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_item_id(node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_selected())
						var frame_pos_x = node.get_node("VBoxContainer/HBoxContainer4/FramePosX").value
						var frame_pos_y = node.get_node("VBoxContainer/HBoxContainer4/FramePosY").value
						var frame_size_x = node.get_node("VBoxContainer/HBoxContainer5/FrameSizeX").value
						var frame_size_y = node.get_node("VBoxContainer/HBoxContainer5/FrameSizeY").value
						var speaker_pos_x = node.ExampleName.position.x
						var speaker_pos_y = node.ExampleName.position.y
						
						node_dict[str(i)]["frame preset"] = frame_preset
						node_dict[str(i)]["frame pos x"] = frame_pos_x
						node_dict[str(i)]["frame pos y"] = frame_pos_y
						node_dict[str(i)]["frame size x"] = frame_size_x
						node_dict[str(i)]["frame size y"] = frame_size_y
						node_dict[str(i)]["speaker pos x"] = speaker_pos_x
						node_dict[str(i)]["speaker pos y"] = speaker_pos_y
		
		node_dict[str(i)]["node name"] = node.get_name()
		
		var start_picture = false
		var pic_to_start = []
		var picture_path = []
		var picture_pos_x = []
		var picture_pos_y = []
		var center_x = []
		var center_y = []
		var fade_in = []
		var fade_in_duration = []
		var fade_in_color = []
		var fade_in_solid = []
		var fade_out = []
		var fade_out_duration = []
		var fade_out_color = []
		var fade_out_solid = []
		var picture_size_x = []
		var picture_size_y = []
		var first_pic_dict_array = []
		var sound_dict_array = []
		
		var end_picture = false
		var pic_to_end = []
		
		for key in picture_dict.keys():
			if picture_dict[key].from == node:
				start_picture = true
				#pic_to_start.append(str(key))
				pic_to_start.append(key.get_name())
				picture_path.append(key.get_node("VBoxContainer/HBoxContainer2/PicturePath").text)
				picture_pos_x.append(key.get_node("VBoxContainer/HBoxContainer/PosXSpinBox").value)
				picture_pos_y.append(key.get_node("VBoxContainer/HBoxContainer/PosYSpinBox").value)
				center_x.append(key.get_node("VBoxContainer/HBoxContainer/CenterXCheck").button_pressed)
				center_y.append(key.get_node("VBoxContainer/HBoxContainer/CenterYCheck").button_pressed)
				fade_in.append(key.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInCheck").button_pressed)
				fade_in_duration.append(key.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInDuration").value)
				fade_in_color.append(key.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInColor").color.to_html())
				fade_in_solid.append(key.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInSolid").button_pressed)
				fade_out.append(key.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutCheck").button_pressed)
				fade_out_duration.append(key.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutDuration").value)
				fade_out_color.append(key.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutColor").color.to_html())
				fade_out_solid.append(key.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutSolid").button_pressed)
				picture_size_x.append(key.get_node("VBoxContainer/HBoxContainer3/SizeXSpinBox").value)
				picture_size_y.append(key.get_node("VBoxContainer/HBoxContainer3/SizeYSpinBox").value)
				first_pic_dict_array.append(key.first_pic_dict)
				sound_dict_array.append(key.sound_dict)
			
			if picture_dict[key].to == node:
				end_picture = true
				#pic_to_end.append(str(key))
				pic_to_end.append(key.get_name())
		
		if start_picture:
			node_dict[str(i)]["start picture"] = true
			node_dict[str(i)]["picture to start"] = pic_to_start
			node_dict[str(i)]["picture path"] = picture_path
			node_dict[str(i)]["picture pos x"] = picture_pos_x
			node_dict[str(i)]["picture pos y"] = picture_pos_y
			node_dict[str(i)]["center x"] = center_x
			node_dict[str(i)]["center y"] = center_y
			node_dict[str(i)]["fade in"] = fade_in
			node_dict[str(i)]["fade in duration"] = fade_in_duration
			node_dict[str(i)]["fade in color"] = fade_in_color
			node_dict[str(i)]["fade in solid"] = fade_in_solid
			node_dict[str(i)]["fade out"] = fade_out
			node_dict[str(i)]["fade out duration"] = fade_out_duration
			node_dict[str(i)]["fade out color"] = fade_out_color
			node_dict[str(i)]["fade out solid"] = fade_out_solid
			node_dict[str(i)]["picture size x"] = picture_size_x
			node_dict[str(i)]["picture size y"] = picture_size_y
			
			if i == 0:
				node_dict[str(i)]["first pic dict"] = first_pic_dict_array
			
			node_dict[str(i)]["sound dict"] = sound_dict_array
		
		elif node_dict[str(i)]["type"] != "transition":
			node_dict[str(i)]["start picture"] = false
		
		if end_picture:
			node_dict[str(i)]["end picture"] = true
			node_dict[str(i)]["picture to end"] = pic_to_end
		
		elif node_dict[str(i)]["type"] != "transition":
			node_dict[str(i)]["end picture"] = false
		
		if node_dict[str(i)]["type"] != "transition":
			node_dict[str(i)]["pics to move"] = node.pics_to_move
			node_dict[str(i)]["dialogue sound dict"] = node.sound_dict
	
	node_dict[str(0)]["frame preset dict"] = frame_preset_dict
	node_dict[str(0)]["frame preset id"] = frame_preset_id
	
	node_dict[str(0)]["text preset dict"] = text_preset_dict
	node_dict[str(0)]["text preset id"] = text_preset_id
	
	node_dict[str(0)]["position offset dict"] = position_offset_dict
	node_dict[str(0)]["location dict"] = location_dict
	node_dict[str(0)]["bg dict"] = bg_dict
	node_dict[str(0)]["margin dict"] = {
		"show": %ShowMargins.button_pressed,
		"left": left_margin,
		"right": right_margin,
		"top": top_margin,
		"bottom": bottom_margin,
		"pair lr": pair_lr.button_pressed,
		"pair tb": pair_tb.button_pressed,
	}
	
	node_dict[str(0)]["border color"] = border_color_button.color.to_html()
	node_dict[str(0)]["border width"] = border_width_spinbox.value
	node_dict[str(0)]["frame color"] = frame_color_button.color.to_html()
	node_dict[str(0)]["frame width"] = frame_width_spinbox.value
	node_dict[str(0)]["name color"] = name_color_button.color.to_html()
	node_dict[str(0)]["wipe color"] = wipe_color_button.color.to_html()
	node_dict[str(0)]["box bg color"] = box_bg_color.color.to_html()
	node_dict[str(0)]["text color"] = text_color.color.to_html()
	node_dict[str(0)]["cursor color"] = cursor_color.color.to_html()
	
	node_dict[str(0)]["loc bg color"] = silver_loc_bg_color.color.to_html()
	node_dict[str(0)]["loc text color"] = silver_loc_text_color.color.to_html()
	node_dict[str(0)]["25 line color"] = twenty_five_line_color.color.to_html()
	node_dict[str(0)]["25 text color"] = twenty_five_text_color.color.to_html()
	
	json_string = JSON.stringify(node_dict, "\t")
	
	if current_file.text == "New File":
		save_as = true
	
	if save_as:
		$FileDialog.popup_centered()
	else:
		save(current_file.text, json_string)
	#print(node_dict)


func clear_all_connections():
	$ClearConnectionsDialog.popup_centered()


func new_picture_node(use_start_pos: bool = false, start_pos: Vector2 = Vector2(0, 0)):
	# Instance picture node.
	var picture_node_instance = picture_node.instantiate()
	
	picture_node_instance.connect("dragged", _on_picture_node_instance_dragged)
	
	var pos
	var center_pos = (get_viewport().get_visible_rect().size / 2.0) - (picture_node_instance.size / 2.0)
	var pos_one =  center_pos - (Vector2(picture_node_instance.size.x / 2.0 + 60, 20) * zoom)
	var pos_two =  center_pos + (Vector2(picture_node_instance.size.x / 2.0 + 60, -20) * zoom)
	var pos_three =  center_pos - (Vector2(picture_node_instance.size.x / 2.0 + 60, -20) * zoom)
	var pos_four =  center_pos + (Vector2(picture_node_instance.size.x / 2.0 + 60, 20) * zoom)
	
	if use_start_pos:
		pos = start_pos
	
	elif pos_counter == 1:
		pos = pos_one
		pos_counter += 1
	
	elif pos_counter == 2:
		pos = pos_two
		pos_counter += 1
	
	elif pos_counter == 3:
		pos = pos_three
		pos_counter += 1
	
	elif pos_counter == 4:
		pos = pos_four
		pos_counter = 1
	
	picture_node_instance.position_offset = (scroll_offset / zoom) + (pos / zoom)
	
	add_child(picture_node_instance)
	
	var stylebox = picture_node_instance.ExamplePictureContainer.stylebox
	stylebox.border_color = border_color_button.color
	stylebox.set_border_width_all(border_width_spinbox.value)
	
	picture_node_index += 1
	global_node_count += 1
	
	var pos_off = {}
	pos_off["x"] = picture_node_instance.position_offset.x
	pos_off["y"] = picture_node_instance.position_offset.y
	position_offset_dict[picture_node_instance.get_name()] = pos_off
	#position_offset_dict[picture_node_instance.get_name()]["x"] = picture_node_instance.position_offset.x
	#position_offset_dict[picture_node_instance.get_name()]["y"] = picture_node_instance.position_offset.y


func _on_picture_node_instance_dragged(from, to):
	if from == picture_node_pos:
		picture_node_pos = to


func _on_file_dialog_file_selected(path):
	save(path, json_string)
	current_file.text = path


func load_json(path: String = ""):
	if path == "":
		$LoadFileDialog.popup_centered()
	else:
		$LoadFileDialog.file_selected.emit(path)


func _on_load_file_dialog_file_selected(path):
	var script = {}
	var to
	var from
	var node_instance
	var pic_node_dict = {}
	
	if current_file.text != "New File":
		add_to_recent_files(current_file.text)
	
	clear_nodes()
	
	current_file.text = path
	
	script = load_json_file(path)
	if script == null:
		clear_nodes()
		$NonexistantFileDialog.popup_centered()
		return
	
	frame_preset_dict = script["0"]["frame preset dict"]
	frame_preset_id = script["0"]["frame preset id"]
	
	if script["0"].has("text preset dict"):
		text_preset_dict = script["0"]["text preset dict"]
	if script["0"].has("text preset id"):
		text_preset_id = script["0"]["text preset id"]
	
	var loaded_position_offsets = script["0"]["position offset dict"]
	
	var loaded_location_dict = script["0"]["location dict"]
	%ShowLocation.button_pressed = loaded_location_dict["show"]
	%LocationType.select(loaded_location_dict["type"])
	%LocationType.item_selected.emit(%LocationType.selected)
	%Location1.text = loaded_location_dict["loc 1"]
	%Location1.text_changed.emit(%Location1.text)
	%Location2.text = loaded_location_dict["loc 2"]
	%Location2.text_changed.emit(%Location2.text)
	%Location3.text = loaded_location_dict["loc 3"]
	%Location3.text_changed.emit(%Location3.text)
	%Location4.text = loaded_location_dict["loc 4"]
	%Location4.text_changed.emit(%Location4.text)
	%Chapter.text = loaded_location_dict["chapter"]
	%Chapter.text_changed.emit(%Chapter.text)
	
	var loaded_bg_dict = script["0"]["bg dict"]
	load_bg_dict(loaded_bg_dict)
	
	var loaded_margins = script["0"]["margin dict"]
	%ShowMargins.button_pressed = loaded_margins["show"]
	left_margin_spin_box.value = loaded_margins["left"]
	right_margin_spin_box.value = loaded_margins["right"]
	top_margin_spin_box.value = loaded_margins["top"]
	bottom_margin_spin_box.value = loaded_margins["bottom"]
	pair_lr.button_pressed = loaded_margins["pair lr"]
	pair_tb.button_pressed = loaded_margins["pair tb"]
	
	# Load loop
	for i in script.size():
		var dict = script[str(i)]
		
		if !dict.has_all(["type"]):
			$LoadFileDialog.hide()
			$LoadErrorDialog.popup_centered()
			clear_nodes()
			print("Load error 1")
			return
		
		var type = script[str(i)]["type"]
		var start_pic
		var end_pic
		
		if type != "transition":
			start_pic = script[str(i)]["start picture"]
			end_pic = script[str(i)]["end picture"]
		
		if type == "blank":
			var dialogue_node_instance = dialogue_node.instantiate()
			
			dialogue_node_instance.connect("dragged", _on_dialogue_node_instance_dragged)
			dialogue_node_instance.connect("frame_preset_added", _on_dialogue_node_instance_frame_preset_added)
			dialogue_node_instance.connect("frame_preset_removed", _on_dialogue_node_instance_frame_preset_removed)
			dialogue_node_instance.connect("text_preset_added", _on_dialogue_node_instance_text_preset_added)
			dialogue_node_instance.connect("text_preset_removed", _on_dialogue_node_instance_text_preset_removed)
			
			node_instance = dialogue_node_instance
			
			#if dialogue_node_index != 0:
			#	dialogue_node_instance.position_offset = dialogue_node_pos + (node_offset + Vector2(dialogue_node_instance.size.x, 0))
			#
			#dialogue_node_pos = dialogue_node_instance.position_offset
			
			dialogue_node_instance.position_offset = (Vector2(
					loaded_position_offsets.get(script[str(i)]["node name"])["x"], 
					loaded_position_offsets.get(script[str(i)]["node name"])["y"])
					)
			add_child(dialogue_node_instance)
			
			if head != null:
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer7/HeadCheck").disabled = true
			
			if i == 0:
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer7/HeadCheck").button_pressed = true
			
			else:
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").disabled = false
			
			dialogue_node_index += 1
			global_node_count += 1
			
			var pos_off = {}
			pos_off["x"] = dialogue_node_instance.position_offset.x
			pos_off["y"] = dialogue_node_instance.position_offset.y
			position_offset_dict[dialogue_node_instance.get_name()] = pos_off
			
			dialogue_node_instance.pics_to_move = script[str(i)]["pics to move"]
			dialogue_node_instance.load_sound_dict(script[str(i)]["dialogue sound dict"])
		
		elif type == "text":
			var dialogue_node_instance = dialogue_node.instantiate()
			
			dialogue_node_instance.connect("dragged", _on_dialogue_node_instance_dragged)
			dialogue_node_instance.connect("frame_preset_added", _on_dialogue_node_instance_frame_preset_added)
			dialogue_node_instance.connect("frame_preset_removed", _on_dialogue_node_instance_frame_preset_removed)
			dialogue_node_instance.connect("text_preset_added", _on_dialogue_node_instance_text_preset_added)
			dialogue_node_instance.connect("text_preset_removed", _on_dialogue_node_instance_text_preset_removed)
			
			node_instance = dialogue_node_instance
			
			#if dialogue_node_index != 0:
			#	dialogue_node_instance.position_offset = dialogue_node_pos + (node_offset + Vector2(dialogue_node_instance.size.x, 0))
			#
			#dialogue_node_pos = dialogue_node_instance.position_offset
			
			dialogue_node_instance.position_offset = (Vector2(
					loaded_position_offsets.get(script[str(i)]["node name"])["x"], 
					loaded_position_offsets.get(script[str(i)]["node name"])["y"])
					)
			add_child(dialogue_node_instance)
			
			if head != null:
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer7/HeadCheck").disabled = true
			
			if i == 0:
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer7/HeadCheck").button_pressed = true
			
			else:
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").disabled = false
			
			dialogue_node_index += 1
			global_node_count += 1
			
			var pos_off = {}
			pos_off["x"] = dialogue_node_instance.position_offset.x
			pos_off["y"] = dialogue_node_instance.position_offset.y
			position_offset_dict[dialogue_node_instance.get_name()] = pos_off
			
			dialogue_node_instance.pics_to_move = script[str(i)]["pics to move"]
			dialogue_node_instance.load_sound_dict(script[str(i)]["dialogue sound dict"])
			
			if !dict.has_all(["text", "name", "speaker option", "new", "width", "auto_width"]):
				$LoadFileDialog.hide()
				$LoadErrorDialog.popup_centered()
				clear_nodes()
				print("Load error 2")
				return
			
			var text = script[str(i)]["text"]
			var speaker_name = script[str(i)]["name"]
			var speaker_option = script[str(i)]["speaker option"]
			var new = script[str(i)]["new"]
			var width = script[str(i)]["width"]
			var auto_width = script[str(i)]["auto_width"]
			
		#	dialogue_node_instance.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").button_pressed = new
			dialogue_node_instance.get_node("VBoxContainer/HBoxContainer3/LineEdit").text = speaker_name
			dialogue_node_instance.get_node("VBoxContainer/HBoxContainer3/LineEdit").text_changed.emit(speaker_name)
			dialogue_node_instance.get_node("VBoxContainer/HBoxContainer3/SpeakerOptions").selected = speaker_option
			dialogue_node_instance.get_node("VBoxContainer/TextEdit").text = text
			dialogue_node_instance.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/TextWidthSpinBox").value = width
			dialogue_node_instance.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer/HBoxContainer/AutoWidth").button_pressed = auto_width
			dialogue_node_instance.get_node("VBoxContainer/TextEdit").text_changed.emit()
			
			if new:
				if !dict.has_all(["dialogue center x", "dialogue center y", "pos x", "pos y", "paired", "lines", "auto_lines", "text preset selected", "include size"]):
					$LoadFileDialog.hide()
					$LoadErrorDialog.popup_centered()
					clear_nodes()
					print("Load error 3")
					return
				
				var dialogue_center_x = script[str(i)]["dialogue center x"]
				var dialogue_center_y = script[str(i)]["dialogue center y"]
				var pos_x = script[str(i)]["pos x"]
				var pos_y = script[str(i)]["pos y"]
				var paired = script[str(i)]["paired"]
				var lines = script[str(i)]["lines"]
				var auto_lines = script[str(i)]["auto_lines"]
				var text_preset_selected = script[str(i)]["text preset selected"]
				#var include_size = script[str(i)]["include size"]
				
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer6/CenterX").button_pressed = dialogue_center_x
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer6/CenterX").toggled.emit(dialogue_center_x)
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer6/CenterY").button_pressed = dialogue_center_y
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer6/CenterY").toggled.emit(dialogue_center_y)
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionX").value = pos_x
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer2/HBoxContainer/PositionY").value = pos_y
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer3/HBoxContainer/LinesBox").value = lines
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer3/HBoxContainer/AutoLines").button_pressed = auto_lines
				dialogue_node_instance.get_node("VBoxContainer/MarginContainer3/HBoxContainer/AutoLines").toggled.emit(auto_lines)
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer8/TextPresets").selected = text_preset_selected
				dialogue_node_instance.get_node("VBoxContainer/HBoxContainer8/TextPresets").item_selected.emit(text_preset_selected)
				#dialogue_node_instance.get_node("VBoxContainer/HBoxContainer8/IncludeSize").button_pressed = include_size
				
				if paired:
					if !dict.has_all(["path", "paired_auto", "paired auto option", "paired pos x", "paired pos y", "frame preset"]):
						$LoadFileDialog.hide()
						$LoadErrorDialog.popup_centered()
						clear_nodes()
						print("Load error 4")
						return
					
					var frame_preset = script[str(i)]["frame preset"]
					
					dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").selected = dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_item_index(frame_preset)
					dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").item_selected.emit(dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_selected())
					
					if frame_preset == 0:
						var paired_path = script[str(i)]["path"]
						var paired_auto = script[str(i)]["paired_auto"]
						var paired_auto_option = script[str(i)]["paired auto option"]
						var paired_x = script[str(i)]["paired pos x"]
						var paired_y = script[str(i)]["paired pos y"]
						
						dialogue_node_instance.get_node("VBoxContainer/HBoxContainer3/LineEdit").text = speaker_name
						dialogue_node_instance.get_node("VBoxContainer/HBoxContainer2/PairedAutoOptions").selected = paired_auto_option
						dialogue_node_instance.get_node("FileDialog").file_selected.emit(paired_path)
						dialogue_node_instance.get_node("VBoxContainer/HBoxContainer2/PairedAuto").button_pressed = paired_auto
						dialogue_node_instance.get_node("VBoxContainer/HBoxContainer/PairedPosX").value = paired_x
						dialogue_node_instance.get_node("VBoxContainer/HBoxContainer/PairedPosY").value = paired_y
				
				else:
					if !dict.has("show frame"):
						$LoadFileDialog.hide()
						$LoadErrorDialog.popup_centered()
						clear_nodes()
						print("Load error 5")
						return
					
					var show_frame = script[str(i)]["show frame"]
					
					dialogue_node_instance.get_node("VBoxContainer/HBoxContainer4/HBoxContainer/ShowFrame").button_pressed = show_frame
					
					if show_frame:
						if !dict.has_all(["frame preset", "frame pos x", "frame pos y", "frame size x", "frame size y"]):
							$LoadFileDialog.hide()
							$LoadErrorDialog.popup_centered()
							clear_nodes()
							print("Load error 6")
							return
						
						var frame_preset = script[str(i)]["frame preset"]
						
						dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").selected = dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_item_index(frame_preset)
						dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").item_selected.emit(dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets").get_selected())
						
						if frame_preset == 0:
							var frame_pos_x = script[str(i)]["frame pos x"]
							var frame_pos_y = script[str(i)]["frame pos y"]
							var frame_size_x = script[str(i)]["frame size x"]
							var frame_size_y = script[str(i)]["frame size y"]
							
							dialogue_node_instance.get_node("VBoxContainer/HBoxContainer3/LineEdit").text = speaker_name
							dialogue_node_instance.get_node("VBoxContainer/HBoxContainer4/FramePosX").value = frame_pos_x
							dialogue_node_instance.get_node("VBoxContainer/HBoxContainer4/FramePosY").value = frame_pos_y
							dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/FrameSizeX").value = frame_size_x
							dialogue_node_instance.get_node("VBoxContainer/HBoxContainer5/FrameSizeY").value = frame_size_y
			
			#else:
			#	var wipe = script[str(i)]["wipe"]
			#	dialogue_node_instance.get_node("VBoxContainer/MarginContainer3/HBoxContainer/HBoxContainer/WipeButton").button_pressed = wipe
		
		elif type == "transition":
			# Instance transition node.
			var transition_node_instance = transition_node.instantiate()
			
			transition_node_instance.position_offset = (Vector2(
					loaded_position_offsets.get(script[str(i)]["node name"])["x"], 
					loaded_position_offsets.get(script[str(i)]["node name"])["y"])
				)
			
			add_child(transition_node_instance)
			
			transition_node_index += 1
			global_node_count += 1
			
			var pos_off = {}
			pos_off["x"] = transition_node_instance.position_offset.x
			pos_off["y"] = transition_node_instance.position_offset.y
			position_offset_dict[transition_node_instance.get_name()] = pos_off
			
			transition_node_instance.load_trans_dict(script[str(i)]["trans dict"].duplicate())
			
			connect_node(node_instance.get_name(), 0, transition_node_instance.get_name(), 0)
			node_instance.next = transition_node_instance
			node_instance.transition_connected = true
			transition_node_instance.dialogue_connected = true
		
		else:
			$LoadFileDialog.hide()
			$LoadErrorDialog.popup_centered()
			clear_nodes()
			print("Load error 7")
			return
		
		# Add pic nodes and connect dialogue to pics if called for
		if start_pic:
			if !dict.has_all(["picture to start", "picture path", "picture pos x", "picture pos y", "center x", "center y", "fade in", "fade in duration", "fade in color", "fade in solid", "fade out", "fade out duration", "fade out color", "fade out solid", "picture size x", "picture size y"]):
				$LoadFileDialog.hide()
				$LoadErrorDialog.popup_centered()
				clear_nodes()
				print("Load error 8")
				return
			
			var pics_to_start = script[str(i)]["picture to start"]
			var pic_paths = script[str(i)]["picture path"]
			var pic_pos_x = script[str(i)]["picture pos x"]
			var pic_pos_y = script[str(i)]["picture pos y"]
			var center_x = script[str(i)]["center x"]
			var center_y = script[str(i)]["center y"]
			var fade_in = script[str(i)]["fade in"]
			var fade_in_duration = script[str(i)]["fade in duration"]
			var fade_in_color = script[str(i)]["fade in color"]
			var fade_in_solid = script[str(i)]["fade in solid"]
			var fade_out = script[str(i)]["fade out"]
			var fade_out_duration = script[str(i)]["fade out duration"]
			var fade_out_color = script[str(i)]["fade out color"]
			var fade_out_solid = script[str(i)]["fade out solid"]
			var pic_size_x = script[str(i)]["picture size x"]
			var pic_size_y = script[str(i)]["picture size y"]
			
			var first_pic_dict_array
			if i == 0:
				first_pic_dict_array = script[str(i)]["first pic dict"]
			
			var sound_dict_array = script[str(i)]["sound dict"]
			
			for j in pics_to_start.size():
				var picture_node_instance = picture_node.instantiate()
				
				picture_node_instance.connect("dragged", _on_picture_node_instance_dragged)
				
				#if picture_node_index != 0:
				#	picture_node_instance.position_offset = picture_node_pos + (node_offset + Vector2(272, 0) + Vector2(picture_node_instance.size.x, 0))
				#
				#picture_node_pos = picture_node_instance.position_offset
				picture_node_instance.position_offset = (Vector2(
						loaded_position_offsets.get(pics_to_start[j])["x"], 
						loaded_position_offsets.get(pics_to_start[j])["y"])
						)
				add_child(picture_node_instance)
				
				pic_node_dict[pics_to_start[j]] = picture_node_instance
				picture_node_index += 1
				global_node_count += 1
				
				var pos_off = {}
				pos_off["x"] = picture_node_instance.position_offset.x
				pos_off["y"] = picture_node_instance.position_offset.y
				position_offset_dict[picture_node_instance.get_name()] = pos_off
				
				picture_node_instance.get_node("VBoxContainer/HBoxContainer2/PicturePath").text = pic_paths[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer/PosXSpinBox").value = pic_pos_x[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer/PosYSpinBox").value = pic_pos_y[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer/CenterXCheck").button_pressed = center_x[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer/CenterYCheck").button_pressed = center_y[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInCheck").button_pressed = fade_in[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInDuration").value = fade_in_duration[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInColor").color = Color(fade_in_color[j])
				picture_node_instance.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer/FadeInSolid").button_pressed = fade_in_solid[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutCheck").button_pressed = fade_out[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutDuration").value = fade_out_duration[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutColor").color = Color(fade_out_color[j])
				picture_node_instance.get_node("VBoxContainer/HBoxContainer4/VBoxContainer/HBoxContainer2/FadeOutSolid").button_pressed = fade_out_solid[j]
				
				picture_node_instance.get_node("FileDialog").file_selected.emit(pic_paths[j])
				
				picture_node_instance.get_node("VBoxContainer/HBoxContainer3/SizeXSpinBox").value = pic_size_x[j]
				picture_node_instance.get_node("VBoxContainer/HBoxContainer3/SizeYSpinBox").value = pic_size_y[j]
				
				if i == 0:
					picture_node_instance.load_first_pic_dict(first_pic_dict_array[j])
				
				picture_node_instance.load_sound_dict(sound_dict_array[j])
				
				connect_node(node_instance.get_name(), 1, picture_node_instance.get_name(), 0)
				picture_node_instance.start_connected = true
				picture_node_instance.start_node = node_instance
				node_instance.picture_connected = true
		
		# Connect pic nodes to dialogue node if called for
		if end_pic:
			if !dict.has("picture to end"):
				$LoadFileDialog.hide()
				$LoadErrorDialog.popup_centered()
				clear_nodes()
				print("Load error 9")
				return
			
			var pics_to_end = script[str(i)]["picture to end"]
			
			for j in pics_to_end.size():
				connect_node(pic_node_dict.get(pics_to_end[j]).get_name(), 0, node_instance.get_name(), 1)
				pic_node_dict.get(pics_to_end[j]).end_connected = true
				pic_node_dict.get(pics_to_end[j]).end_node = node_instance
				node_instance.picture_connected = true
		
		# Add move nodes if called for
		if not node_instance.pics_to_move.is_empty():
			var new_pics_to_move = []
			
			for move_dict in node_instance.pics_to_move:
				var move_node_instance = move_node.instantiate()
				
				#move_node_instance.connect("dragged", _on_move_node_instance_dragged)
				#
				#if move_node_index != 0:
				#	move_node_instance.position_offset = move_node_pos + (node_offset + Vector2(272, 0) + Vector2(move_node_instance.size.x, 0))
				#
				#move_node_pos = move_node_instance.position_offset
				#
				move_node_instance.position_offset = (Vector2(
						loaded_position_offsets.get(move_dict["move node name"])["x"], 
						loaded_position_offsets.get(move_dict["move node name"])["y"])
						)
				add_child(move_node_instance)
				move_node_index += 1
				global_node_count += 1
				
				var pos_off = {}
				pos_off["x"] = move_node_instance.position_offset.x
				pos_off["y"] = move_node_instance.position_offset.y
				position_offset_dict[move_node_instance.get_name()] = pos_off
				
				move_node_instance.pic_node = pic_node_dict.get(move_dict["pic name"])
				move_node_instance.new_pos_x.value = move_dict["new pos x"]
				move_node_instance.new_pos_y.value = move_dict["new pos y"]
				move_node_instance.move_type.selected = move_dict["move type"]
				move_node_instance.move_type.item_selected.emit(move_dict["move type"])
				move_node_instance.load_move_dict(move_dict)
				
				connect_node(pic_node_dict.get(move_dict["pic name"]).get_name(), 1, move_node_instance.get_name(), 0)
				move_node_instance.pic_connected = true
				move_node_instance.pic_node = pic_node_dict.get(move_dict["pic name"])
				pic_node_dict.get(move_dict["pic name"]).move_connected = true
				
				connect_node(move_node_instance.get_name(), 0, node_instance.get_name(), 2)
				move_node_instance.dialogue_connected = true
				move_node_instance.dialogue_node = node_instance
				node_instance.move_connected = true
				new_pics_to_move.append(move_node_instance.move_dict)
			
			node_instance.pics_to_move = new_pics_to_move
		
		# Connect dialogue nodes
		if script[str(i)]["type"] != "transition":
			if i == 0:
				from = node_instance
			else:
				to = node_instance
				connect_node(from.get_name(), 0, to.get_name(), 0)
				from.next = to
				to.prev = from
				if script[str(i)].has("new"):
					node_instance.get_node("VBoxContainer/MarginContainer/HBoxContainer/HBoxContainer2/HBoxContainer/NewBoxCheck").button_pressed = script[str(i)]["new"]
				if script[str(i)].has("wipe"):
					node_instance.get_node("VBoxContainer/MarginContainer3/HBoxContainer/HBoxContainer/WipeButton").button_pressed = script[str(i)]["wipe"]
				from = to
	
	border_color_button.color = script["0"]["border color"]
	border_color_button.color_changed.emit(border_color_button.color)
	border_width_spinbox.value = script["0"]["border width"]
	frame_color_button.color = script["0"]["frame color"]
	frame_color_button.color_changed.emit(frame_color_button.color)
	frame_width_spinbox.value = script["0"]["frame width"]
	name_color_button.color = script["0"]["name color"]
	name_color_button.color_changed.emit(name_color_button.color)
	wipe_color_button.color = script["0"]["wipe color"]
	wipe_color_button.color_changed.emit(wipe_color_button.color)
	box_bg_color.color = script["0"]["box bg color"]
	box_bg_color.color_changed.emit(box_bg_color.color)
	text_color.color = script["0"]["text color"]
	text_color.color_changed.emit(text_color.color)
	cursor_color.color = script["0"]["cursor color"]
	cursor_color.color_changed.emit(cursor_color.color)
	
	silver_loc_bg_color.color = script["0"]["loc bg color"]
	silver_loc_bg_color.color_changed.emit(silver_loc_bg_color.color)
	silver_loc_text_color.color = script["0"]["loc text color"]
	silver_loc_text_color.color_changed.emit(silver_loc_text_color.color)
	twenty_five_line_color.color = script["0"]["25 line color"]
	twenty_five_line_color.color_changed.emit(twenty_five_line_color.color)
	twenty_five_text_color.color = script["0"]["25 text color"]
	twenty_five_text_color.color_changed.emit(twenty_five_text_color.color)


func prompt_to_clear_nodes():
	$ConfirmationDialog.popup_centered()


func _on_confirmation_dialog_confirmed():
	add_to_recent_files(current_file.text)
	clear_nodes()


func _on_clear_connections_dialog_confirmed():
#	for connection in get_connection_list():
#		disconnection_request.emit(connection["from"], connection["from_port"], 
#				connection["to"], connection["to_port"])
	clear_connections()


func quit_editor():
	$QuitConfirmationDialog.popup_centered()


func _on_quit_confirmation_dialog_confirmed():
	#add_to_recent_files(current_file.text)
	get_tree().quit()


func _on_dialogue_node_instance_frame_preset_added(preset_name):
	for node in get_tree().get_nodes_in_group("dialogue_nodes"):
		var FramePresets = node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets")
		
		if FramePresets.get_item_index(frame_preset_dict[preset_name]["id"]) == -1:
			FramePresets.add_item(preset_name, frame_preset_dict[preset_name]["id"])


func _on_dialogue_node_instance_frame_preset_removed(preset_id):
	for node in get_tree().get_nodes_in_group("dialogue_nodes"):
		var FramePresets = node.get_node("VBoxContainer/HBoxContainer5/HBoxContainer/FramePresets")
		
		if FramePresets.get_item_index(preset_id) != -1:
			FramePresets.remove_item(FramePresets.get_item_index(preset_id))
			FramePresets.select(0)
			FramePresets.item_selected.emit(0)


func _on_dialogue_node_instance_text_preset_added(preset_name):
	for node in get_tree().get_nodes_in_group("dialogue_nodes"):
		var TextPresets = node.get_node("VBoxContainer/HBoxContainer8/TextPresets")
		
		if TextPresets.get_item_index(text_preset_dict[preset_name]["id"]) == -1:
			TextPresets.add_item(preset_name, text_preset_dict[preset_name]["id"])


func _on_dialogue_node_instance_text_preset_removed(preset_id):
	for node in get_tree().get_nodes_in_group("dialogue_nodes"):
		var TextPresets = node.get_node("VBoxContainer/HBoxContainer8/TextPresets")
		
		if TextPresets.get_item_index(preset_id) != -1:
			TextPresets.remove_item(TextPresets.get_item_index(preset_id))
			TextPresets.select(0)
			TextPresets.item_selected.emit(0)


func _on_full_screen_toggle_toggled(button_pressed):
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_head_changed():
	if head != null:
		for node in get_tree().get_nodes_in_group("dialogue_nodes"):
			if node != head:
				node.get_node("VBoxContainer/HBoxContainer7/HeadCheck").disabled = true
	
	else:
		var next_array = []
		
		for node in get_tree().get_nodes_in_group("dialogue_nodes"):
			if node.next != null:
				next_array.append(node.next)
		
		for node in get_tree().get_nodes_in_group("dialogue_nodes"):
			if !next_array.has(node):
				node.get_node("VBoxContainer/HBoxContainer7/HeadCheck").disabled = false


func hide_examples():
	for node in get_tree().get_nodes_in_group("dialogues_and_pics"):
		node.get_node("VBoxContainer/CenterContainer/ShowExampleBox").button_pressed = false


func run_json():
	save_json(false)
	await %SaveIndicatorPanel.hidden
	
	if current_file.text != "New File":
		if $EditorAudioPlayer.playing:
			$EditorAudioPlayer.stop()
		
		DialogueManager.change_script(current_file.text)
		GlobalData.running_from_editor = true
		SceneSwitcher.preserve_and_go_to_scene("res://main1.tscn")
	
	else:
		$NoFileDialog.popup_centered()


func _on_top_margin_value_changed(value):
	top_margin = value
	$MarginLines.position.y = top_margin
	$MarginLines.size.y = get_viewport().get_visible_rect().size.y - top_margin - bottom_margin
	
	if pair_tb.button_pressed:
		bottom_margin_spin_box.value = top_margin


func _on_bottom_margin_value_changed(value):
	bottom_margin = value
	$MarginLines.size.y = get_viewport().get_visible_rect().size.y - top_margin - bottom_margin


func _on_left_margin_value_changed(value):
	left_margin = value
	$MarginLines.position.x = left_margin
	$MarginLines.size.x = get_viewport().get_visible_rect().size.x - left_margin - right_margin
	
	if pair_lr.button_pressed:
		right_margin_spin_box.value = left_margin


func _on_right_margin_value_changed(value):
	right_margin = value
	$MarginLines.size.x = get_viewport().get_visible_rect().size.x - left_margin - right_margin


func _on_show_margins_toggled(button_pressed):
	if button_pressed:
		$MarginLines.show()
	
	else:
		$MarginLines.hide()


func _on_pair_lr_toggled(button_pressed):
	if button_pressed:
		right_margin_spin_box.value = left_margin_spin_box.value
		right_margin_spin_box.editable = false
	
	else:
		right_margin_spin_box.editable = true


func _on_pair_tb_toggled(button_pressed):
	if button_pressed:
		bottom_margin_spin_box.value = top_margin_spin_box.value
		bottom_margin_spin_box.editable = false
	
	else:
		bottom_margin_spin_box.editable = true


func hide_graph_nodes():
	if not get_tree().get_nodes_in_group("no_controls").is_empty():
		var node = get_tree().get_nodes_in_group("no_controls")[0]
		
		if node.is_visible_in_tree():
			get_tree().call_group("no_controls", "hide")
		
		else:
			get_tree().call_group("no_controls", "show")


func new_move_node(use_start_pos: bool = false, start_pos: Vector2 = Vector2(0, 0)):
	# Instance move node.
	var move_node_instance = move_node.instantiate()
	
	var pos
	var center_pos = (get_viewport().get_visible_rect().size / 2.0) - (move_node_instance.size / 2.0)
	var pos_one =  center_pos - (Vector2(move_node_instance.size.x / 2.0 + 30, 20) * zoom)
	var pos_two =  center_pos + (Vector2(move_node_instance.size.x / 2.0 + 30, -20) * zoom)
	var pos_three =  center_pos - (Vector2(move_node_instance.size.x / 2.0 + 30, -20) * zoom)
	var pos_four =  center_pos + (Vector2(move_node_instance.size.x / 2.0 + 30, 20) * zoom)
	
	if use_start_pos:
		pos = start_pos
	
	elif pos_counter == 1:
		pos = pos_one
		pos_counter += 1
	
	elif pos_counter == 2:
		pos = pos_two
		pos_counter += 1
	
	elif pos_counter == 3:
		pos = pos_three
		pos_counter += 1
	
	elif pos_counter == 4:
		pos = pos_four
		pos_counter = 1
	
	move_node_instance.position_offset = (scroll_offset / zoom) + (pos / zoom)
	
	add_child(move_node_instance)
	
	move_node_index += 1
	global_node_count += 1
	
	var pos_off = {}
	pos_off["x"] = move_node_instance.position_offset.x
	pos_off["y"] = move_node_instance.position_offset.y
	position_offset_dict[move_node_instance.get_name()] = pos_off
	#position_offset_dict[move_node_instance.get_name()]["x"] = move_node_instance.position_offset.x
	#position_offset_dict[move_node_instance.get_name()]["y"] = move_node_instance.position_offset.y


#func new_change_node(use_start_pos: bool = false, start_pos: Vector2 = Vector2(0, 0)):
#	# Instance change node.
#	var change_node_instance = change_node.instantiate()
#
#	var pos
#	var center_pos = (get_viewport().get_visible_rect().size / 2.0) - (change_node_instance.size / 2.0)
#	var pos_one =  center_pos - (Vector2(change_node_instance.size.x / 2.0 + 30, 20) * zoom)
#	var pos_two =  center_pos + (Vector2(change_node_instance.size.x / 2.0 + 30, -20) * zoom)
#	var pos_three =  center_pos - (Vector2(change_node_instance.size.x / 2.0 + 30, -20) * zoom)
#	var pos_four =  center_pos + (Vector2(change_node_instance.size.x / 2.0 + 30, 20) * zoom)
#
#	if use_start_pos:
#		pos = start_pos
#
#	elif pos_counter == 1:
#		pos = pos_one
#		pos_counter += 1
#
#	elif pos_counter == 2:
#		pos = pos_two
#		pos_counter += 1
#
#	elif pos_counter == 3:
#		pos = pos_three
#		pos_counter += 1
#
#	elif pos_counter == 4:
#		pos = pos_four
#		pos_counter = 1
#
#	change_node_instance.position_offset = (scroll_offset / zoom) + (pos / zoom)
#
#	add_child(change_node_instance)
#
#	change_node_index += 1
#	global_node_count += 1
#
#	var pos_off = {}
#	pos_off["x"] = change_node_instance.position_offset.x
#	pos_off["y"] = change_node_instance.position_offset.y
#	position_offset_dict[change_node_instance.get_name()] = pos_off


func new_transition_node(use_start_pos: bool = false, start_pos: Vector2 = Vector2(0, 0)):
	# Instance transition node.
	var transition_node_instance = transition_node.instantiate()
	
	var pos
	var center_pos = (get_viewport().get_visible_rect().size / 2.0) - (transition_node_instance.size / 2.0)
	var pos_one =  center_pos - (Vector2(transition_node_instance.size.x / 2.0 + 30, 20) * zoom)
	var pos_two =  center_pos + (Vector2(transition_node_instance.size.x / 2.0 + 30, -20) * zoom)
	var pos_three =  center_pos - (Vector2(transition_node_instance.size.x / 2.0 + 30, -20) * zoom)
	var pos_four =  center_pos + (Vector2(transition_node_instance.size.x / 2.0 + 30, 20) * zoom)
	
	if use_start_pos:
		pos = start_pos
	
	elif pos_counter == 1:
		pos = pos_one
		pos_counter += 1
	
	elif pos_counter == 2:
		pos = pos_two
		pos_counter += 1
	
	elif pos_counter == 3:
		pos = pos_three
		pos_counter += 1
	
	elif pos_counter == 4:
		pos = pos_four
		pos_counter = 1
	
	transition_node_instance.position_offset = (scroll_offset / zoom) + (pos / zoom)
	
	add_child(transition_node_instance)
	
	transition_node_index += 1
	global_node_count += 1
	
	var pos_off = {}
	pos_off["x"] = transition_node_instance.position_offset.x
	pos_off["y"] = transition_node_instance.position_offset.y
	position_offset_dict[transition_node_instance.get_name()] = pos_off


func _on_reset_margins_pressed():
	pair_tb.button_pressed = false
	pair_lr.button_pressed = false
	top_margin_spin_box.value = default_margins["top"]
	bottom_margin_spin_box.value = default_margins["bottom"]
	left_margin_spin_box.value = default_margins["left"]
	right_margin_spin_box.value = default_margins["right"]


func _on_run_json_button_pressed():
	run_json()


func _input(event):
	if event.is_action_pressed("new_json"):
		prompt_to_clear_nodes()
	elif event.is_action_pressed("save_json"):
		save_json(false)
	elif event.is_action_pressed("save_json_as"):
		save_json(true)
	elif event.is_action_pressed("save_minimal_json"):
		pass
	elif event.is_action_pressed("load_json"):
		load_json()
	elif event.is_action_pressed("quit_editor"):
		quit_editor()
	elif event.is_action_pressed("hide_examples"):
		hide_examples()
	elif event.is_action_pressed("run_json"):
		run_json()
	elif event.is_action_pressed("new_dialogue_node"):
		new_dialogue_node()
	elif event.is_action_pressed("new_picture_node"):
		new_picture_node()
	elif event.is_action_pressed("new_move_node"):
		new_move_node()
	elif event.is_action_pressed("new_transition_node"):
		new_transition_node()
#	elif event.is_action_pressed("new_change_node"):
#		new_change_node()
	elif event.is_action_pressed("close_selected_nodes"):
		for node in selected_nodes:
			if node != null:
				node.close_request.emit()
		selected_nodes.clear()


func _on_node_selected(node):
	selected_nodes.append(node)


func _on_node_deselected(node):
	selected_nodes.erase(node)


@warning_ignore("shadowed_variable_base_class")
func _on_popup_request(position):
	right_click_location = position
	%Node.position = position
	%Node.popup()


func _on_border_color_button_color_changed(color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	window_stylebox.border_color = color
	for panel_cont in get_tree().get_nodes_in_group("window_panel_containers"):
		panel_cont.get_theme_stylebox("panel").border_color = color


func _on_border_width_spin_box_value_changed(value):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	window_stylebox.set_border_width_all(value)
	for panel_cont in get_tree().get_nodes_in_group("window_panel_containers"):
		panel_cont.get_theme_stylebox("panel").set_border_width_all(value)
		panel_cont.reset_size()


func _on_frame_color_button_color_changed(color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	speaker_frame_stylebox.border_color = color


func _on_name_color_button_color_changed(color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	name_label_settings.font_color = color


func _on_frame_width_spin_box_value_changed(value):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	speaker_frame_stylebox.set_border_width_all(value)


func _on_location_button_toggled(button_pressed):
	if button_pressed:
		location_panel.position = (location_button.global_position 
				+ Vector2(location_button.size.x / 2, location_button.size.y + 5) 
				- Vector2(location_panel.size.x / 2, 0))
		location_panel.popup()
	else:
		location_panel.hide()


func _on_location_panel_popup_hide():
	if location_button.button_pressed:
		location_button.button_pressed = false


func _on_margins_button_toggled(button_pressed):
	if button_pressed:
		margins_panel.position = (margins_button.global_position 
				+ Vector2(margins_button.size.x / 2, margins_button.size.y + 5) 
				- Vector2(margins_panel.size.x / 2, 0))
		margins_panel.popup()
	else:
		margins_panel.hide()


func _on_margins_panel_popup_hide():
	if margins_button.button_pressed:
		margins_button.button_pressed = false


func _on_clear_locations_pressed():
	get_tree().call_group("location_line_edits", "clear")


func _on_show_location_toggled(button_pressed):
	location_dict["show"] = button_pressed
	
	if button_pressed:
		%LocationType.disabled = false
		for location in get_tree().get_nodes_in_group("location_line_edits"):
			location.editable = true
		
		%LocColorVBox.show()
	else:
		%LocationType.disabled = true
		for location in get_tree().get_nodes_in_group("location_line_edits"):
			location.editable = false
		
		%LocColorVBox.hide()
		%LocationPanel.reset_size()


func _on_location_1_text_changed(new_text):
	location_dict["loc 1"] = new_text


func _on_location_2_text_changed(new_text):
	location_dict["loc 2"] = new_text


func _on_location_3_text_changed(new_text):
	location_dict["loc 3"] = new_text


func _on_location_4_text_changed(new_text):
	location_dict["loc 4"] = new_text


func _on_chapter_text_changed(new_text):
	location_dict["chapter"] = new_text


func _on_location_type_item_selected(index):
	location_dict["type"] = index
	
	match index:
		0:
			%TwentyFiveVBox.hide()
			%SilverLocVBox.show()
			%LocationPanel.reset_size()
		1:
			%SilverLocVBox.hide()
			%TwentyFiveVBox.show()
			%LocationPanel.reset_size()


func _on_silver_loc_bg_color_color_changed(color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	silver_location_stylebox.bg_color = color


func _on_silver_loc_text_color_color_changed(color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	silver_location_label_settings.font_color = color


func _on_twenty_five_line_color_color_changed(color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	twenty_five_location_line.color = color
	
	if %TwentyFiveSame.button_pressed:
		%TwentyFiveTextColor.color = color


func _on_twenty_five_text_color_color_changed(color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	twenty_five_label_settings.font_color = color


func _on_twenty_five_same_toggled(button_pressed):
	if button_pressed:
		%TwentyFiveTextColor.color = %TwentyFiveLineColor.color
		%TwentyFiveTextColor.disabled = true
	else:
		%TwentyFiveTextColor.disabled = false


func _on_menu_bar_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			right_click_location = null


func _on_save_theme_button_pressed():
	%ThemeLineEdit.clear()
	$ThemePopupPanel.popup_centered()
	%ThemeLineEdit.grab_focus()


func _on_theme_line_edit_text_submitted(new_text):
	if editor_theme.theme_dict.has(new_text):
		$ThemeAcceptDialog.popup_centered()
	else:
		editor_theme.theme_dict[new_text] = {
			"border width": border_width_spinbox.value,
			"frame width": frame_width_spinbox.value,
			"border color": border_color_button.color,
			"frame color": frame_color_button.color,
			"name color": name_color_button.color,
			"wipe color": wipe_color_button.color,
			"box bg color": box_bg_color.color,
			"text color": text_color.color,
			"cursor color": cursor_color.color,
			"silver location bg": silver_loc_bg_color.color,
			"silver location text": silver_loc_text_color.color,
			"twenty-five line color": twenty_five_line_color.color,
			"twenty-five text color": twenty_five_text_color.color,
			"bg dict": bg_dict,
		}
		
		ResourceSaver.save(editor_theme, "res://resources/Data/visual_editor_theme.tres")
		$ThemePopupPanel.hide()
		
		%ThemeOptionButton.add_item(new_text)
		%ThemeOptionButton.select(%ThemeOptionButton.get_item_count() - 1)
		%ThemeOptionButton.item_selected.emit(%ThemeOptionButton.selected)


func _on_theme_option_button_item_selected(index):
	if index == 0: # None selected
		pass
	else:
		var theme_name = theme_option_button.get_item_text(index)
		var theme_dict = editor_theme.theme_dict[theme_name]
		
		border_width_spinbox.value = theme_dict["border width"]
		frame_width_spinbox.value = theme_dict["frame width"]
		border_color_button.color = theme_dict["border color"]
		border_color_button.color_changed.emit(border_color_button.color)
		frame_color_button.color = theme_dict["frame color"]
		frame_color_button.color_changed.emit(frame_color_button.color)
		name_color_button.color = theme_dict["name color"]
		name_color_button.color_changed.emit(name_color_button.color)
		wipe_color_button.color = theme_dict["wipe color"]
		wipe_color_button.color_changed.emit(wipe_color_button.color)
		box_bg_color.color = theme_dict["box bg color"]
		box_bg_color.color_changed.emit(box_bg_color.color)
		text_color.color = theme_dict["text color"]
		text_color.color_changed.emit(text_color.color)
		cursor_color.color = theme_dict["cursor color"]
		silver_loc_bg_color.color = theme_dict["silver location bg"]
		silver_loc_bg_color.color_changed.emit(silver_loc_bg_color.color)
		silver_loc_text_color.color = theme_dict["silver location text"]
		silver_loc_text_color.color_changed.emit(silver_loc_text_color.color)
		twenty_five_line_color.color = theme_dict["twenty-five line color"]
		twenty_five_line_color.color_changed.emit(twenty_five_line_color.color)
		twenty_five_text_color.color = theme_dict["twenty-five text color"]
		twenty_five_text_color.color_changed.emit(twenty_five_text_color.color)
		load_bg_dict(theme_dict["bg dict"])
		
		theme_option_button.selected = index


func _on_remove_theme_button_pressed():
	var current_theme = theme_option_button.get_selected()
	
	if current_theme != 0:
		var current_theme_name = theme_option_button.get_item_text(current_theme)
		theme_option_button.select(0)
		theme_option_button.remove_item(current_theme)
		editor_theme.theme_dict.erase(current_theme_name)
		ResourceSaver.save(editor_theme, "res://resources/Data/visual_editor_theme.tres")
		reset_colors_widths()


func _on_tree_exiting():
	add_to_recent_files(current_file.text)


func _on_background_button_toggled(button_pressed):
	if button_pressed:
		background_panel.position = (
				background_button.global_position 
				+ Vector2(background_button.size.x / 2, background_button.size.y + 5) 
				- Vector2(background_panel.size.x / 2, 0)
		)
		background_panel.popup()
	else:
		background_panel.hide()


func _on_background_panel_popup_hide():
	if background_button.button_pressed:
		background_button.button_pressed = false


func _on_bg_type_item_selected(index):
	set_bg_dict("type", index)
	
	match index:
		0:
			solid_color_h_box.show()
			grad_color_v_box.hide()
			texture_v_box.hide()
			background_panel.reset_size()
		1:
			solid_color_h_box.hide()
			grad_color_v_box.show()
			texture_v_box.hide()
			background_panel.reset_size()
		2:
			solid_color_h_box.hide()
			grad_color_v_box.hide()
			texture_v_box.show()
			background_panel.reset_size()


func _on_bg_animation_item_selected(index):
	set_bg_dict("animation", index)
	
	match index:
		0:
			anim_color_h_box.hide()
			line_color_v_box.hide()
			ripple_delay_h_box.hide()
			background_panel.reset_size()
		4:
			anim_color_h_box.hide()
			line_color_v_box.show()
			ripple_delay_h_box.hide()
			background_panel.reset_size()
		5:
			anim_color_h_box.show()
			line_color_v_box.hide()
			ripple_delay_h_box.show()
			background_panel.reset_size()
		_:
			anim_color_h_box.show()
			line_color_v_box.hide()
			ripple_delay_h_box.hide()
			background_panel.reset_size()


func _on_solid_color_color_changed(color):
	set_bg_dict("solid color", color.to_html())


func _on_grad_top_color_color_changed(color):
	set_bg_dict("top color", color.to_html())


func _on_grad_bott_color_color_changed(color):
	set_bg_dict("bott color", color.to_html())


func _on_bg_path_text_changed(new_text):
	set_bg_dict("path", new_text)


func _on_anim_color_color_changed(color):
	set_bg_dict("anim color", color.to_html())


func _on_line_color_1_color_changed(color):
	set_bg_dict("line color 1", color.to_html())


func _on_line_color_2_color_changed(color):
	set_bg_dict("line color 2", color.to_html())


func _on_line_color_3_color_changed(color):
	set_bg_dict("line color 3", color.to_html())


func _on_line_color_4_color_changed(color):
	set_bg_dict("line color 4", color.to_html())


func _on_open_bg_pressed():
	$BGTextureFileDialog.popup_centered()


func _on_bg_texture_file_dialog_file_selected(path):
	bg_path.text = path
	bg_path.text_changed.emit(bg_path.text)


func _on_clear_bg_pressed():
	bg_path.text = ""
	bg_path.text_changed.emit(bg_path.text)


func _on_grad_top_offset_value_changed(value):
	set_bg_dict("top offset", value)
	if grad_top_slider.value != value:
		grad_top_slider.value = value


func _on_grad_top_slider_value_changed(value):
	if grad_top_offset.value != value:
		grad_top_offset.value = value


func _on_grad_bott_offset_value_changed(value):
	set_bg_dict("bott offset", value)
	if grad_bott_slider.value != value:
		grad_bott_slider.value = value


func _on_grad_bott_slider_value_changed(value):
	if grad_bott_offset.value != value:
		grad_bott_offset.value = value


func _on_ripple_delay_value_changed(value):
	set_bg_dict("ripple delay", value)


func _on_box_bg_color_color_changed(color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	window_stylebox.bg_color = color
	for panel_cont in get_tree().get_nodes_in_group("window_panel_containers"):
		panel_cont.get_theme_stylebox("panel").bg_color = color


func _on_text_color_color_changed(color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
	
	window_theme.set_color("default_color", "RichTextLabel", color)
#	for panel_cont in get_tree().get_nodes_in_group("window_panel_containers"):
#		panel_cont.get_parent().theme.set_color("default_color", "RichTextLabel", color)


func _on_cursor_color_color_changed(_color):
	theme_option_button.selected = 0
	theme_option_button.item_selected.emit(theme_option_button.selected)
