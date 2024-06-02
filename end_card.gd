extends Control

signal reveal_finished

@export var show_next: bool = true


func _ready():
	if GlobalData.current_chapter + 1 >= GlobalData.chapter_list.size():
		$EndBG.show()
		$EndContainer.show()
		SoundManager.play_final_music()
		
		await TransitionManager.transition_finished
		await get_tree().create_timer(5.0).timeout
		
		TransitionManager.fade_to_scene("res://post_end_card.tscn")
		return
	
	$ChapterLabel.text = GlobalData.chapter_list[GlobalData.current_chapter]
	$MoonPhrase.text = GlobalData.end_card_moon_phrase
	#$MoonPhrase.text = "[rain]" + GlobalData.end_card_moon_phrase + "[/rain]"
	$MoonPhrase.add_theme_color_override("default_color", GlobalData.end_card_moon_phrase_color)
	
	if GlobalData.current_chapter + 1 < GlobalData.chapter_list.size():
		var next_chapter_name: String = GlobalData.chapter_list[GlobalData.current_chapter + 1]
		$NextLabel.text = next_chapter_name + " is coming soon..."
	else:
		show_next = false
	
	$MoonTextureRect.self_modulate.h = GlobalData.end_card_moon_color.h
	
	$NextLabel.visible = show_next
	
	await TransitionManager.transition_finished
	await get_tree().create_timer(1.0).timeout
	
	SoundManager.play_end_card_sound()
	reveal_label($ChapterLabel)
	await reveal_finished
	
	if show_next:
		await get_tree().create_timer(2.0).timeout
		reveal_label($NextLabel)
		await reveal_finished
	
	if $MoonPhrase.text != "":
		await get_tree().create_timer(2.0).timeout
		await fade_in_phrase(2.0)
	
	await get_tree().create_timer(3.0).timeout
	TransitionManager.fade_to_scene("res://post_end_card.tscn")


func fade_in_phrase(duration: float = 1.0) -> void:
	$MoonPhrase.self_modulate.a = 0.0
	$MoonPhrase.show()
	
	var tween = create_tween()
	tween.tween_property($MoonPhrase, "self_modulate:a", 1.0, duration)
	await tween.finished
	tween.kill()
	
	#$MoonPhrase.text = GlobalData.end_card_moon_phrase


func reveal_label(label: Label, speed: int = 400) -> void:
	var color_rect = label.get_child(0)
	var distance = label.size.x
	var duration = distance / float(speed)
	var tween = create_tween()
	
	tween.tween_property(color_rect, "position:x", distance, duration)
	
	await tween.finished
	tween.kill()
	
	reveal_finished.emit()
