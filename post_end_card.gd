extends Control

var menu_colors: Resource = preload("res://resources/Data/main_menu_colors.tres")
var menu_popup = preload("res://menu_popup.tscn")
var file_select = preload("res://file_select.tscn")
var chapter_select = preload("res://chapter_select.tscn")

var game_finished: bool = false
var new_chapter_unlocked: bool = false

@onready var background = %Background
@onready var outer_margin = %OuterMargin
@onready var temp_panel = %TempPanel


func _ready():
	if GlobalData.current_chapter + 1 < GlobalData.chapter_list.size():
		if GlobalData.current_chapter + 1 > GlobalData.furthest_chapter:
			GlobalData.furthest_chapter = GlobalData.current_chapter + 1
			new_chapter_unlocked = true
		
		var next = GlobalData.first_script_list[GlobalData.current_chapter + 1]
		DialogueManager.change_script(next)
		
	else:
		game_finished = true
		GlobalData.game_completed = true
		
		var next = GlobalData.first_script_list[0]
		DialogueManager.change_script(next)
	
	background.color = menu_colors.bg_color
	
	if GlobalData.transitioning:
		await TransitionManager.transition_finished
	
	var menu_popup_instance = menu_popup.instantiate()
	menu_popup_instance.message_size = 36
	menu_popup_instance.button_size = 32
	menu_popup_instance.line_1_text = "Save?"
	menu_popup_instance.expand_on_ready = true
	menu_popup_instance.size_after_expand = Vector2i(480, 0)
	add_child(menu_popup_instance)
	
	var confirm: bool = await menu_popup_instance.choice_made
	
	if confirm:
		await adjust_margin(menu_popup_instance.popup_panel.size, Vector2i(1280, 720))
		var file_select_instance = file_select.instantiate()
		file_select_instance.load_menu = false
		file_select_instance.post_end_card = true
		add_child(file_select_instance)
		
		await file_select_instance.tree_exited
		
		if not game_finished:
			await adjust_margin(Vector2i(1280, 720), Vector2i(480, 720))
	else:
		if not game_finished:
			await adjust_margin(menu_popup_instance.popup_panel.size, Vector2i(480, 720))
		
	if not game_finished:
		var chapter_select_instance = chapter_select.instantiate()
		chapter_select_instance.post_end_card = true
		chapter_select_instance.new_chapter_unlocked = new_chapter_unlocked
		add_child(chapter_select_instance)
	else:
		TransitionManager.fade_to_scene("res://main_menu.tscn", 1.0)


func adjust_margin(initial_size: Vector2i, final_size: Vector2i, frames: int = 13) -> void:
	var tween = create_tween().set_parallel()
	var dur = frames / 60.0
	var initial_marg_left = (1280 - initial_size.x) / 2.0
	var initial_marg_right = 1280 - initial_size.x - initial_marg_left
	var initial_marg_top = (720 - initial_size.y) / 2.0
	var initial_marg_bott = 720 - initial_size.y - initial_marg_top
	
	var final_marg_left = (1280 - final_size.x) / 2.0
	var final_marg_right = 1280 - final_size.x - final_marg_left
	var final_marg_top = (720 - final_size.y) / 2.0
	var final_marg_bott = 720 - final_size.y - final_marg_top
	
	outer_margin.add_theme_constant_override("margin_left", initial_marg_left)
	outer_margin.add_theme_constant_override("margin_right", initial_marg_right)
	outer_margin.add_theme_constant_override("margin_top", initial_marg_top)
	outer_margin.add_theme_constant_override("margin_bottom", initial_marg_bott)
	
	outer_margin.show()
	
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_left", final_marg_left, dur
	)
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_right", final_marg_right, dur
	)
	tween.chain().tween_property(
			outer_margin, "theme_override_constants/margin_top", final_marg_top, dur
	)
	tween.tween_property(
			outer_margin, "theme_override_constants/margin_bottom", final_marg_bott, dur
	)
	await tween.finished
	tween.kill()
	
