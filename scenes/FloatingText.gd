extends Marker2D

@onready var label: Label = $PanelContainer/Label

signal text_disappear
var showing: bool = false


## Node ready initialization callback.
func _ready() -> void:
	# Keep node hidden on scene load until show_text is invoked
	self.visible = false
	if Engine.is_editor_hint():
		self.show_text("This is a floating text", Color.GREEN)


## Displays floating notification text with pop-in, float upward, and fade-out animations.
## @param text Message string to display.
## @param color Text font color.
## @param custom_position Optional custom Vector2 position to display text (defaults to viewport center).
func show_text(text: Variant, color: Color, custom_position: Variant = null) -> void:
	if self.showing == false:
		self.showing = true
		self.visible = true
		
		# Step 1: Reset opacity to fully visible
		self.modulate.a = 1.0
		
		# Step 2: Set target position (custom position or default viewport center)
		if custom_position != null and custom_position is Vector2:
			self.global_position = custom_position
		else:
			self.global_position = self.vector2_viewport_center()
		
		# Step 3: Configure font color, halved black outline size (10px), and text content
		self.label.set("theme_override_colors/font_color", color)
		self.label.set("theme_override_constants/outline_size", 10)
		self.label.set_text(str(text))
		
		# Step 4: Setup initial transform scale for pop-in bounce effect
		self.scale = Vector2(0.1, 0.1)
		var start_y: float = self.position.y
		
		# Step 5: Configure parallel Tween animation timeline
		var tween: Tween = create_tween().set_parallel(true)
		
		# Animate scale pop-in with elastic bounce curve (TRANS_BACK)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.35)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
			
		# Float text smoothly upward over 2.2 seconds
		tween.tween_property(self, "position:y", start_y - 70.0, 2.2)\
			.set_trans(Tween.TRANS_QUAD)\
			.set_ease(Tween.EASE_OUT)
			
		# Fade out opacity towards the end of floating animation
		tween.tween_property(self, "modulate:a", 0.0, 0.6)\
			.set_delay(1.6)\
			.set_trans(Tween.TRANS_LINEAR)
		
		# Step 6: Await animation completion and reset node state
		await tween.finished
		
		self.visible = false
		self.showing = false
		emit_signal("text_disappear")


## Calculates and returns the 2D center coordinates of the current viewport rectangle.
## @return Vector2 center position.
func vector2_viewport_center() -> Vector2:
	var window_width: float = get_viewport_rect().size.x
	var window_height: float = get_viewport_rect().size.y
	return Vector2(window_width / 2.0, window_height / 2.0)
