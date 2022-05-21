extends Control

var color_name : String 
var player_name : String
var plays : bool
var ia: bool

func get_color_name():
	return self.color_name

func set_color_name(s):	
	self.color_name=s
	$HBoxContainer/Icon.modulate.b=255

func get_player_name():
	return self.player_name
	
func set_player_name(s):
	self.player_name=s
	$HBoxContainer/Name.text=s
	
func get_plays():
	return self.plays

func set_plays(b):
	self.plays=b
	$HBoxContainer/Plays.pressed=b
	
func get_ia():
	return self.ia
	
func set_ia(b):
	self.ia=b
	$HBoxContainer/IA.pressed=b



func _on_Name_text_changed():
	self.set_player_name($HBoxContainer/Name.text)


func _on_Plays_toggled(button_pressed):
	self.set_plays(button_pressed)


func _on_IA_toggled(button_pressed):
	self.set_ia(button_pressed)
