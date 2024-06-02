@tool
extends RichTextEffect
class_name RichTextRain2
# Code adapted from teebarjunk on github

# Syntax: [rain2][/rain2]
var bbcode = "rain2"


func get_rand(char_fx):
	return fmod(get_rand_unclamped(char_fx), 1.0)


func get_rand_unclamped(char_fx):
	return char_fx.glyph_index * 33.33 + char_fx.relative_index * 4545.5454


func _process_custom_fx(char_fx):
	var time = char_fx.elapsed_time
	var r = get_rand(char_fx)
	var t = fmod(r + time * 0.25, 1.0)
	char_fx.offset.y += t * 80.0
	char_fx.color = lerp(char_fx.color, Color.TRANSPARENT, t)
	return true
