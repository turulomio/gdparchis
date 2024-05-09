extends Position2D

onready var label=get_node("Label")
onready var tween=get_node("Tween" )

signal text_disappear

func _on_Tween_tween_all_completed():
	emit_signal("text_disappear")
	self.visible=false


func show_text(text, color):
	label.add_color_override("font_color", color)
	self.visible=true
	self.transform.origin=self.vector2_viewport_center()
	label.set_text(str(text))
	tween.interpolate_property(self, 'scale',Vector2(0.5,0.5) ,Vector2(1.5,1.5),2.5,Tween.TRANS_LINEAR,Tween.EASE_OUT )
	tween.start()

## Returns the center of ther wiewport rect
func vector2_viewport_center() -> Vector2:
	var	window_width=get_viewport_rect().size.x
	var window_height=get_viewport_rect().size.y
	return Vector2(window_width/2,window_height/2)
