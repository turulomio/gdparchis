extends Control


## Scene entry point initializing version label text and window resize listener.
func _ready():	
	$VBoxContainer2/HBoxContainer/Version.text = " Version: {0}".format([Globals.VERSION])
	get_tree().get_root().size_changed.connect(resize) 
	self.resize()


## Button handler quitting the game application.
func _on_Exit_pressed():
	get_tree().quit()


## Button handler displaying the load game FileDialog.
func _on_Load_pressed():
	$FileDialog.popup()


## Button handler starting a new 4-player game.
func _on_Players4_pressed():
	Globals.game_data = Globals.new_game(4)
	get_tree().change_scene_to_file.call_deferred("res://scenes/PlayersSelection.tscn")


## Callback when a saved game file is selected in FileDialog.
## @param path Absolute file path to .save file.
func _on_FileDialog_file_selected(path):
	var data = Globals.load_game(path)
	if data["max_players"] == 4:
		Globals.game_data = data
		get_tree().change_scene_to_file.call_deferred("res://scenes/Game4.tscn")


## Button handler navigating to GameHistory.tscn scene.
func _on_History_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/GameHistory.tscn")


## Mouse hover event playing sound effect for Controls button.
func _on_Controls_mouse_entered():
	$Click.play()


## Button handler navigating to Controls.tscn scene.
func _on_Controls_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/Controls.tscn")


## Button handler navigating to Options.tscn scene.
func _on_Options_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/Options.tscn")


## Input event callback handling global exit key press.
## @param _event InputEvent object.
func _input(_event):
	if _event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		print("Exiting from gdParchis due to exit action")
		get_tree().quit()


## GUI input callback opening GitHub repository URL in web browser.
## @param _event InputEvent object.
func _on_Github_gui_input(_event):
	if _event.is_action_pressed("left_click"):
		OS.shell_open("https://github.com/turulomio/gdparchis/")


## Mouse hover audio feedback for 4 players button.
func _on_Players4_mouse_entered():
	$Click.play()


## Mouse hover audio feedback for Load button.
func _on_Load_mouse_entered():
	$Click.play()


## Mouse hover audio feedback for History button.
func _on_History_mouse_entered():
	$Click.play()


## Mouse hover audio feedback for Options button.
func _on_Options_mouse_entered():
	$Click.play()


## Mouse hover audio feedback for Exit button.
func _on_Exit_mouse_entered():
	$Click.play()


## Resizes UI container bounds to match active window dimensions.
func resize():
	$VBoxContainer2.size = DisplayServer.window_get_size()
