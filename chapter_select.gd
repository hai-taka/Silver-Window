extends Control

signal chapter_list_shown

@export var new_chapter_color: Color

var menu_colors: Resource = preload("res://resources/Data/main_menu_colors.tres")
var allow_input: bool = false
var first_focus: bool = true
var post_end_card: bool = false
var new_chapter_unlocked: bool = false

@onready var outer_margin = %OuterMargin
@onready var inner_margin = %InnerMargin
@onready var chapter_vbox = %ChapterVBox
@onready var end_hsep = %EndHSep
@onready var back_button = %BackButton
@onready var chapter_panel = %ChapterPanel
@onready var background = %Background
@onready var bg_color = menu_colors.bg_color


func _ready():
	background.color = bg_color
	back_button.mouse_entered.connect(_on_chapter_item_mouse_entered.bind(back_button))
	back_button.focus_entered.connect(_on_chapter_item_focus_entered.bind(back_button))
	end_hsep.hide()
	back_button.hide()
	
	if not post_end_card:
		inner_margin.hide()
		outer_margin.add_theme_constant_override("margin_top", 275)
		outer_margin.add_theme_constant_override("margin_bottom", 275)
		await expand_box()
		inner_margin.show()
	else:
		back_button.text = "Main Menu"
	
	await grow_hsep()
	var delay: float = 0.05
	populate_chapters(delay)
	await chapter_list_shown
	back_button.show()
	
	back_button.focus_neighbor_bottom = chapter_vbox.get_child(0).get_child(0).get_path()
	back_button.focus_next = chapter_vbox.get_child(0).get_child(0).get_path()
	back_button.focus_neighbor_top = chapter_vbox.get_child(-1).get_child(0).get_path()
	back_button.focus_previous = chapter_vbox.get_child(-1).get_child(0).get_path()
	
	var chapter_buttons = get_tree().get_nodes_in_group("chapter_buttons")
	for i in chapter_buttons.size():
		var button = chapter_buttons[i]
		
		if i == 0:
			button.focus_neighbor_top = back_button.get_path()
			button.focus_previous = button.focus_neighbor_top
		else:
			button.focus_neighbor_top = chapter_buttons[i - 1].get_path()
			button.focus_previous = button.focus_neighbor_top
		
		if i == chapter_buttons.size() - 1:
			button.focus_neighbor_bottom = back_button.get_path()
			button.focus_next = button.focus_neighbor_bottom
		else:
			button.focus_neighbor_bottom = chapter_buttons[i + 1].get_path()
			button.focus_next = button.focus_neighbor_bottom
	
	await get_tree().create_timer(delay).timeout
	
	if not post_end_card:
		chapter_vbox.get_child(0).get_child(0).grab_focus()
	else:
		#var latest_index = chapter_vbox.get_child_count() - 1
		#chapter_vbox.get_child(latest_index).get_child(0).grab_focus()
		
		var next: int = GlobalData.current_chapter + 1
		chapter_vbox.get_child(next).get_child(0).grab_focus()
	
	first_focus = false
	allow_input = true


func grow_hsep(frames: int = 13) -> void:
	var tween = create_tween().set_parallel()
	var duration = frames / 60.0
	var stylebox: StyleBoxLine = end_hsep.get_theme_stylebox("separator")
	var initial_value = -376 / 2.0
	var sep_color: Color = menu_colors.border_color
	
	stylebox.color = sep_color
	stylebox.grow_begin = initial_value
	stylebox.grow_end = initial_value
	end_hsep.show()
	
	tween.tween_property(stylebox, "grow_begin", 1, duration).from(initial_value)
	tween.tween_property(stylebox, "grow_end", 1, duration).from(initial_value)
	
	await tween.finished
	tween.kill()


