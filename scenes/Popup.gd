extends PopupPanel

@onready var rich: RichTextLabel = find_child("RichTextLabel", true, false)
@onready var title_lbl: Label = find_child("TitleLabel", true, false)
@onready var close_btn: Button = find_child("CloseButton", true, false)


## Node initialization callback hiding popup on scene start and connecting close button signal.
func _ready():
	self.visible = false
	if close_btn:
		if not close_btn.pressed.is_connected(hide_popup):
			close_btn.pressed.connect(hide_popup)


## Hides popup dialog window.
func hide_popup():
	self.hide()


## Displays popup window centered on screen with specified BBCode text content and title.
## @param content_text BBCode formatted text string.
## @param title_text Optional title header text.
func set_text(content_text: String, title_text: String = ""):
	if rich:
		rich.clear()
		rich.bbcode_enabled = true
		rich.text = content_text
		
	if title_lbl:
		if title_text != "":
			title_lbl.text = title_text
		else:
			title_lbl.text = tr("Information")
			
	# Dynamically calculate window size & position centered on viewport
	var vp_rect = get_viewport().get_visible_rect()
	var width: int = 560
	var height: int = 420
	self.size = Vector2i(width, height)
	self.position = Vector2i(int((vp_rect.size.x - width) / 2.0), int((vp_rect.size.y - height) / 2.0))
	self.popup()
