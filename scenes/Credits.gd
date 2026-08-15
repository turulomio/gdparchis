extends Node3D

@onready var Piece1Pivot = $Piece1Pivot
@onready var Piece2Pivot = $Piece2Pivot
@onready var Piece3Pivot = get_node_or_null("Piece3Pivot")
@onready var Piece4Pivot = get_node_or_null("Piece4Pivot")
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


## Scene initialization entry point configuring translated text fields, 3D red & green pieces, and materials.
func _ready() -> void:
	print("LOADING CREDITS SCENE")
	
	# 1. Cast VERSION_DATE string constant into a Godot Date Dictionary object
	var date_obj = Time.get_datetime_dict_from_datetime_string(Globals.VERSION_DATE, false)
	var release_year = str(date_obj.get("year", 2026))
		
	# 2. Populate translated credit text fields using dynamic engine version
	var godot_ver = str(Engine.get_version_info().get("string", "4.7"))
	TitleLabel.text = "GDParchis"
	SubtitleLabel.text = tr("Credits")
	VersionLabel.text = tr(" Version: {0}").format([Globals.VERSION])
	DateLabel.text = tr("Release Date: {0}").format([Globals.VERSION_DATE])
	DevLabel.text = tr("Lead Developer: {0}").format(["turulomio"])
	EngineLabel.text = tr("Engine: {0}").format(["Godot Engine " + godot_ver])
	LicenseLabel.text = tr("License: {0}").format(["GNU GPL v3.0"])
	CopyrightLabel.text = "© 2024 - " + release_year + " turulomio"
	ButtonBack.text = tr("Back to Main Menu")
	
	# 3. Configure 3D red and green pieces, freeze physics, scale, tilt 30°, and apply wooden varnish materials
	var piece_tilt = Vector3(deg_to_rad(30.0), 0.0, 0.0)
	var red_color = Color(0.9, 0.1, 0.1)
	var green_color = Color(0.1, 0.85, 0.2)
	
	if Piece1Pivot and Piece1Pivot.has_node("Piece"):
		var p1 = Piece1Pivot.get_node("Piece")
		if p1 is RigidBody3D:
			p1.freeze = true
			p1.gravity_scale = 0.0
			p1.linear_velocity = Vector3.ZERO
			p1.angular_velocity = Vector3.ZERO
		p1.scale = Vector3(1.49, 1.49, 1.49)
		p1.rotation = piece_tilt
		if p1.has_method("initialize"):
			p1.initialize(red_color)
			
	if Piece2Pivot and Piece2Pivot.has_node("Piece"):
		var p2 = Piece2Pivot.get_node("Piece")
		if p2 is RigidBody3D:
			p2.freeze = true
			p2.gravity_scale = 0.0
			p2.linear_velocity = Vector3.ZERO
			p2.angular_velocity = Vector3.ZERO
		p2.scale = Vector3(1.49, 1.49, 1.49)
		p2.rotation = piece_tilt
		if p2.has_method("initialize"):
			p2.initialize(red_color)

	if Piece3Pivot and Piece3Pivot.has_node("Piece"):
		var p3 = Piece3Pivot.get_node("Piece")
		if p3 is RigidBody3D:
			p3.freeze = true
			p3.gravity_scale = 0.0
			p3.linear_velocity = Vector3.ZERO
			p3.angular_velocity = Vector3.ZERO
		p3.scale = Vector3(1.49, 1.49, 1.49)
		p3.rotation = piece_tilt
		if p3.has_method("initialize"):
			p3.initialize(green_color)

	if Piece4Pivot and Piece4Pivot.has_node("Piece"):
		var p4 = Piece4Pivot.get_node("Piece")
		if p4 is RigidBody3D:
			p4.freeze = true
			p4.gravity_scale = 0.0
			p4.linear_velocity = Vector3.ZERO
			p4.angular_velocity = Vector3.ZERO
		p4.scale = Vector3(1.49, 1.49, 1.49)
		p4.rotation = piece_tilt
		if p4.has_method("initialize"):
			p4.initialize(green_color)
			
	# 4. Connect window resize listener
	if not get_tree().get_root().size_changed.is_connected(resize):
		get_tree().get_root().size_changed.connect(resize)
	self.resize()


