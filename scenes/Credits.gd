extends Node3D

@onready var Dice1Pivot = $Dice1Pivot
@onready var Dice2Pivot = $Dice2Pivot
@onready var TitleLabel = $UI/Control/MarginContainer/VBoxContainer/Title
@onready var SubtitleLabel = $UI/Control/MarginContainer/VBoxContainer/Subtitle
@onready var VersionLabel = $UI/Control/MarginContainer/VBoxContainer/Version
@onready var DateLabel = $UI/Control/MarginContainer/VBoxContainer/VersionDate
@onready var DevLabel = $UI/Control/MarginContainer/VBoxContainer/Developer
@onready var EngineLabel = $UI/Control/MarginContainer/VBoxContainer/Engine
@onready var LicenseLabel = $UI/Control/MarginContainer/VBoxContainer/License
@onready var CopyrightLabel = $UI/Control/MarginContainer/VBoxContainer/Copyright
@onready var ButtonBack = $UI/Control/MarginContainer/VBoxContainer/ButtonBack

var rotation_speed: float = 1.2


## System notification handler intercepting Android OS back button navigation.
## @param what Notification type identifier.
func _notification(what: int):
	# Intercept Android back button press and return to Main Menu
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_back_pressed()


## Scene initialization entry point configuring translated text fields, 3D dice tilts, and red materials.
func _ready() -> void:
	print("LOADING CREDITS SCENE")
	
	# 1. Cast VERSION_DATE string constant into a Godot Date Dictionary object
	var date_obj = Time.get_datetime_dict_from_datetime_string(Globals.VERSION_DATE, false)
	var release_year = str(date_obj.get("year", 2026))
		
	# 2. Populate translated credit text fields
	TitleLabel.text = "GDParchis"
	SubtitleLabel.text = tr("Credits")
	VersionLabel.text = tr(" Version: {0}").format([Globals.VERSION])
	DateLabel.text = tr("Release Date: {0}").format([Globals.VERSION_DATE])
	DevLabel.text = tr("Lead Developer: {0}").format(["turulomio"])
	EngineLabel.text = tr("Engine: {0}").format(["Godot Engine 4.7.1"])
	LicenseLabel.text = tr("License: {0}").format(["GNU GPL v3.0"])
	CopyrightLabel.text = "© 2024 - " + release_year + " turulomio"
	ButtonBack.text = tr("Back to Main Menu")
	
	# 3. Apply diamond tilt rotation (35.264° pitch, 45° yaw) to both 3D dice meshes
	var diamond_tilt = Vector3(deg_to_rad(35.264), deg_to_rad(45.0), 0.0)
	if Dice1Pivot and Dice1Pivot.has_node("Dice"):
		var dice1 = Dice1Pivot.get_node("Dice")
		dice1.rotation = diamond_tilt
		if dice1.has_method("apply_soft_tint"):
			dice1.apply_soft_tint(Color(0.95, 0.15, 0.15))
			
	if Dice2Pivot and Dice2Pivot.has_node("Dice"):
		var dice2 = Dice2Pivot.get_node("Dice")
		dice2.rotation = diamond_tilt
		if dice2.has_method("apply_soft_tint"):
			dice2.apply_soft_tint(Color(0.95, 0.15, 0.15))
			
	# 4. Connect window resize listener
	if not get_tree().get_root().size_changed.is_connected(resize):
		get_tree().get_root().size_changed.connect(resize)
	self.resize()


## Frame process loop spinning both 3D red dice continuously around their vertical Y-axis like diamonds.
## @param delta Frame delta time in seconds.
func _process(delta: float) -> void:
	# Rotate left dice pivot clockwise and right dice pivot counter-clockwise around vertical Y-axis
	if Dice1Pivot:
		Dice1Pivot.rotate_y(delta * rotation_speed)
	if Dice2Pivot:
		Dice2Pivot.rotate_y(-delta * rotation_speed)


## Cleanup callback disconnecting root window resize listener upon scene exit.
func _exit_tree() -> void:
	if get_tree() and get_tree().get_root() and get_tree().get_root().size_changed.is_connected(resize):
		get_tree().get_root().size_changed.disconnect(resize)


## Window resize listener callback.
func resize() -> void:
	pass


## Button handler navigating back to Main.tscn menu.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")


## Input event listener supporting Escape key navigation back to Main.tscn.
## @param event InputEvent object.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
