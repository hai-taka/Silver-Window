#@tool
extends RichTextEffect
class_name RichTextSink

# Syntax: [sink speed=5.0 height=100.0 spread=100.0][/sink]
var bbcode = "sink"
var whtsp_count = 0


func _process_custom_fx(char_fx):
	var time = char_fx.elapsed_time
	var speed = char_fx.env.get("speed", 5.0)
	var height = char_fx.env.get("height", 100.0)
	var spread = char_fx.env.get("spread", 100.0)
	
	if char_fx.relative_index == 0:
		whtsp_count = 0
	
	if char_fx.glyph_flags == 41:
		whtsp_count += 1
	
	char_fx.offset.y += speed * time * height - (char_fx.relative_index - whtsp_count) * spread
	
	if char_fx.offset.y < 0:
		char_fx.offset.y = 0
	else:
		var t = char_fx.offset.y / height
		char_fx.color = lerp(char_fx.color, Color.TRANSPARENT, t)
	
	if char_fx.offset.y > height:
		char_fx.offset.y = height
		char_fx.color = Color.TRANSPARENT
	
	return true
