extends Control


func _ready():
	get_tree().get_root().size_changed.connect(self.resize) 
	self.resize()

func _on_Button_pressed():
	var i=0
	for node in self.nodes():
		Globals.game_data.players[i].playername=node.playername
		Globals.game_data.players[i].plays=node.plays
		Globals.game_data.players[i].ia=node.ia
		i+=1
	get_tree().change_scene_to_file("res://scenes/GameDiceStart.tscn")
	
func nodes():
	var r=[]
	for node in self.get_children():
		if node is PlayerOptions:
			r.append(node)
	print(r)
	return r

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if Input.is_action_just_pressed("exit"):
		_on_button_return_pressed()


func resize():
	self.size=DisplayServer.window_get_size()

func _on_button_return_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
