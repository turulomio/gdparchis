extends Control


## Scene entry point initializing window resize listener.
func _ready():
	get_tree().get_root().size_changed.connect(self.resize) 
	self.resize()


## Play button click handler saving player selections into Globals.game_data and launching GameDiceStart.tscn.
func _on_Button_pressed():
	var i = 0
	for node in self.nodes():
		Globals.game_data.players[i].playername = node.playername
		Globals.game_data.players[i].plays = node.plays
		Globals.game_data.players[i].ia = node.ia
		i += 1
	get_tree().change_scene_to_file.call_deferred("res://scenes/GameDiceStart.tscn")


## Helper returning an array of all child PlayerOptions nodes.
## @return Array of PlayerOptions nodes.
func nodes():
	var r = []
	for node in self.get_children():
		if node is PlayerOptions:
			r.append(node)
	return r


## Process loop checking for exit shortcut.
## @param _delta Frame delta time.
func _process(_delta):	
	if Input.is_action_just_pressed("exit"):
		_on_button_return_pressed()


## Resizes control bounds to match window size.
func resize():
	self.size = DisplayServer.window_get_size()


## Return button handler navigating back to Main.tscn.
func _on_button_return_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
