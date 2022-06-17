extends Position2D

onready var label=get_node("Label")
onready var tween=get_node("Tween" )

signal text_disappear

func _on_Tween_tween_all_completed():
	emit_signal("text_disappear")
	self.visible=false


func show_text(text,color, _wait):
	$Label.add_color_override("font_color", color)
	self.visible=true
	self.transform.origin=Globals.vector2_center
	label.set_text(str(color))
	tween.interpolate_property(self, 'scale',Vector2(0.5,0.5) ,Vector2(2,2),3,Tween.TRANS_LINEAR,Tween.EASE_OUT )
	tween.start()
	if _wait==true:
		yield(self,"text_disappear")
