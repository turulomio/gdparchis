extends Control

## Scene entry point initializing window resize listener for Controls screen.
func _ready() -> void:
	get_tree().get_root().size_changed.connect(resize) 
	self.resize()


## Dynamically resizes Control elements based on window size.
## Window resize callback.
func resize() -> void:
	pass


## Button handler navigating back to Main.tscn menu.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")


## Input event handler supporting Escape key navigation back to main menu.
## @param event InputEvent object.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
