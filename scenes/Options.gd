extends Control


## System notification handler for Android OS back button.
## @param what Notification type identifier.
func _notification(what: int):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_Return_pressed()


## Scene entry point initializing settings UI elements from Globals configuration.
func _ready():
	if not get_tree().get_root().size_changed.is_connected(self.resize):
		get_tree().get_root().size_changed.connect(self.resize) 
	self.resize()

	# Populate translated labels in Options scene
	if has_node("MarginContainer/VBoxContainer/Title"):
		$MarginContainer/VBoxContainer/Title.text = tr("Settings")
		
	var opt_list = get_node_or_null("MarginContainer/VBoxContainer/OptionsList")
	if opt_list:
		if opt_list.has_node("FullScreen"):
			var fs_cb = opt_list.get_node("FullScreen")
			fs_cb.text = tr("Full window mode")
			fs_cb.set_pressed_no_signal(Globals.is_window_mode_fullscreen())
		if opt_list.has_node("Sound"):
			var snd_cb = opt_list.get_node("Sound")
			snd_cb.text = tr("Sound")
			snd_cb.set_pressed_no_signal(bool(Globals.settings.get("sound", true)))
		if opt_list.has_node("AutomaticDice"):
			var auto_cb = opt_list.get_node("AutomaticDice")
			auto_cb.text = tr("Automatic dice and movements")
			auto_cb.set_pressed_no_signal(bool(Globals.settings.get("automatic", true)))
		if opt_list.has_node("HBAutosaves/Label"):
			opt_list.get_node("HBAutosaves/Label").text = tr("Autosaves number  ")
		if opt_list.has_node("HBAutosaves/Autosaves"):
			opt_list.get_node("HBAutosaves/Autosaves").text = str(int(Globals.settings.get("autosaves", 10)))
		if opt_list.has_node("HBDifficulty/Label"):
			opt_list.get_node("HBDifficulty/Label").text = tr("Game difficulty  ")
		if opt_list.has_node("HBDifficulty/Difficulty"):
			opt_list.get_node("HBDifficulty/Difficulty").select(int(Globals.settings.get("difficulty", 1)))
		if opt_list.has_node("HBLanguages/Label"):
			opt_list.get_node("HBLanguages/Label").text = tr("Language  ")
		if opt_list.has_node("HBLanguages/Language"):
			opt_list.get_node("HBLanguages/Language").select(int(Globals.settings.get("language", 0)))
			
	if has_node("MarginContainer/VBoxContainer/Return"):
		$MarginContainer/VBoxContainer/Return.text = tr("Back to Main Menu")


## Scene exit cleanup callback disconnecting root window resize signal.
func _exit_tree() -> void:
	if get_tree() and get_tree().get_root() and get_tree().get_root().size_changed.is_connected(self.resize):
		get_tree().get_root().size_changed.disconnect(self.resize)


## Return button click handler saving settings to disk and returning to Main.tscn.
func _on_Return_pressed():
	Globals.save_settings()
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")


## Input event callback handling Escape key navigation back to Main.tscn.
## @param event InputEvent object.
func _input(event: InputEvent):
	if event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		_on_Return_pressed()


## Checkbox toggle handler for FullScreen window mode setting.
## @param button_pressed Boolean state.
func _on_FullScreen_toggled(button_pressed):
	Globals.settings["full_screen"] = button_pressed
	Globals.set_window_mode_fullscreen(button_pressed)
	Globals.save_settings()
	self.resize()


## Window resize callback.
func resize():
	# Sync FullScreen checkbox state with current window display mode
	var opt_list = get_node_or_null("MarginContainer/VBoxContainer/OptionsList")
	if opt_list and opt_list.has_node("FullScreen"):
		opt_list.get_node("FullScreen").set_pressed_no_signal(Globals.is_window_mode_fullscreen())


## Checkbox toggle handler for Automatic Dice roll setting.
## @param button_pressed Boolean state.
func _on_AutomaticDice_toggled(button_pressed):
	Globals.settings["automatic"] = button_pressed
	Globals.save_settings()


## LineEdit text change handler for Autosaves count configuration.
## @param new_text New text string.
func _on_Autosaves_text_changed(new_text):
	Globals.settings["autosaves"] = int(new_text)
	Globals.save_settings()


## OptionButton selection handler for game difficulty setting.
## @param index Selected item index.
func _on_Difficulty_item_selected(index):
	Globals.settings["difficulty"] = index
	Globals.save_settings()


## OptionButton selection handler for application display language.
## @param index Selected language index.
func _on_Language_item_selected(index):
	Globals.settings["language"] = index
	Globals.change_language(Globals.settings["language"])
	Globals.save_settings()


## Checkbox toggle handler for Master Audio sound mute setting.
## @param button_pressed Boolean state.
func _on_Sound_toggled(button_pressed):
	Globals.settings["sound"] = button_pressed
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not button_pressed)
	Globals.save_settings()
