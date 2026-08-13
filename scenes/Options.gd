extends Control


## Scene entry point initializing settings UI elements from Globals configuration.
func _ready():
	get_tree().get_root().size_changed.connect(self.resize) 
	self.resize()
	$VBoxContainer/FullScreen.set_pressed(Globals.settings.get("full_screen", false))
	$VBoxContainer/Sound.set_pressed(Globals.settings.get("sound", true))
	$VBoxContainer/AutomaticDice.set_pressed(Globals.settings.get("automatic", false))
	$VBoxContainer/HBAutosaves/Autosaves.text = str(Globals.settings["autosaves"])
	$VBoxContainer/HBDifficulty/Difficulty.select(Globals.settings["difficulty"])
	$VBoxContainer/HBLanguages/Language.select(int(Globals.settings["language"]))


## Return button click handler saving settings to disk and returning to Main.tscn.
func _on_Return_pressed():
	Globals.save_settings()
	get_tree().change_scene_to_file("res://scenes/Main.tscn")


## Checkbox toggle handler for FullScreen window mode setting.
## @param _button_pressed Boolean state.
func _on_FullScreen_toggled(_button_pressed):
	Globals.set_window_mode_fullscreen(_button_pressed)
	self.resize()


## Resizes control bounds to match current window size.
func resize():
	self.size = DisplayServer.window_get_size()


## Checkbox toggle handler for Automatic Dice roll setting.
## @param button_pressed Boolean state.
func _on_AutomaticDice_toggled(button_pressed):
	Globals.settings["automatic"] = button_pressed


## LineEdit text change handler for Autosaves count configuration.
## @param new_text New text string.
func _on_Autosaves_text_changed(new_text):
	Globals.settings["autosaves"] = int(new_text)


## OptionButton selection handler for game difficulty setting.
## @param index Selected item index.
func _on_Difficulty_item_selected(index):
	Globals.settings["difficulty"] = index


## OptionButton selection handler for application display language.
## @param index Selected language index.
func _on_Language_item_selected(index):
	Globals.settings["language"] = index
	Globals.change_language(Globals.settings["language"])


## Checkbox toggle handler for Master Audio sound mute setting.
## @param button_pressed Boolean state.
func _on_Sound_toggled(button_pressed):
	Globals.settings["sound"] = button_pressed
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not button_pressed)
