extends Popup

@onready var rich = $RichTextLabel


## Displays popup window with specified text.
## @param t Text string to set.
func set_text(t):
	rich.clear()
	rich.text = t
	self.popup()
