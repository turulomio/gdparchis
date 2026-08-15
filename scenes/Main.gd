extends Node3D

@onready var Dice1Pivot = get_node_or_null("Dice1Pivot")
@onready var Dice2Pivot = get_node_or_null("Dice2Pivot")

var http_request: HTTPRequest
var latest_release_url: String = "https://github.com/turulomio/gdparchis/releases"
var rotation_speed: float = 1.2


## Scene entry point initializing 3D red dice, version label text, update checker, and window resize listener.
func _ready() -> void:	
	# 1. Apply diamond tilt rotation (35.264° pitch, 45° yaw) and freeze physics for background 3D dice
	var diamond_tilt = Vector3(deg_to_rad(35.264), deg_to_rad(45.0), 0.0)
	if Dice1Pivot and Dice1Pivot.has_node("Dice"):
		var dice1 = Dice1Pivot.get_node("Dice")
		if dice1 is RigidBody3D:
			dice1.freeze = true
			dice1.gravity_scale = 0.0
			dice1.linear_velocity = Vector3.ZERO
			dice1.angular_velocity = Vector3.ZERO
		dice1.rotation = diamond_tilt
		if dice1.has_method("apply_soft_tint"):
			dice1.apply_soft_tint(Color(0.95, 0.15, 0.15))
			
	if Dice2Pivot and Dice2Pivot.has_node("Dice"):
		var dice2 = Dice2Pivot.get_node("Dice")
		if dice2 is RigidBody3D:
			dice2.freeze = true
			dice2.gravity_scale = 0.0
			dice2.linear_velocity = Vector3.ZERO
			dice2.angular_velocity = Vector3.ZERO
		dice2.rotation = diamond_tilt
		if dice2.has_method("apply_soft_tint"):
			dice2.apply_soft_tint(Color(0.95, 0.15, 0.15))

	# 2. Populate translated UI text fields and scale Title font size by 3x
	var title_lbl = find_child("Title", true, false)
	if title_lbl:
		title_lbl.add_theme_font_size_override("font_size", 135)

	var ver_label = find_child("Version", true, false)
	if ver_label:
		ver_label.text = tr(" Version: {0} - ").format([Globals.VERSION])
		
	var file_dlg = find_child("FileDialog", true, false)
	if file_dlg:
		file_dlg.title = tr("Load game")
		file_dlg.ok_button_text = tr("Load game")
		
	var p3_btn = find_child("Players3", true, false)
	if p3_btn:
		p3_btn.text = tr("3 players board")

	var p4_btn = find_child("Players4", true, false)
	if p4_btn:
		p4_btn.text = tr("4 players board")

	var load_btn = find_child("Load", true, false)
	if load_btn:
		load_btn.text = tr("Load game")

	var hist_btn = find_child("History", true, false)
	if hist_btn:
		hist_btn.text = tr("Match history")

	var ctrl_btn = find_child("Controls", true, false)
	if ctrl_btn:
		ctrl_btn.text = tr("Controls & Shortcuts")

	var opt_btn = find_child("Options", true, false)
	if opt_btn:
		opt_btn.text = tr("Settings")

	var credits_btn = find_child("Credits", true, false)
	if credits_btn:
		credits_btn.text = tr("Credits")

	var exit_btn = find_child("Exit", true, false)
	if exit_btn:
		exit_btn.text = tr("Exit")

	# Developer Calibration Mode check
	if is_calibration_requested():
		setup_calibration_developer_buttons()

	# 3. Connect window resize listener
	if not get_tree().get_root().size_changed.is_connected(resize):
		get_tree().get_root().size_changed.connect(resize) 
	self.resize()
	self.check_for_updates()


## Checks whether --calibration flag was passed on CLI invocation.
func is_calibration_requested() -> bool:
	var user_args = OS.get_cmdline_user_args()
	for arg in user_args:
		if arg == "--calibration" or arg == "-c":
			return true
	var args = OS.get_cmdline_args()
	for arg in args:
		if arg == "--calibration" or arg == "-c":
			return true
	return false


## Sets up developer calibration buttons in Main menu when --calibration is active.
func setup_calibration_developer_buttons() -> void:
	var vbox = find_child("VBoxContainer", true, false)
	if not vbox: return
	
	var exit_btn = find_child("Exit", true, false)
	
	# Developer Calibration Section Label
	var sep = Label.new()
	sep.text = "--- MOD DEVEL CALIBRACIÓN ---"
	sep.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(sep)
	if exit_btn: vbox.move_child(sep, exit_btn.get_index())
	
	# Board 3 Calibration Button
	var calib3_btn = Button.new()
	calib3_btn.name = "Calibration3"
	calib3_btn.text = "Calibración Tablero 3"
	calib3_btn.pressed.connect(func(): get_tree().change_scene_to_file.call_deferred("res://scenes/Board3Calibration.tscn"))
	calib3_btn.mouse_entered.connect(_play_click)
	vbox.add_child(calib3_btn)
	if exit_btn: vbox.move_child(calib3_btn, exit_btn.get_index())

	# Board 4 Calibration Button
	var calib4_btn = Button.new()
	calib4_btn.name = "Calibration4"
	calib4_btn.text = "Calibración Tablero 4"
	calib4_btn.pressed.connect(func(): get_tree().change_scene_to_file.call_deferred("res://scenes/Board4Calibration.tscn"))
	calib4_btn.mouse_entered.connect(_play_click)
	vbox.add_child(calib4_btn)
	if exit_btn: vbox.move_child(calib4_btn, exit_btn.get_index())


