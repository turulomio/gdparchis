extends Control


func _on_Exit_pressed():
		get_tree().quit()

func _on_Load_pressed():
	$FileDialog.popup()
#	pass


func _on_Players4_pressed():
	get_tree().change_scene("res://scenes/Game4.tscn")


func _on_Players4All_pressed():
	get_tree().change_scene("res://scenes/Game4Objects.tscn")


func _on_FileDialog_file_selected(path):
	var data=Globals.load_game(path)
	if data["max_players"]==4:
		Globals.game_data=data
		get_tree().change_scene("res://scenes/Game4.tscn")
		


func _on_Options_pressed():
	get_tree().change_scene("res://scenes/Options.tscn")


func _on_CheckBox_toggled(button_pressed):
		OS.window_fullscreen = button_pressed


func _on_Main_gui_input(event):
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene("res://scenes/Main.tscn")
	if Input.is_action_just_pressed("full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen

