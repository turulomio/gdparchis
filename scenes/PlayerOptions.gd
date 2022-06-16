tool
extends Control


export(String) var playername="player" setget set_playername 
export(bool) var plays=true setget set_plays
export(bool) var ia=true setget set_ia
# Editor will enumerate with string names.
export(String, "Yellow", "Blue", "Red", "Green") var color_name setget set_color_name

func set_color_name(s):	
	color_name=s
	if Engine.is_editor_hint(): #Solo se ejecuta como tool
		change_icon_and_name(color_name)

		set_plays(plays)
		set_ia(ia)


func change_icon_and_name(color_name):
	if color_name=="Red":
		set_playername("Redy")
		if has_node("HBoxContainer/Icon"):
			get_node("HBoxContainer/Icon").texture = load("res://images/ficharoja.png")
	if color_name=="Blue":
		set_playername("Bluey")
		if has_node("HBoxContainer/Icon"):
			get_node("HBoxContainer/Icon").texture = load("res://images/fichaazul.png")
	if color_name=="Green":
		set_playername("Greeny")
		if has_node("HBoxContainer/Icon"):
			get_node("HBoxContainer/Icon").texture = load("res://images/fichaverde.png")
	if color_name=="Yellow":
		set_playername("Yellowy")
		if has_node("HBoxContainer/Icon"):
			get_node("HBoxContainer/Icon").texture = load("res://images/fichaamarilla.png")
	
func set_playername(s):
	playername=s
	if has_node("HBoxContainer/PlayerName"):
		$HBoxContainer/PlayerName.text=s
	
func set_plays(b):
	plays=b
	if has_node("HBoxContainer/Plays"):
		$HBoxContainer/Plays.pressed=b
	
func set_ia(b):
	ia=b
	if has_node("HBoxContainer/IA"):
		$HBoxContainer/IA.pressed=b
	
func _ready():
	change_icon_and_name(color_name)
	set_plays(plays)
	set_ia(ia)
	set_playername(playername)


func _on_Plays_toggled(button_pressed):
	set_plays(button_pressed)


func _on_IA_toggled(button_pressed):
	set_ia(button_pressed)


func _on_PlayerName_text_changed():
	set_playername(($HBoxContainer/PlayerName.text))
