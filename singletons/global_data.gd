extends Node

enum {NONE, CURTAIN_WIPE, FADE}

var running_from_editor: bool = false
var first_script: bool = true
var transitioning: bool = false

var old_locations: Dictionary = {}
var old_locations_to_show: Array = []
var previous_transition: int = -1

var chapter_list: Array[String] = [
	"Textbox Demo",
	"Picture Demo",
	"Other Stuff",
]
var first_script_list: Array[String] = [
	"res://JSONs/demo/textbox_demo/demo-1.json",
	"res://JSONs/demo/picture_demo/picture-demo-1.json",
	"res://JSONs/demo/other_stuff/other-stuff-1.json",
]

var current_chapter: int = 0
var furthest_chapter: int = 0
var game_completed: bool = false

var play_time_at_load: Dictionary = {
	"hours": 0,
	"minutes": 0,
	"seconds": 0,
}
var unix_time_at_load: float = 0.0

var end_card_moon_color: Color = Color("c0c0c0")
var end_card_moon_phrase: String = ""
var end_card_moon_phrase_color: Color = Color("ffffff")


func initialize() -> void:
	first_script = true
	old_locations.clear()
	old_locations_to_show.clear()
	previous_transition = -1


func reset_play_time() -> void:
	set_play_time("hours", 0)
	set_play_time("minutes", 0)
	set_play_time("seconds", 0)


func set_play_time(key: String, value: int) -> void:
	if play_time_at_load.has(key):
		play_time_at_load[key] = value
	else:
		print("Key does not exist.")
