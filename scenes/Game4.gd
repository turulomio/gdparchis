extends Node3D
class_name Game4

@onready var OrCamera = $Camera
@onready var OrBoard=$Board4
var current_player

func board():
	return $Board4

func get_object_under_mouse():
	var mouse_pos=get_viewport().get_mouse_position()
	var ray_from=OrCamera.project_ray_origin(mouse_pos)
	var ray_to= ray_from + OrCamera.project_ray_normal(mouse_pos)*100
	var space_state=get_world_3d().direct_space_state
	var selection=space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from,ray_to))
	if len(selection)==0:
		return null
	return selection.collider

# Called when the node enters the scene tree for the first time.
func _ready():	
	print("LOADING GAME4")
	## Came from playersselection or load_directly
	var d=Globals.game_data

	Globals.game_load_glogals_game_data(self,true)

	# Start game
	self.current_player=self.board().players()[d["current"]]
	self.current_player.can_move_pieces=false
	self.current_player.dice_throws=[]
	self.current_player.can_throw_dice=true
	if self.current_player.ia==true or Globals.settings.get("automatic", true):
		self.current_player.dice().on_clicked()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		var object=get_object_under_mouse()
		if object == null:
			return
		if object is Piece:
			if object.player()==self.current_player and object.player().can_move_pieces:
				object.on_clicked()
			else:
				$Click.play()
		if object is Dice:
			if object.player()==self.current_player and object.player().can_throw_dice:
				object.on_clicked()
			else:
				$Click.play()

		
	if Input.is_action_just_pressed("top_view"):
		OrCamera.look_at_from_position(Vector3(0,47,0),Vector3(0,0,0.001),Vector3.UP)
		OrCamera.global_rotate(Vector3(0,1,0),PI)
	if Input.is_action_just_pressed("bottom_view"):
		OrCamera.look_at_from_position(Vector3(0,-47,0),Vector3(0,0,-0.001),Vector3.UP)
		OrCamera.global_rotate(Vector3(0,1,0),PI)
	if Input.is_action_just_pressed("yellow_view"):
		OrCamera.look_at_from_position(Vector3(-30,50,-30),Vector3(0,3,0),Vector3.UP)
	if Input.is_action_just_pressed("blue_view"):
		OrCamera.look_at_from_position(Vector3(-30,50,30),Vector3(0,3,0),Vector3.UP)
	if Input.is_action_just_pressed("red_view"):
		OrCamera.look_at_from_position(Vector3(30,50,30),Vector3(0,3,0),Vector3.UP)
	if Input.is_action_just_pressed("green_view"):
		OrCamera.look_at_from_position(Vector3(30,50,-30),Vector3(0,3,0),Vector3.UP)
	if Input.is_action_pressed("zoom_in"):
		OrCamera.global_transform.origin.y=OrCamera.global_transform.origin.y-1
	if Input.is_action_pressed("zoom_out"):
		OrCamera.global_transform.origin.y=OrCamera.global_transform.origin.y+1
	if Input.is_action_just_pressed("exit"):
		for player in self.board().players():
			if player.plays:
				player.dice().historical_report()
		
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	if Input.is_action_just_pressed("full_screen"):
		Globals.toggle_window_mode()
	if Input.is_action_just_pressed("right_click"):
		var object=get_object_under_mouse()
		if object == null:
			return
		if object is Piece:
			print("Piece", str(object), " ", object.player.name)
			if object.player==self.current_player and object.player.can_move_pieces:
				print("  + Can move: ", object.can_move_stm())
				print("  + Can eat before: ", object.can_eat_before_stm())
				print("  + Can eat after: ", object.can_eat_at_route_position(object.route_position+object.squares_to_move(),false))
			print("  + Threats before: ", object.threats_at(object.square()))
				
			if object.player==self.current_player and object.player.can_move_pieces:
				print("  + Threats after: ", object.threats_at(object.route().square_at(object.route_position+object.squares_to_move())))
				
		if object is Dice and OS.is_debug_build():
			$Popup.set_text(object.historical_report())
			

func change_current_player():
	if self.current_player==null:
		self.current_player= self.board().players()[0]
	elif self.current_player==self.board().players()[0]:
		self.current_player = self.board().players()[1]
	elif self.current_player==self.board().players()[1]:
		self.current_player = self.board().players()[2]
	elif self.current_player==self.board().players()[2]:
		self.current_player = self.board().players()[3]
	elif self.current_player==self.board().players()[3]:
		self.current_player = self.board().players()[0]
		
	print("Current player now is ", self.current_player.name)
		
	if self.current_player.plays==false:
		self.change_current_player()
		return
		
	self.current_player.last_piece_moved=null
	self.current_player.can_move_pieces=false
	self.current_player.dice_throws=[]
	self.current_player.extra_moves=[]
	self.current_player.can_throw_dice=true
	if self.current_player.ia==true:
		self.current_player.dice().on_clicked()
	else:#Not ia
		#print(self.current_player.game())
		Globals.save_game(self.current_player.game())
		if Globals.settings.get("automatic",true)==true:
			self.current_player.dice().on_clicked()
	
