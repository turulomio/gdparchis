extends Control
class_name PlayerOptions

@export var playername: String = "player": set = set_playername
@export var plays: bool = true: set = set_plays
@export var ia: bool = true: set = set_ia
@export var id: int = 0:
	set(value):
		id = value
		change_icon_and_name()


## Node ready initialization callback.
func _ready():
	change_icon_and_name()


## Helper setter for player ID.
func set_player_id(new_id: int):
	self.id = new_id


## Helper setter for full player customization data.
func set_player_data(p_name: String, p_plays: bool, p_ia: bool):
	self.set_playername(p_name)
	self.set_plays(p_plays)
	self.set_ia(p_ia)


## Updates player icon texture, default name, and button font theme colors matching player ID.
func change_icon_and_name():
	set_playername(Globals.ePlayerDefaultName(id))
	
	if has_node("HBoxContainer/Icon"):
		match id:
			Globals.ePlayer.YELLOW:
				get_node("HBoxContainer/Icon").texture = load("res://images/fichaamarilla.png")
			Globals.ePlayer.BLUE:
				get_node("HBoxContainer/Icon").texture = load("res://images/fichaazul.png")
			Globals.ePlayer.RED:
				get_node("HBoxContainer/Icon").texture = load("res://images/ficharoja.png")
			Globals.ePlayer.GREEN:
				get_node("HBoxContainer/Icon").texture = load("res://images/fichaverde.png")
			Globals.ePlayer.GREY:
				get_node("HBoxContainer/Icon").texture = load("res://images/fichagris.png")
			Globals.ePlayer.VIOLET:
				get_node("HBoxContainer/Icon").texture = load("res://images/ficharosa.png")
			Globals.ePlayer.ORANGE:
				get_node("HBoxContainer/Icon").texture = load("res://images/fichanaranja.png")
			Globals.ePlayer.CYAN:
				get_node("HBoxContainer/Icon").texture = load("res://images/fichacyan.png")
			_:
				get_node("HBoxContainer/Icon").texture = load("res://images/piece_red.png")
			
	# Update font colors for UI buttons based on player color
	var c = Globals.ePlayer2Color(id)
	if has_node("HBoxContainer/Plays"):
		$HBoxContainer/Plays.set("theme_override_colors/font_color", c)
		$HBoxContainer/Plays.set("theme_override_colors/font_pressed_color", c)
		$HBoxContainer/Plays.set("theme_override_colors/font_hover_color", c)
		$HBoxContainer/Plays.set("theme_override_colors/font_hover_pressed_color", c)
		$HBoxContainer/Plays.set("theme_override_colors/font_focus_color", c)
	if has_node("HBoxContainer/IA"):
		$HBoxContainer/IA.set("theme_override_colors/font_color", c)
		$HBoxContainer/IA.set("theme_override_colors/font_pressed_color", c)
		$HBoxContainer/IA.set("theme_override_colors/font_hover_color", c)
		$HBoxContainer/IA.set("theme_override_colors/font_hover_pressed_color", c)
		$HBoxContainer/IA.set("theme_override_colors/font_focus_color", c)


## Setter for player name string. Updates UI LineEdit control.
## @param s New player name string.
func set_playername(s):
	playername = s
	if has_node("HBoxContainer/PlayerName"):
		$HBoxContainer/PlayerName.text = s


## Setter for plays boolean flag. Updates UI CheckButton control.
## @param b Boolean flag.
func set_plays(b):
	plays = b
	if has_node("HBoxContainer/Plays"):
		$HBoxContainer/Plays.set_pressed(b)


## Setter for IA boolean flag. Updates UI CheckButton control.
## @param b Boolean flag.
func set_ia(b):
	ia = b
	if has_node("HBoxContainer/IA"):
		$HBoxContainer/IA.set_pressed(b)


## Checkbox toggle handler for Plays setting.
## @param button_pressed Boolean state.
func _on_Plays_toggled(button_pressed):
	set_plays(button_pressed)


## Checkbox toggle handler for IA AI setting.
## @param button_pressed Boolean state.
func _on_IA_toggled(button_pressed):
	set_ia(button_pressed)


## LineEdit text change handler for PlayerName control.
func _on_PlayerName_text_changed():
	set_playername(($HBoxContainer/PlayerName.text))
