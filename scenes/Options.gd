extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().size_changed.connect(self.resize) 
	self.resize()
	$VBoxContainer/FullScreen.set_pressed(Globals.settings.get("full_screen",false))
	$VBoxContainer/Sound.set_pressed(Globals.settings.get("sound",true))
	$VBoxContainer/AutomaticDice.set_pressed(Globals.settings.get("automatic",false))
	$VBoxContainer/HBAutosaves/Autosaves.text=str(Globals.settings["autosaves"])
	
	$VBoxContainer/HBDifficulty/Difficulty.select(Globals.settings["difficulty"])
	
	$VBoxContainer/HBLanguages/Language.select(int(Globals.settings["language"]))
	

func _on_Return_pressed():
	Globals.save_settings()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_FullScreen_toggled(_button_pressed):
	Globals.set_window_mode_fullscreen(_button_pressed)
	self.resize()
	
func resize():
	self.size=DisplayServer.window_get_size()

func _on_AutomaticDice_toggled(button_pressed):
	Globals.settings["automatic"]=button_pressed


func _on_Autosaves_text_changed(new_text):
	Globals.settings["autosaves"]=int(new_text)


func _on_Difficulty_item_selected(index):
	Globals.settings["difficulty"]=index


func _on_Language_item_selected(index):
	Globals.settings["language"]=index
	Globals.change_language(Globals.settings["language"])


func _on_Sound_toggled(button_pressed):
	Globals.settings["sound"]=button_pressed
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),not button_pressed)

