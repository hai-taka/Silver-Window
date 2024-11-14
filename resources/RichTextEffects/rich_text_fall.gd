#@tool
extends RichTextEffect
class_name RichTextFall

# Syntax: [fall speed=5.0 height=100.0 spread=100.0][/fall]
var bbcode = "fall"
var whtsp_count = 0


func _process_custom_fx(char_fx):
	var time = char_fx.elapsed_time
	var regular_color = char_fx.color
	var speed = char_fx.env.get("speed", 5.0)
	var height = char_fx.env.get("height", 100.0)
	var spread = char_fx.env.get("spread", 100.0)
	
	if char_fx.relative_index == 0:
		whtsp_count = 0
	
	if char_fx.glyph_flags == 41:
		whtsp_count += 1
	
	char_fx.offset.y += speed * time * height - height - (char_fx.relative_index - whtsp_count) * spread
	
	if char_fx.offset.y < -height:
		char_fx.color = Color.TRANSPARENT
	else:
		var t = (char_fx.offset.y / height) + 1
		char_fx.color = lerp(Color.TRANSPARENT, char_fx.color, t)
	
	if char_fx.offset.y > 0:
		char_fx.offset.y = 0
		char_fx.color = regular_color
	
	return true
