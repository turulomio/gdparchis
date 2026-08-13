extends Node3D
class_name Game4

@onready var OrCamera = $Camera
@onready var OrBoard = $Board4
@onready var OrPopup = $Popup
var current_player


## Returns the Board4 child node instance.
## @return Board4 node.
func board():
	return $Board4


## Performs a 3D raycast query from mouse position into the scene world.
## @return Physics object collider hit by raycast, or null.
func get_object_under_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = OrCamera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + OrCamera.project_ray_normal(mouse_pos) * 100
	var space_state = get_world_3d().direct_space_state
	var selection = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from, ray_to))
	if len(selection) == 0:
		return null
	return selection.collider


## Evaluates if any active player has won and triggers the game victory completion sequence.
## @return True if a winner was confirmed and game transition initiated.
func check_game_over() -> bool:
	for player in self.board().players_than_plays():
		if player.has_won():
			$DebugFloatingText.show_text(tr("Player {0} wins").format([player.playername]), player.color)
			await $DebugFloatingText.text_disappear
			
			print("Registering end of game:")	
			var fields = {
				"game_uuid": Globals.game_data.game_uuid,
				"human_won": not player.ia,
			}
			print(fields)
			get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
			return true
	return false


## Scene entry point. Initializes board data, player turns, and auto-throws if AI.
func _ready():	
	print("LOADING GAME4")
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
		if object == null:
			return
		if object is Piece:
			if object.player() == self.current_player and object.player().can_move_pieces:
				object.on_clicked()
			else:
				$Click.play()
		if object is Dice:
			if object.player() == self.current_player and object.player().can_throw_dice:
				object.on_clicked()
			else:
				$Click.play()

	# Process preset camera view angles
	if Input.is_action_just_pressed("top_view"):
		OrCamera.look_at_from_position(Vector3(0, 47, 0), Vector3(0, 0, 0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
		$DebugFloatingText.show_text(tr("Upps, I did it again"), Color.CHOCOLATE)
	if Input.is_action_just_pressed("bottom_view"):
		OrCamera.look_at_from_position(Vector3(0, -47, 0), Vector3(0, 0, -0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
	if Input.is_action_just_pressed("yellow_view"):
		OrCamera.look_at_from_position(Vector3(-30, 50, -30), Vector3(0, 3, 0), Vector3.UP)
		OrCamera.global_transform.origin.y -= 18
	if Input.is_action_just_pressed("blue_view"):
		OrCamera.look_at_from_position(Vector3(-30, 50, 30), Vector3(0, 3, 0), Vector3.UP)
		OrCamera.global_transform.origin.y -= 18
	if Input.is_action_just_pressed("red_view"):
		OrCamera.look_at_from_position(Vector3(30, 50, 30), Vector3(0, 3, 0), Vector3.UP)
		OrCamera.global_transform.origin.y -= 18
	if Input.is_action_just_pressed("green_view"):
		OrCamera.look_at_from_position(Vector3(30, 50, -30), Vector3(0, 3, 0), Vector3.UP)
		OrCamera.global_transform.origin.y -= 18
	if Input.is_action_just_pressed("yellow_view_floor"):
		OrCamera.look_at_from_position(Vector3(-30, 1, -30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("blue_view_floor"):
		OrCamera.look_at_from_position(Vector3(-30, 1, 30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("red_view_floor"):
		OrCamera.look_at_from_position(Vector3(30, 1, 30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("green_view_floor"):
		OrCamera.look_at_from_position(Vector3(30, 1, -30), Vector3(0, 1, 0), Vector3.UP)
		
	# Process camera zoom
	if Input.is_action_pressed("zoom_in"):
		OrCamera.global_transform.origin.y = OrCamera.global_transform.origin.y - 1
	if Input.is_action_pressed("zoom_out"):
		OrCamera.global_transform.origin.y = OrCamera.global_transform.origin.y + 1
		
	# Handle exit to main menu
	if Input.is_action_just_pressed("exit"):
		for player in self.board().players():
			if player.plays:
				player.dice().historical_report()
		get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
		
	# Handle fullscreen toggle
	if Input.is_action_just_pressed("full_screen"):
		Globals.toggle_window_mode()
		
	# Handle right-click debug popup info
	if Input.is_action_just_pressed("right_click"):
		var object = get_object_under_mouse()
		if object == null:
			return
		if object is Piece:
			var s = "Piece " + str(object) + " " + object.player().name + "\n"
			if object.player() == self.current_player and object.player().can_move_pieces:
				s += "  + Can move: " + str(object.can_move_stm())
				s += "  + Can eat before: " + str(object.can_eat_before_stm())
				s += "  + Can eat after: " + str(object.can_eat_at_route_position(object.route_position + object.squares_to_move(), false))
				s += "  + Threats before: " + str(object.threats_at(object.square()))
				s += "  + Threats after: " + str(object.threats_at(object.route().square_at(object.route_position + object.squares_to_move())))
			OrPopup.set_text(s)
				
		if object is Dice and OS.is_debug_build():
			OrPopup.set_text(object.historical_report())


## Rotates turn to next participating player, saves game state, and initiates turn action.
func change_current_player():
	# Check if an active player has won before changing turn
	if await self.check_game_over():
		return

	# Cycle player turn in sequence (0 -> 1 -> 2 -> 3 -> 0)
	if self.current_player == null:
		self.current_player = self.board().players()[0]
	elif self.current_player == self.board().players()[0]:
		self.current_player = self.board().players()[1]
	elif self.current_player == self.board().players()[1]:
		self.current_player = self.board().players()[2]
	elif self.current_player == self.board().players()[2]:
		self.current_player = self.board().players()[3]
	elif self.current_player == self.board().players()[3]:
		self.current_player = self.board().players()[0]
		
	print("Current player now is ", self.current_player.name)
		
	# Skip inactive non-participating players or players who have already won
	if self.current_player.plays == false or self.current_player.has_won():
		self.change_current_player()
		return
		
	# Reset state variables for new turn
	self.current_player.last_piece_moved = null
	self.current_player.can_move_pieces = false
	self.current_player.dice_throws = []
	self.current_player.extra_moves = []
	self.current_player.can_throw_dice = true
	
	# Update dice visibility so only current player's dice is visible
	for p in self.board().players():
		p.dice().visible = (p == self.current_player)
	
	# Realign and drop all active pieces on the board to correct any displacement
	for p in self.board().players():
		for piece in p.pieces():
			if piece.visible:
				piece.correct_position_and_drop(0.12)
	
	# Autosave current game progress
	Globals.save_game(self)
	
	# Auto-trigger dice throw for AI or automatic mode
	if self.current_player.ia == true:
		self.current_player.dice().on_clicked()
	else:
		if Globals.settings.get("automatic", true) == true:
			self.current_player.dice().on_clicked()
