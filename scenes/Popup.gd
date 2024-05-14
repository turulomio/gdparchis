extends Popup

@onready var rich=$RichTextLabel



func set_text(t):
	rich.clear()
	rich.text=t
	self.popup()
