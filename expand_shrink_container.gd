extends MarginContainer

signal expanded
signal expand_started
signal audio_timer_finished

@export var tween_frames : int = 13

var waiting_to_expand = true
var expanding = false
var shrinking = false
var final_window = false

var change_bgm: bool = false
var sound_path: String = ""

@onready var DialogueContainer = $DialogueContainer
@onready var DialoguePadding = $DialogueContainer/DialoguePadding
@onready var Dialogue = $DialogueContainer/DialoguePadding/Dialogue
@onready var border_left = $DialogueContainer.get_theme_stylebox("panel").border_width_left
@onready var border_top = $DialogueContainer.get_theme_stylebox("panel").border_width_top
@onready var border_right = $DialogueContainer.get_theme_stylebox("panel").border_width_right
@onready var border_bottom = $DialogueContainer.get_theme_stylebox("panel").border_width_bottom

@onready var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	reset_size()
	hide()
	
	if main.fading_in and not Dialogue.blank:
		await main.fading_in_picture_window.get_node("ExpandShrinkContainer/PictureContainer/Control/PictureRect").fade_in_finished
		
		if (
				main.picture_playing_sound != null 
				and main.picture_playing_sound.get_child(0).await_sound and not Dialogue.blank
		):
			await SoundManager.picture_sound.finished
		
	elif (
			main.picture_playing_sound != null 
			and main.picture_playing_sound.get_child(0).await_sound and not Dialogue.blank
		):
		await SoundManager.picture_sound.finished
	elif main.pic_to_show != null and not Dialogue.blank:
		await main.pic_to_show.get_child(0).expanded
	
	if main.fading_out:
		await main.fading_out_picture_window.tree_exited
	
	elif main.pic_to_close != null:
		await main.pic_to_close.tree_exited
	
	if main.moving_pic != null:
		await main.moving_pic.move_completed
		main.moving_pic = null
	
	if main.changing_pic != null:
		if main.non_zero_delay:
			await main.changing_pic.change_completed
			main.non_zero_delay = false
		
		main.changing_pic = null
	
	waiting_to_expand = false
	expand()
	#print("expand called")


func set_all_margins(left : int, top : int, right : int, bottom : int):
	add_theme_constant_override("margin_left", left)
	add_theme_constant_override("margin_top", top)
	add_theme_constant_override("margin_right", right)
	add_theme_constant_override("margin_bottom", bottom)


func expand():
	expanding = true
	emit_signal("expand_started")
	
	var full_size = size
	var left_marg = (full_size.x / 2) - border_left
	var right_marg = (full_size.x / 2) - border_right
	var top_marg = (full_size.y / 2) - border_top
	var bottom_marg = (full_size.y / 2) - border_bottom
	
	DialoguePadding.hide()
	set_all_margins(left_marg, top_marg, right_marg, bottom_marg)
	show()
	
	var tween = create_tween()
	var tween_time = tween_frames/60.0
	
	tween.set_parallel()
	tween.tween_property(self, "theme_override_constants/margin_left", 0, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_top", 0, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_right", 0, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_bottom", 0, tween_time)
	
#	var audio_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
#	#print(audio_delay)
#	if audio_delay >= 0:
#		await get_tree().create_timer(tween_time - audio_delay).timeout
#	else:
#		await get_tree().create_timer(tween_time - 0.15).timeout
#
#	audio_timer_finished.emit()
	
	await tween.finished
	tween.kill()
	
	DialoguePadding.show()
	expanding = false
	
	if change_bgm:
		SoundManager.play_background_music(sound_path)
	
	emit_signal("expanded")


func shrink():
	shrinking = true
	
	var full_size = size
	var left_marg = (full_size.x / 2) - border_left
	var right_marg = (full_size.x / 2) - border_right
	var top_marg = (full_size.y / 2) - border_top
	var bottom_marg = (full_size.y / 2) - border_bottom
	
	DialoguePadding.hide()
	set_all_margins(0, 0, 0, 0)
	
	var tween = create_tween()
	var tween_time = tween_frames/60.0
	
	tween.set_parallel()
	tween.tween_property(self, "theme_override_constants/margin_left", left_marg, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_top", top_marg, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_right", right_marg, tween_time)
	tween.tween_property(self, "theme_override_constants/margin_bottom", bottom_marg, tween_time)
	
	await tween.finished
	tween.kill()
	
	hide()
	shrinking = false
	$"..".queue_free()
	
	# What to do when dialogue script is finished
	if final_window:
		if not GlobalData.running_from_editor:
			if not main.active_pictures.is_empty():
				main.active_pictures.values()[0].get_child(0).final_window = true
			else:
				main.pull_up_all()
				#get_tree().quit()
		#else:
		#	get_parent().get_parent().get_node("ReturnButton").emit_signal("pressed")