## Frame process loop spinning both background 3D red dice continuously around their vertical Y-axis like diamonds.
## @param delta Frame delta time in seconds.
func _process(delta: float) -> void:
	if Dice1Pivot:
		Dice1Pivot.rotate_y(delta * rotation_speed)
	if Dice2Pivot:
		Dice2Pivot.rotate_y(-delta * rotation_speed)


## Initializes HTTPRequest node and sends asynchronous API query to GitHub releases endpoint.
func check_for_updates() -> void:
	var status_label = find_child("UpdateStatus", true, false)
	if not status_label:
		return
	status_label.text = tr("Checking for updates...")
	
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_update_request_completed)
	
	var url = "https://api.github.com/repos/turulomio/gdparchis/releases/latest"
	var headers = PackedStringArray([
		"User-Agent: gdParchis-App",
		"Accept: application/vnd.github.v3+json"
	])
	var err = http_request.request(url, headers)
	if err != OK:
		status_label.text = tr("Could not check for updates")
		status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))


## Callback processing HTTP response from GitHub releases API.
## @param result Result enum of HTTP request.
## @param response_code HTTP response status code (e.g. 200).
## @param _headers Array of response headers.
## @param body Byte array containing JSON response.
func _on_update_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var status_label = find_child("UpdateStatus", true, false)
	if not status_label:
		return
	
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		status_label.text = tr("Could not check for updates")
		status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		return
		
	var json_str = body.get_string_from_utf8()
	var json_data = JSON.parse_string(json_str)
	if json_data == null or not (json_data is Dictionary):
		status_label.text = tr("Could not check for updates")
		status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		return
		
	var tag_name = str(json_data.get("tag_name", ""))
	var release_url = str(json_data.get("html_url", "https://github.com/turulomio/gdparchis/releases"))
	self.latest_release_url = release_url
	
	if Globals.is_newer_version(tag_name, Globals.VERSION):
		status_label.text = tr("New version available: {0}!").format([tag_name])
		status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		status_label.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	else:
		status_label.text = tr("Up to date")
		status_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
		
	# Store timestamp of successful update check
	if Globals.settings != null and Globals.settings is Dictionary:
		Globals.settings["last_internet_update"] = Time.get_datetime_string_from_system()
		Globals.save_settings()


## GUI input callback handling clicks on center-bottom UpdateStatus label.
## @param _event InputEvent object.
func _on_UpdateStatus_gui_input(_event: InputEvent) -> void:
	if _event.is_action_pressed("left_click"):
		OS.shell_open(self.latest_release_url)


## Scene exit cleanup callback disconnecting root window resize signal.
func _exit_tree() -> void:
	if get_tree() and get_tree().get_root() and get_tree().get_root().size_changed.is_connected(resize):
		get_tree().get_root().size_changed.disconnect(resize)


## Button handler navigating to Board3Calibration.tscn scene.
func _on_Calibration3_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/Board3Calibration.tscn")


## Button handler quitting the game application.
func _on_Exit_pressed():
	get_tree().quit()


## Button handler displaying the load game FileDialog.
func _on_Load_pressed():
	var file_dlg = find_child("FileDialog", true, false)
	if file_dlg:
		file_dlg.current_dir = "user://saves/"
		self.resize()
		file_dlg.popup_centered()


## Button handler starting a new 3-player game.
func _on_Players3_pressed():
	Globals.game_data = Globals.new_game(3)
	get_tree().change_scene_to_file.call_deferred("res://scenes/PlayersSelection.tscn")


## Mouse hover audio feedback for 3 players button.
func _on_Players3_mouse_entered():
	_play_click()


## Button handler starting a new 4-player game.
func _on_Players4_pressed():
	Globals.game_data = Globals.new_game(4)
	get_tree().change_scene_to_file.call_deferred("res://scenes/PlayersSelection.tscn")


## Button handler starting a new 6-player game.
func _on_Players6_pressed():
	Globals.game_data = Globals.new_game(6)
	get_tree().change_scene_to_file.call_deferred("res://scenes/PlayersSelection.tscn")


