extends Popup

@onready var rich = $RichTextLabel


## Node initialization callback ensuring popup is hidden on scene start.
func _ready():
	self.visible = false


## Displays popup window with specified text.
## @param t Text string to set.
func set_text(t):
	rich.clear()
	rich.text = t
	self.popup()
