extends Control

## Scene entry point initializing window resize listener for Controls screen.
func _ready() -> void:
	if not get_tree().get_root().size_changed.is_connected(resize):
		get_tree().get_root().size_changed.connect(resize) 
	self.resize()


## Scene exit cleanup callback disconnecting root window resize signal.
func _exit_tree() -> void:
	if get_tree() and get_tree().get_root() and get_tree().get_root().size_changed.is_connected(resize):
		get_tree().get_root().size_changed.disconnect(resize)


## Dynamically resizes Control elements based on window size.
## Window resize callback.
func resize() -> void:
	pass


## Button handler navigating back to Main.tscn menu.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")


## Input event handler supporting Escape key navigation and S key sound toggle.
## @param event InputEvent object.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
	elif event.is_action_pressed("toggle_sound"):
		get_viewport().set_input_as_handled()
		Globals.toggle_sound()
