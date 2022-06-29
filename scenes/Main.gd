extends Control

# Called when the node enters the scene tree for the first time.
func _ready():	
	$CanvasLayer/Version.text="Version: {0}".format([Globals.VERSION])



func _on_Exit_pressed():
		get_tree().quit()

func _on_Load_pressed():
	$FileDialog.popup()


func _on_Players4_pressed():
	Globals.game_data=Globals.new_game(4)
	get_tree().change_scene("res://scenes/PlayersSelection.tscn")

func _on_FileDialog_file_selected(path):
	var data=Globals.load_game(path)
	if data["max_players"]==4:
		Globals.game_data=data
		get_tree().change_scene("res://scenes/Game4.tscn")
		


func _on_Options_pressed():
	get_tree().change_scene("res://scenes/Options.tscn")


func _on_CheckBox_toggled(button_pressed):
		OS.window_fullscreen = button_pressed


func _input(_event):
	if _event.is_action_pressed("exit"):
		print("Exiting from gdParchis due to exit action")
		get_tree().quit()

func _on_Github_gui_input(_event):
	if _event.is_action_pressed("left_click"):
		OS.shell_open("https://github.com/turulomio/gdparchis/")