func populate_chapters(delay: float = 0.2) -> void:
	var count: int = 0
	
	for chapter in GlobalData.chapter_list:
		if count > GlobalData.furthest_chapter:
			break
		
		var hbox = HBoxContainer.new()
		hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		chapter_vbox.add_child(hbox)
		
		var chapter_button: Button = Button.new()
		chapter_button.text = chapter
		hbox.add_child(chapter_button)
		
		chapter_button.add_to_group("chapter_buttons")
		
		chapter_button.focus_neighbor_left = chapter_button.get_path()
		chapter_button.focus_neighbor_right = chapter_button.get_path()
		chapter_button.mouse_entered.connect(_on_chapter_item_mouse_entered.bind(chapter_button))
		chapter_button.focus_entered.connect(_on_chapter_item_focus_entered.bind(chapter_button))
		chapter_button.focus_exited.connect(_on_chapter_item_focus_exited.bind(chapter_button))
		chapter_button.pressed.connect(_on_chapter_item_pressed.bind(count))
		
		count += 1
		
		var rich_text_label = RichTextLabel.new()
		rich_text_label.bbcode_enabled = true
		rich_text_label.fit_content = true
		rich_text_label.scroll_active = false
		rich_text_label.autowrap_mode = TextServer.AUTOWRAP_OFF
		rich_text_label.text = chapter_button.text
		rich_text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chapter_button.add_child(rich_text_label)
		rich_text_label.hide()
		
		if post_end_card and new_chapter_unlocked and count > GlobalData.furthest_chapter:
			rich_text_label.text = (
					"[wave amp=25.0 freq=5.0 connected=0]" 
					+ rich_text_label.text 
					+ "[/wave]"
			)
			rich_text_label.add_theme_color_override(
						"default_color", 
						new_chapter_color
			)
			chapter_button.add_theme_color_override("font_color", Color.TRANSPARENT)
			chapter_button.add_theme_color_override("font_focus_color", Color.TRANSPARENT)
			chapter_button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
			chapter_button.add_theme_color_override("font_hover_pressed_color", Color.TRANSPARENT)
			chapter_button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
			
			rich_text_label.self_modulate.a = 0.0
			rich_text_label.show()
			SoundManager.play_new_chapter_unlock_sound()
			
			var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
			tween.tween_property(rich_text_label, "self_modulate:a", 1.0, 1.0)
			await tween.finished
			tween.kill()
		
		await get_tree().create_timer(delay).timeout
	
	chapter_list_shown.emit()


func shrink_box(frames: int = 13) -> void:
	var tween = create_tween().set_parallel()
	var final_value: int = 275
	var duration: float = frames / 60.0
	
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_top", final_value, duration
	)
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_bottom", final_value, duration
	)
	await tween.finished
	tween.kill()


func expand_box(frames: int = 13) -> void:
	var tween = create_tween().set_parallel()
	var final_value: int = 0
	var duration: float = frames / 60.0
	
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_top", final_value, duration
	)
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_bottom", final_value, duration
	)
	await tween.finished
	tween.kill()


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if not allow_input or post_end_card:
			return
		
		back_button.pressed.emit()


func _on_back_button_pressed():
	if not allow_input:
		return
	
	allow_input = false
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
	
	if not post_end_card:
		inner_margin.hide()
		await shrink_box()
	
	if get_parent() == get_tree().root:
		get_tree().quit()
	elif post_end_card:
		TransitionManager.fade_to_scene("res://main_menu.tscn", 1.0)
	else:
		get_parent().first_focus = true
		get_parent().chapter_select_button.grab_focus()
		get_parent().first_focus = false
		get_parent().allow_input = true
		queue_free()


func _on_chapter_item_mouse_entered(item):
	if allow_input:
		item.grab_focus()


func _on_chapter_item_focus_entered(item):
	if not first_focus:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)
	
	if post_end_card and new_chapter_unlocked:
		if item == get_tree().get_nodes_in_group("chapter_buttons").back():
			item.get_child(0).add_theme_color_override(
					"default_color", 
					new_chapter_color
			)


func _on_chapter_item_focus_exited(item):
	if post_end_card and new_chapter_unlocked:
		if item == get_tree().get_nodes_in_group("chapter_buttons").back():
			item.get_child(0).add_theme_color_override(
					"default_color", 
					menu_colors.button_reg_color
			)


func _on_chapter_item_pressed(index) -> void:
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.SPECIAL)
	allow_input = false
	for hbox in chapter_vbox.get_children():
		var button = hbox.get_child(0)
		if button is Button:
			if button != chapter_vbox.get_child(index).get_child(0):
				button.disabled = true
				button.focus_mode = Control.FOCUS_NONE
				button.get_child(0).hide()
			else:
				button.disabled = true
				button.get_child(0).show()
				button.get_child(0).text = (
						"[shake rate=30.0 level=20 connected=0]" 
						+ button.text 
						+ "[/shake]"
				)
				button.get_child(0).add_theme_color_override(
						"default_color", 
						menu_colors.shake_color
				)
		else:
			pass
	
	end_hsep.hide()
	back_button.hide()
	
	#await get_tree().process_frame
	
	GlobalData.current_chapter = index
	GlobalData.initialize()
	DialogueManager.change_script(GlobalData.first_script_list[index])
	TransitionManager.fade_to_scene("res://title_card.tscn")
	SoundManager.stop_main_menu_music()
