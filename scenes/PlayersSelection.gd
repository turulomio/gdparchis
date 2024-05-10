extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	
	var nodes =[
		$VBoxContainerMain/VBoxContainer/PoYellow,
		$VBoxContainerMain/VBoxContainer/PoBlue,
		$VBoxContainerMain/VBoxContainer/PoRed,
		$VBoxContainerMain/VBoxContainer/PoGreen
	]
	
	for i in range(Globals.game_data["max_players"]):
		Globals.game_data.players[i].name=nodes[i].playername
		Globals.game_data.players[i].plays=nodes[i].plays
		Globals.game_data.players[i].ia=nodes[i].ia
	get_tree().change_scene_to_file("res://scenes/GameDiceStart.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://scenes/Main.tscn")

