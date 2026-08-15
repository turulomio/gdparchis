extends Control


## System notification handler for Android OS back button navigation.
## @param what Notification type identifier.
func _notification(what: int):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_button_return_pressed()


## Scene entry point initializing dynamic player customization controls and window resize listener.
func _ready():
	if not get_tree().get_root().size_changed.is_connected(self.resize):
		get_tree().get_root().size_changed.connect(self.resize) 
	self.resize()

	var container = get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer")
	if container:
		for child in container.get_children():
			child.queue_free()
		
		var max_players = 4
		if Globals.game_data and Globals.game_data.has("max_players"):
			max_players = Globals.game_data.max_players
			
		for p_idx in range(max_players):
			var po = Globals.SCENE_PLAYER_OPTIONS.instantiate()
			container.add_child(po)
			po.set_player_id(p_idx)
			if Globals.game_data and Globals.game_data.has("players") and p_idx < Globals.game_data.players.size():
				var p_info = Globals.game_data.players[p_idx]
				if po.has_method("set_player_data"):
					po.set_player_data(p_info.get("playername", Globals.ePlayerDefaultName(p_idx)), p_info.get("plays", true), p_info.get("ia", p_idx > 0))


## Scene exit cleanup callback disconnecting root window resize signal.
func _exit_tree() -> void:
	if get_tree() and get_tree().get_root() and get_tree().get_root().size_changed.is_connected(self.resize):
		get_tree().get_root().size_changed.disconnect(self.resize)


## Play button click handler saving player selections into Globals.game_data and launching GameDiceStart.tscn.
func _on_Button_pressed():
	var i = 0
	for node in self.nodes():
		if i < Globals.game_data.players.size():
			Globals.game_data.players[i].playername = node.playername
			Globals.game_data.players[i].plays = node.plays
			Globals.game_data.players[i].ia = node.ia
		i += 1
	match Globals.game_data.get("max_players", 4):
		3:
			get_tree().change_scene_to_file.call_deferred("res://scenes/GameDiceStart3.tscn")
		6:
			get_tree().change_scene_to_file.call_deferred("res://scenes/GameDiceStart6.tscn")
		_:
			get_tree().change_scene_to_file.call_deferred("res://scenes/GameDiceStart.tscn")


## Helper returning an array of all child PlayerOptions nodes.
## @return Array of PlayerOptions nodes.
func nodes():
	var r = []
	var container = get_node_or_null("MarginContainer/VBoxContainer/HBoxContainer")
	if container:
		for node in container.get_children():
			if node is PlayerOptions:
				r.append(node)
	return r


## Process loop checking for exit shortcut.
## @param _delta Frame delta time.
func _process(_delta):	
	if Input.is_action_just_pressed("exit"):
		_on_button_return_pressed()


## Window resize callback.
func resize():
	pass


## Return button handler navigating back to Main.tscn.
func _on_button_return_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
