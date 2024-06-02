extends Control

@onready var chapter_number = %ChapterNumber
@onready var chapter_name = %ChapterName


func _ready():
	chapter_number.text = "#" + str(GlobalData.current_chapter + 1)
	chapter_name.text = GlobalData.chapter_list[GlobalData.current_chapter]
	
	await TransitionManager.transition_finished
	await get_tree().create_timer(2.0).timeout
	TransitionManager.fade_to_scene("res://main1.tscn")
