extends GameBase
class_name Game4


## Returns the Board4 child node instance.
## @return Board4 node.
func board() -> BoardBase:
	return $Board4 if has_node("Board4") else super.board()


## Scene entry point. Initializes board data, player turns, and auto-throws if AI.
func _ready():	
	print("LOADING GAME4")
	self.game_start_time = Time.get_unix_time_from_system()
	var d = Globals.game_data

	# Check if transition came from GameDiceStart (pieces already animated) or saved game load
	var animate = not Globals.from_dice_start
	Globals.from_dice_start = false

	# Load global game state into board and pieces and wait for piece placement to complete
	await Globals.game_load_glogals_game_data(self, true, animate)

	# Check if any active player has already won upon loading scene
	if await self.check_game_over():
		return

	# Set active starting player
	self.current_player = self.board().players()[d["current"]]
	self.current_player.can_move_pieces = false
	self.current_player.dice_throws = []
	self.current_player.can_throw_dice = true
	
	# Skip turn if starting player is non-participating or has won
	if self.current_player.plays == false or self.current_player.has_won():
		self.change_current_player()
		return

	# Update dice visibility so only current player's dice is visible
	for p in self.board().players():
		p.dice().visible = (p == self.current_player)
	
	# Automatically trigger dice throw for AI or automatic mode
	if self.current_player.ia == true or Globals.settings.get("automatic", true):
		self.current_player.dice().on_clicked()


## Frame process loop handling mouse click interactions, camera shortcuts, and fullscreen toggles.
## @param _delta Delta frame time.
func _process(_delta):
	# Handle left click interactions with Piece or Dice
	if Input.is_action_just_pressed("left_click"):
		var object = get_object_under_mouse()
		handle_object_click(object)

	# Handle right click interactions (popup details)
	if Input.is_action_just_pressed("right_click"):
		var object = get_object_under_mouse()
		handle_object_right_click(object)

	# Process preset camera view angles
	if Input.is_action_just_pressed("top_view"):
		OrCamera.look_at_from_position(Vector3(0, 50, 0), Vector3(0, 0, 0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
	if Input.is_action_just_pressed("bottom_view"):
		OrCamera.look_at_from_position(Vector3(0, -50, 0), Vector3(0, 0, -0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
	if Input.is_action_just_pressed("yellow_view"):
		OrCamera.look_at_from_position(Vector3(-18, 48, -18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("blue_view"):
		OrCamera.look_at_from_position(Vector3(-18, 48, 18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("red_view"):
		OrCamera.look_at_from_position(Vector3(18, 48, 18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("green_view"):
		OrCamera.look_at_from_position(Vector3(18, 48, -18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("yellow_view_floor"):
		OrCamera.look_at_from_position(Vector3(-30, 1, -30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("blue_view_floor"):
		OrCamera.look_at_from_position(Vector3(-30, 1, 30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("red_view_floor"):
		OrCamera.look_at_from_position(Vector3(30, 1, 30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("green_view_floor"):
		OrCamera.look_at_from_position(Vector3(30, 1, -30), Vector3(0, 1, 0), Vector3.UP)
		
	# Process camera zoom
	if Input.is_action_just_pressed("zoom_in") or Input.is_action_pressed("zoom_in"):
		zoom_camera(-1.5)
	if Input.is_action_just_pressed("zoom_out") or Input.is_action_pressed("zoom_out"):
		zoom_camera(1.5)

	# Handle toggle sound shortcut ('S' key) and display notification on board
	if Input.is_action_just_pressed("toggle_sound"):
		var is_sound_enabled = Globals.toggle_sound()
		var msg = tr("Sound ON") if is_sound_enabled else tr("Sound OFF")
		var text_color = Color.GREEN if is_sound_enabled else Color.RED
		var debug_text = get_node_or_null("DebugFloatingText")
		if debug_text:
			debug_text.show_text(msg, text_color)

	# Handle exit key shortcut back to main menu
	if Input.is_action_just_pressed("exit"):
		for player in self.board().players():
			if player.plays:
				player.dice().historical_report()
		get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
