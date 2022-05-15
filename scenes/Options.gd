extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/FullScreen.pressed=Globals.settings["full_screen"]
	$VBoxContainer/Sound.pressed=Globals.settings["sound"]
	$VBoxContainer/AutomaticDice.pressed=Globals.settings["automatic_dice"]
	$VBoxContainer/HBAutosaves/Autosaves.text=str(Globals.settings["autosaves"])
	
	$VBoxContainer/HBDifficulty/Difficulty.add_item("Easy",Globals.eDifficulty.EASY)
	$VBoxContainer/HBDifficulty/Difficulty.add_item("Normal",Globals.eDifficulty.NORMAL)
	$VBoxContainer/HBDifficulty/Difficulty.add_item("Difficult",Globals.eDifficulty.DIFFICULT)
	$VBoxContainer/HBDifficulty/Difficulty.select(Globals.settings["difficulty"])
	
	#Must have the same order than enumLanguage
	$VBoxContainer/HBLanguages/Language.add_item("English", Globals.eLanguages.ENGLISH)
	$VBoxContainer/HBLanguages/Language.add_item("Spanish", Globals.eLanguages.SPANISH)
	$VBoxContainer/HBLanguages/Language.add_item("French", Globals.eLanguages.FRENCH)
	$VBoxContainer/HBLanguages/Language.select(int(Globals.settings["language"]))
	

func _on_Return_pressed():
	Globals.save_settings()
	get_tree().change_scene("res://scenes/Main.tscn")

func _on_FullScreen_toggled(button_pressed):
	Globals.settings["full_screen"]=button_pressed
	OS.window_fullscreen = button_pressed

func _on_AutomaticDice_toggled(button_pressed):
	Globals.settings["automatic_dice"]=button_pressed


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

