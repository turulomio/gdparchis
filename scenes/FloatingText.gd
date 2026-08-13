extends Marker2D

@onready var label = get_node("Label")

signal text_disappear
var showing: bool = false


## Node ready initialization callback.
func _ready():
	if Engine.is_editor_hint():
		self.show_text("This is a floating text", Color.GREEN)


## Displays floating notification text in the center of the viewport with a scale tween.
## @param text Message string to display.
## @param color Text font color.
func show_text(text, color):
	if self.showing == false:
		self.visible = true
		self.transform.origin = self.vector2_viewport_center()
		self.label.set("theme_override_colors/font_color", color)
		label.set_text(str(text))
		
		# Animate label scale up over 2.5 seconds
		var tween = create_tween()
		self.label.scale = Vector2(0.1, 0.1)
		tween.tween_property($Label, 'scale', Vector2(1.3, 1.3), 2.5).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		await tween.finished
		
		self.visible = false
		emit_signal("text_disappear")


## Calculates and returns the 2D center coordinates of the current viewport rectangle.
## @return Vector2 center position.
func vector2_viewport_center() -> Vector2:
	var window_width = get_viewport_rect().size.x
	var window_height = get_viewport_rect().size.y
	return Vector2(window_width / 2, window_height / 2)
