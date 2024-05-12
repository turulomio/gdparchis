extends Control

# Called when the node enters the scene tree for the first time.
func _ready():	
	$Version.text="Version: {0}".format([Globals.VERSION])
	get_tree().get_root().size_changed.connect(resize) 


func _on_Exit_pressed():
		get_tree().quit()

func _on_Load_pressed():
	$FileDialog.popup()


func _on_Players4_pressed():
	Globals.game_data=Globals.new_game(4)
	get_tree().change_scene_to_file("res://scenes/PlayersSelection.tscn")

func _on_FileDialog_file_selected(path):
	var data=Globals.load_game(path)
	if data["max_players"]==4:
		Globals.game_data=data
		get_tree().change_scene_to_file("res://scenes/Game4.tscn")
		


func _on_Options_pressed():
	get_tree().change_scene_to_file("res://scenes/Options.tscn")


func _on_CheckBox_toggled(_button_pressed):
	var current_mode = DisplayServer.window_get_mode(0)
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, 0)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN, 0)


func _input(_event):
	if _event.is_action_pressed("exit"):
		print("Exiting from gdParchis due to exit action")
		get_tree().quit()

func _on_Github_gui_input(_event):
	if _event.is_action_pressed("left_click"):
		OS.shell_open("https://github.com/turulomio/gdparchis/")


func _on_Players4_mouse_entered():
	$Click.play()


func _on_Load_mouse_entered():
	$Click.play()


func _on_Options_mouse_entered():
	$Click.play()


func _on_Exit_mouse_entered():
	$Click.play()

func _on_RequestPostInstallation_ready():
	print("Registering installation:")
	var fields = {"uuid" : Globals.settings.get("installation_uuid",""), "so":OS.get_name()}
	#Globals.request_post($RequestPostInstallation, Globals.APIROOT+"/installations/", fields)


func _on_RequestPostInstallation_request_completed(result, response_code, headers, body):
	if result==0:
		var r=JSON.parse_string(body.get_string_from_utf8())
		print ("  - ", r["success"],": ", r["detail"])
	else:
		print ("  -  Couldn't connect")



func _on_StatisticsUser_gui_input(_event):
	if _event.is_action_pressed("left_click"):
		OS.shell_open("https://coolnewton.mooo.com/django_gdparchis/statistics/user/?uuid="+ Globals.settings.get("installation_uuid"))


func _on_StatisticsGlobal_gui_input(_event):
	if _event.is_action_pressed("left_click"):
		OS.shell_open("https://coolnewton.mooo.com/django_gdparchis/statistics/globals/")


func resize():
	print($VBoxContainer.size)
	$VBoxContainer.size=DisplayServer.window_get_size()
	print($VBoxContainer.size)
