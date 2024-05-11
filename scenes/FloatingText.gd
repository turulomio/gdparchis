@tool
extends Marker2D

@onready var label=get_node("Label")

var tween
signal text_disappear

func _on_Tween_tween_all_completed():
	emit_signal("text_disappear")
	self.visible=false


func show_text(text, color):
	label.set("theme_override_colors/font_color", color)
	self.visible=true
	self.transform.origin=self.vector2_viewport_center()
	label.set_text(str(text))
	self.tween=create_tween()
	self.tween.tween_property(self, 'scale' ,Vector2(1.5,1.5),2.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT )
	#self.tween.start()

## Returns the center of ther wiewport rect
func vector2_viewport_center() -> Vector2:
	var	window_width=get_viewport_rect().size.x
	var window_height=get_viewport_rect().size.y
	return Vector2(window_width/2,window_height/2)