## Frame process loop spinning both 3D red and green pieces continuously around their vertical Y-axis.
## @param delta Frame delta time in seconds.
func _process(delta: float) -> void:
	if Piece1Pivot:
		Piece1Pivot.rotate_y(delta * rotation_speed)
	if Piece2Pivot:
		Piece2Pivot.rotate_y(-delta * rotation_speed)
	if Piece3Pivot:
		Piece3Pivot.rotate_y(-delta * rotation_speed)
	if Piece4Pivot:
		Piece4Pivot.rotate_y(delta * rotation_speed)


## Cleanup callback disconnecting root window resize listener upon scene exit.
func _exit_tree() -> void:
	if get_tree() and get_tree().get_root() and get_tree().get_root().size_changed.is_connected(resize):
		get_tree().get_root().size_changed.disconnect(resize)


## Window resize listener callback.
func resize() -> void:
	call_deferred("position_pivots_from_ui")


## Positions 3D piece pivots at a fixed screen margin relative to the central UI container bounds.
func position_pivots_from_ui() -> void:
	var camera = get_node_or_null("Camera3D")
	var vbox = find_child("VBoxContainer", true, false)
	if not camera or not vbox:
		return

	vbox.force_update_transform()
	var rect = vbox.get_global_rect()
	var cam_z = camera.global_transform.origin.z

	var top_y = rect.position.y + rect.size.y * 0.25 - 50.0
	var bottom_y = rect.position.y + rect.size.y * 0.75 + 50.0

	var top_left_3d = camera.project_position(Vector2(rect.position.x - 201.6, top_y), cam_z)
	var top_right_3d = camera.project_position(Vector2(rect.position.x + rect.size.x + 201.6, top_y), cam_z)
	var bottom_left_3d = camera.project_position(Vector2(rect.position.x - 201.6, bottom_y), cam_z)
	var bottom_right_3d = camera.project_position(Vector2(rect.position.x + rect.size.x + 201.6, bottom_y), cam_z)

	if Piece1Pivot:
		Piece1Pivot.global_transform.origin = top_left_3d
		if Piece1Pivot.has_node("Piece"):
			var p1 = Piece1Pivot.get_node("Piece")
			p1.global_transform.origin = top_left_3d
			if p1 is RigidBody3D:
				p1.freeze = true
				p1.gravity_scale = 0.0
				p1.linear_velocity = Vector3.ZERO
				p1.angular_velocity = Vector3.ZERO

	if Piece2Pivot:
		Piece2Pivot.global_transform.origin = top_right_3d
		if Piece2Pivot.has_node("Piece"):
			var p2 = Piece2Pivot.get_node("Piece")
			p2.global_transform.origin = top_right_3d
			if p2 is RigidBody3D:
				p2.freeze = true
				p2.gravity_scale = 0.0
				p2.linear_velocity = Vector3.ZERO
				p2.angular_velocity = Vector3.ZERO

	if Piece3Pivot:
		Piece3Pivot.global_transform.origin = bottom_left_3d
		if Piece3Pivot.has_node("Piece"):
			var p3 = Piece3Pivot.get_node("Piece")
			p3.global_transform.origin = bottom_left_3d
			if p3 is RigidBody3D:
				p3.freeze = true
				p3.gravity_scale = 0.0
				p3.linear_velocity = Vector3.ZERO
				p3.angular_velocity = Vector3.ZERO

	if Piece4Pivot:
		Piece4Pivot.global_transform.origin = bottom_right_3d
		if Piece4Pivot.has_node("Piece"):
			var p4 = Piece4Pivot.get_node("Piece")
			p4.global_transform.origin = bottom_right_3d
			if p4 is RigidBody3D:
				p4.freeze = true
				p4.gravity_scale = 0.0
				p4.linear_velocity = Vector3.ZERO
				p4.angular_velocity = Vector3.ZERO


## Button handler navigating back to Main.tscn menu.
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")


## Input event listener supporting Escape key navigation back to Main.tscn.
## @param event InputEvent object.
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
