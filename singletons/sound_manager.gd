extends Node

signal fade_out_finished

enum UI_TYPE {
	FOCUS,
	CONFIRM,
	SPECIAL,
	CANCEL,
}

var current_bg_player: AudioStreamPlayer
var available_bg_player: AudioStreamPlayer

@onready var typing_sound_pool = $TypingSoundPool
@onready var end_beep_sound_pool = $EndBeepSoundPool
@onready var main_menu_music = $MainMenuMusic
@onready var picture_sound = $PictureSound
@onready var background_music = $BackgroundMusic
@onready var background_music_2 = $BackgroundMusic2
@onready var ui_focus_sound = $UIFocusSound
@onready var ui_confirm_sound = $UIConfirmSound
@onready var ui_special_confirm_sound = $UISpecialConfirmSound
@onready var ui_cancel_sound = $UICancelSound
@onready var first_pic_text_appear = $FirstPicTextAppear
@onready var first_pic_text_disappear = $FirstPicTextDisappear
@onready var location_sound = $"25LocationSound"
@onready var curtain_sound = $CurtainSound
@onready var end_card_chapter_reveal = $EndCardChapterReveal
@onready var end_card_music = $EndCardMusic
@onready var new_chapter_unlock = $NewChapterUnlock
@onready var final_end_card = $FinalEndCard


func _ready():
	current_bg_player = background_music
	available_bg_player = background_music_2


func play_final_music() -> void:
	final_end_card.play()


func play_new_chapter_unlock_sound() -> void:
	new_chapter_unlock.play()
	await new_chapter_unlock.finished


func play_end_card_sound() -> void:
	end_card_chapter_reveal.play()
	await end_card_chapter_reveal.finished
	end_card_music.play()


func play_curtain_sound() -> void:
	curtain_sound.play()


func play_location_sound(fade: bool = true) -> void:
	if fade:
		fade_in(location_sound, 0.5)
	#location_sound.play()


func stop_location_sound(fade: bool = true) -> void:
	if location_sound.playing:
		if fade:
			fade_out(location_sound, 0.1)
			await fade_out_finished
		else:
			location_sound.stop()


func play_first_pic_appear() -> void:
	first_pic_text_appear.play()


func stop_first_pic_appear() -> void:
	if first_pic_text_appear.playing:
		first_pic_text_appear.stop()


func play_first_pic_disappear() -> void:
	first_pic_text_disappear.play()


func stop_first_pic_disappear() -> void:
	if first_pic_text_disappear.playing:
		first_pic_text_disappear.stop()


func play_ui_sound(type: UI_TYPE) -> void:
	var player: AudioStreamPlayer
	match type:
		UI_TYPE.FOCUS:
			player = ui_focus_sound
		UI_TYPE.CONFIRM:
			ui_focus_sound.stop()
			player = ui_confirm_sound
		UI_TYPE.SPECIAL:
			ui_focus_sound.stop()
			player = ui_special_confirm_sound
		UI_TYPE.CANCEL:
			ui_focus_sound.stop()
			player = ui_cancel_sound
	
	if player.playing:
		player.stop()
	
	player.play()


func play_background_music(sound_path: String, crossfade: bool = true, duration: float = 1.0) -> void:
	if not current_bg_player.playing:
		crossfade = false
	
	if not crossfade:
		if current_bg_player.playing:
			current_bg_player.stop()
		if sound_path != "":
			current_bg_player.stream = load(sound_path)
			current_bg_player.play()
	else:
		fade_out(current_bg_player, duration)
		if sound_path != "":
			available_bg_player.stream = load(sound_path)
			fade_in(available_bg_player, duration)
		
		var holder: AudioStreamPlayer = current_bg_player
		current_bg_player = available_bg_player
		available_bg_player = holder


func stop_background_music(fade_out_sound: bool = true, duration: float = 3.0) -> void:
	if fade_out_sound:
		fade_out(current_bg_player, duration)
		await fade_out_finished
	else:
		current_bg_player.stop()


func play_picture_sound(sound_path: String) -> void:
	picture_sound.stream = load(sound_path)
	
	var original_vol = current_bg_player.volume_db
	if current_bg_player.playing:
		current_bg_player.volume_db -= 6
	
	picture_sound.play()
	await picture_sound.finished
	
	if current_bg_player.playing:
		current_bg_player.volume_db = original_vol


func stop_picture_sound() -> void:
	if picture_sound.playing:
		picture_sound.stop()


func play_typing_sound(random: bool = true) -> void:
	if typing_sound_pool.is_playing():
		return
	
	if random:
		typing_sound_pool.play_random_sound()
	else:
		typing_sound_pool.play_next_sound()


func stop_typing_sound() -> void:
	typing_sound_pool.stop_sound()


func play_end_beep(random: bool = true) -> void:
	for child in end_beep_sound_pool.get_children():
		if child is AudioStreamPlayer:
			if child.playing:
				return
	
	if random:
		end_beep_sound_pool.play_random_sound()
	else:
		end_beep_sound_pool.play_next_sound()


func play_main_menu_music(fade_in_sound: bool = true) -> void:
	if fade_in_sound:
		fade_in(main_menu_music)
	else:
		main_menu_music.play()


func stop_main_menu_music(fade_out_sound: bool = true) -> void:
	if fade_out_sound:
		fade_out(main_menu_music)
	else:
		main_menu_music.stop()


func fade_in(player: AudioStreamPlayer, duration: float = 3.0) -> void:
	var tween = create_tween()
	var target_vol = player.volume_db
	
	player.volume_db = -36
	player.play()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(player, "volume_db", target_vol, duration)
	await tween.finished
	tween.kill()


func fade_out(player: AudioStreamPlayer, duration: float = 3.0) -> void:
	if not player.playing:
		#print("Player not playing.")
		return
	
	var current_level = player.volume_db
	var tween = create_tween()
	
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(player, "volume_db", -80, duration)
	await tween.finished
	tween.kill()
	player.stop()
	player.volume_db = current_level
	
	fade_out_finished.emit()
