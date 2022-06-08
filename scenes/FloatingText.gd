extends Position2D

onready var label=get_node("Label")
onready var tween=get_node("Tween" )

signal text_disappear
var text=""


func _ready():
	self.transform.origin=Globals.vector2_center
	label.set_text(text)
	tween.interpolate_property(self, 'scale',Vector2(0.5,0.5) ,Vector2(2,2),3,Tween.TRANS_LINEAR,Tween.EASE_OUT )
	#tween.interpolate_property(self, 'scale',Vector2(2,2) ,Vector2(1,1),4,Tween.TRANS_LINEAR,Tween.EASE_OUT , 1)
	tween.start()


func _on_Tween_tween_all_completed():
	self.queue_free()
	emit_signal("text_disappear")
