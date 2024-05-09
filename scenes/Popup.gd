extends Popup

#onready var rich=$Panel/RichTextLabel
#onready var rich=$Panel/RichTextLabel

func set_text(t):
	$Panel/RichTextLabel.text=t
	self.popup()
