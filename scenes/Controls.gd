extends Control

## Scene entry point initializing window resize listener and translated control strings.
func _ready() -> void:
	$MarginContainer/VBoxContainer/Title.text = tr("Controls & Shortcuts")
	$MarginContainer/VBoxContainer/Button_Back.text = tr("Back to Main Menu")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl1.text = tr("Mouse Left Click: Roll Dice / Select Piece to Move")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl2.text = tr("Mouse Right Click Drag: Rotate 3D Board Camera")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl3.text = tr("Wheel Up / Key +: Zoom Camera In")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl4.text = tr("Wheel Down / Key -: Zoom Camera Out")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl5.text = tr("F1: Yellow Player Camera View (Perspective)")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl6.text = tr("F2: Blue Player Camera View (Perspective)")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl7.text = tr("F3: Red Player Camera View (Perspective)")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl8.text = tr("F4: Green Player Camera View (Perspective)")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl9.text = tr("Shift + F1: Yellow Player Camera View (Floor Level)")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl10.text = tr("Shift + F2: Blue Player Camera View (Floor Level)")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl11.text = tr("Shift + F3: Red Player Camera View (Floor Level)")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl12.text = tr("Shift + F4: Green Player Camera View (Floor Level)")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl13.text = tr("F9: Bottom Camera View")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl14.text = tr("F10 / Enter: Top Camera View")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl15.text = tr("F11 / Key F: Toggle Fullscreen Mode")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl16.text = tr("Esc: Back to Main Menu / Exit")
	$MarginContainer/VBoxContainer/ScrollContainer/ControlsList/Ctrl17.text = tr("Key S: Toggle Sound ON / OFF")
	
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
