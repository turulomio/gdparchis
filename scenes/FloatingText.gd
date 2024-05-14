extends Marker2D

@onready var label=get_node("Label")

signal text_disappear
var showing:bool=false

func _ready():
	if Engine.is_editor_hint():
		self.show_text("This is a floating text", Color.GREEN)

func show_text(text, color):
	# print("Starting to show ", text, color)
	if self.showing==false:
		self.visible=true
		self.transform.origin=self.vector2_viewport_center()
		self.label.set("theme_override_colors/font_color", color)
		label.set_text(str(text))
		var tween=create_tween()
		self.label.scale=Vector2(0.1,0.1)
		tween.tween_property($Label, 'scale' ,Vector2(1.3,1.3),2.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT )
		await tween.finished
		self.visible=false
		emit_signal("text_disappear")

## Returns the center of ther wiewport rect
func vector2_viewport_center() -> Vector2:
	var	window_width=get_viewport_rect().size.x
	var window_height=get_viewport_rect().size.y
	return Vector2(window_width/2,window_height/2)
