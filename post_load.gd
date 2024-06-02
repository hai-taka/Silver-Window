extends Control

var chapter_select = preload("res://chapter_select.tscn")
var menu_colors: Resource = preload("res://resources/Data/main_menu_colors.tres")
var allow_input: bool = false
var first_focus: bool = true
var selected_slot: PanelContainer = null

@onready var background = %Background
@onready var outer_margin = %OuterMargin
@onready var button_v_box = %ButtonVBox
@onready var continue_button = %ContinueButton
@onready var chapter_select_button = %ChapterSelectButton


func _ready():
	for button in button_v_box.get_children():
		if button is Button:
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
			button.focus_entered.connect(_on_button_focus_entered)
	
	button_v_box.hide()
	outer_margin.add_theme_constant_override("margin_left", 0)
	outer_margin.add_theme_constant_override("margin_top", 0)
	outer_margin.add_theme_constant_override("margin_right", 0)
	outer_margin.add_theme_constant_override("margin_bottom", 0)
	
	#await get_tree().create_timer(1.0).timeout
	await shrink_box()
	await reveal_buttons()
	continue_button.grab_focus()
	first_focus = false
	allow_input = true


func reveal_buttons(delay: float = 0.05) -> void:
	for button in button_v_box.get_children():
		if button is Button:
			button.disabled = true
			button.focus_mode = Control.FOCUS_NONE
			#button.hide()
	
	button_v_box.show()
	for button in button_v_box.get_children():
		if button is Button:
			#button.show()
			button.disabled = false
			button.focus_mode = Control.FOCUS_ALL
			await get_tree().create_timer(delay).timeout


func shrink_box(frames: int = 13) -> void:
	var tween = create_tween().set_parallel()
	var v_final_value: int = 275
	var h_final_value: int = 400
	var duration: float = frames / 60.0
	
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_left", h_final_value, duration
	)
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_right", h_final_value, duration
	)
	tween.chain().tween_property(
			outer_margin, "theme_override_constants/margin_top", v_final_value, duration
	)
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_bottom", v_final_value, duration
	)
	
	await tween.finished
	tween.kill()


func undo_shrink_box(frames: int = 13) -> void:
	var tween = create_tween().set_parallel()
	var v_final_value: int = 0
	var h_final_value: int = 0
	var duration: float = frames / 60.0
	
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_top", v_final_value, duration
	)
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_bottom", v_final_value, duration
	)
	tween.chain().tween_property(
			outer_margin, "theme_override_constants/margin_left", h_final_value, duration
	)
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_right", h_final_value, duration
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
	if not allow_input:
		return
	
	if event.is_action_pressed("ui_cancel"):
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.CANCEL)
		button_v_box.hide()
		await undo_shrink_box()
		
		if get_parent() == get_tree().root:
			get_tree().quit()
		else:
			selected_slot.grab_focus()
			get_parent().first_focus = false
			get_parent().allow_input = true
			queue_free()


func _on_button_mouse_entered(button: Button):
	if allow_input:
		button.grab_focus()


func _on_button_focus_entered():
	if not first_focus:
		SoundManager.play_ui_sound(SoundManager.UI_TYPE.FOCUS)


func _on_continue_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.SPECIAL)
	allow_input = false
	chapter_select_button.disabled = true
	chapter_select_button.focus_mode = Control.FOCUS_NONE
	continue_button.disabled = true
	continue_button.get_child(0).show()
	continue_button.get_child(0).text = (
			"[shake rate=30.0 level=20 connected=0][center]Continue[/center][/shake]"
	)
	continue_button.get_child(0).add_theme_color_override(
			"default_color", menu_colors.shake_color
	)
	
	SoundManager.stop_main_menu_music()
	
	if GlobalData.first_script_list.has(DialogueManager.dialogue_script_file_path):
		var cur: int = GlobalData.first_script_list.find(DialogueManager.dialogue_script_file_path)
		GlobalData.current_chapter = cur
		TransitionManager.fade_to_scene("res://title_card.tscn")
	else:
		TransitionManager.fade_to_scene("res://main1.tscn")


func _on_chapter_select_button_pressed():
	if not allow_input:
		return
	
	SoundManager.play_ui_sound(SoundManager.UI_TYPE.CONFIRM)
	
	var chapter_select_instance = chapter_select.instantiate()
	allow_input = false
	first_focus = true
	chapter_select_button.release_focus()
	add_child(chapter_select_instance)