## Mouse hover audio feedback for 6 players button.
func _on_Players6_mouse_entered():
	_play_click()


## Callback when a saved game file is selected in FileDialog.
## @param path Absolute file path to .save file.
func _on_FileDialog_file_selected(path):
	var data = Globals.load_game(path)
	Globals.game_data = data
	match data.get("max_players", 4):
		3:
			get_tree().change_scene_to_file.call_deferred("res://scenes/Game3.tscn")
		6:
			get_tree().change_scene_to_file.call_deferred("res://scenes/Game6.tscn")
		_:
			get_tree().change_scene_to_file.call_deferred("res://scenes/Game4.tscn")


## Button handler navigating to GameHistory.tscn scene.
func _on_History_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/GameHistory.tscn")


## Mouse hover event playing sound effect for Controls button.
func _on_Controls_mouse_entered():
	_play_click()


## Button handler navigating to Controls.tscn scene.
func _on_Controls_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/Controls.tscn")


## Button handler navigating to Options.tscn scene.
func _on_Options_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/Options.tscn")


## Mouse hover audio feedback for Credits button.
func _on_Credits_mouse_entered():
	_play_click()


## Button handler navigating to Credits.tscn scene.
func _on_Credits_pressed():
	get_tree().change_scene_to_file.call_deferred("res://scenes/Credits.tscn")


## Input event callback handling global exit key press.
## @param _event InputEvent object.
func _input(_event):
	if _event.is_action_pressed("exit"):
		get_viewport().set_input_as_handled()
		print("Exiting from gdParchis due to exit action")
		get_tree().quit()


## GUI input callback opening GitHub repository URL in web browser.
## @param _event InputEvent object.
func _on_Github_gui_input(_event):
	if _event.is_action_pressed("left_click"):
		OS.shell_open("https://github.com/turulomio/gdparchis/")


## Mouse hover audio feedback for 4 players button.
func _on_Players4_mouse_entered():
	_play_click()


## Mouse hover audio feedback for Load button.
func _on_Load_mouse_entered():
	_play_click()


## Mouse hover audio feedback for History button.
func _on_History_mouse_entered():
	_play_click()


## Mouse hover audio feedback for Options button.
func _on_Options_mouse_entered():
	_play_click()


## Mouse hover audio feedback for Exit button.
func _on_Exit_mouse_entered():
	_play_click()


## Plays click audio sound effect if node exists.
func _play_click() -> void:
	var click_sound = find_child("Click", true, false)
	if click_sound:
		click_sound.play()


## Resizes UI container bounds, FileDialog, and repositions 3D background dice relative to UI widget.
func resize():
	var file_dlg = find_child("FileDialog", true, false)
	if file_dlg:
		var vp_size = get_viewport().get_visible_rect().size
		var target_w = max(400, int(vp_size.x * 0.85))
		var target_h = max(300, int(vp_size.y * 0.85))
		file_dlg.size = Vector2i(target_w, target_h)
		
	call_deferred("position_pivots_from_ui")


## Positions 3D dice pivots at a fixed screen margin relative to the central UI container bounds.
func position_pivots_from_ui():
	var camera = get_node_or_null("Camera3D")
	if not camera:
		return

	var vp_size = get_viewport().get_visible_rect().size
	var center_x = vp_size.x * 0.5
	var center_y = vp_size.y * 0.5
	var cam_z = camera.global_transform.origin.z

	var half_menu = 250.0
	var vbox = find_child("VBoxContainer", true, false)
	if vbox:
		vbox.force_update_transform()
		if vbox.size.x > 50.0:
			half_menu = vbox.size.x * 0.5

	var margin = max(160.0, vp_size.x * 0.08)
	var left_screen = Vector2(center_x - half_menu - margin, center_y)
	var right_screen = Vector2(center_x + half_menu + margin, center_y)

	var left_3d = camera.project_position(left_screen, cam_z)
	var right_3d = camera.project_position(right_screen, cam_z)

	if Dice1Pivot:
		Dice1Pivot.global_transform.origin = left_3d
		if Dice1Pivot.has_node("Dice"):
			var dice1 = Dice1Pivot.get_node("Dice")
			dice1.global_transform.origin = left_3d
			if dice1 is RigidBody3D:
				dice1.freeze = true
				dice1.gravity_scale = 0.0
				dice1.linear_velocity = Vector3.ZERO
				dice1.angular_velocity = Vector3.ZERO

	if Dice2Pivot:
		Dice2Pivot.global_transform.origin = right_3d
		if Dice2Pivot.has_node("Dice"):
			var dice2 = Dice2Pivot.get_node("Dice")
			dice2.global_transform.origin = right_3d
			if dice2 is RigidBody3D:
				dice2.freeze = true
				dice2.gravity_scale = 0.0
				dice2.linear_velocity = Vector3.ZERO
				dice2.angular_velocity = Vector3.ZERO
