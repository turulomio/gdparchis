extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for p in Globals.game_data.players:
		var po= Globals.SCENE_PLAYER_OPTIONS.instance()
		po.set_color_name(Globals.color_name(p.id))
		po.set_player_name(p.name)
		po.set_plays(p.plays)
		po.set_ia(p.ia)
		$VBoxContainerMain/VBoxContainer.add_child(po)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	for i in range($VBoxContainerMain/VBoxContainer.get_child_count()):
		var child=$VBoxContainerMain/VBoxContainer.get_child(i)
		Globals.game_data.players[i].name=child.get_player_name()
		Globals.game_data.players[i].plays=child.get_plays()
		Globals.game_data.players[i].ia=child.get_ia()
	get_tree().change_scene("res://scenes/GameDiceStart.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene("res://scenes/Main.tscn")
