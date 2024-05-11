@tool
extends Control


@export var playername: String="player"  : set = set_playername
@export var plays: bool= true : set = set_plays
@export var ia:bool=true: set=set_ia
# Editor will enumerate with string names.
@export_enum("YELLOW", "BLUE", "RED", "GREEN") var color_name  : set =  set_color_name ## Estaba con string

func set_color_name(s):	
	color_name=s
	if Engine.is_editor_hint(): #Solo se ejecuta como tool
		change_icon_and_name()

		set_plays(plays)
		set_ia(ia)


func change_icon_and_name():
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
		$HBoxContainer/Plays.set_pressed(b)
	
func set_ia(b):
	ia=b
	if has_node("HBoxContainer/IA"):
		$HBoxContainer/IA.set_pressed(b)
	
func _ready():
	change_icon_and_name()
	set_plays(plays)
	set_ia(ia)
	set_playername(playername)


func _on_Plays_toggled(button_pressed):
	set_plays(button_pressed)


func _on_IA_toggled(button_pressed):
	set_ia(button_pressed)


func _on_PlayerName_text_changed():
	set_playername(($HBoxContainer/PlayerName.text))
