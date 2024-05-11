extends Node3D
class_name Game4

@onready var camera = $Camera
@onready var Board4Full=$Board4Full
var current_player


func get_object_under_mouse():
	var mouse_pos=get_viewport().get_mouse_position()
	var ray_from=camera.project_ray_origin(mouse_pos)
	var ray_to= ray_from + camera.project_ray_normal(mouse_pos)*100
	var space_state=get_world_3d().direct_space_state
	var selection=space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from,ray_to))
	if len(selection)==0:
		return null
	return selection.collider

# Called when the node enters the scene tree for the first time.
func _ready():	
	
	## Came from playersselection or load_directly
	var d=Globals.game_data

	Globals.game_load_glogals_game_data(self)



	# Start game
	self.current_player=self.Board4Full.players()[d["current"]]
	self.current_player.can_move_pieces=false
	self.current_player.dice_throws=[]
	self.current_player.can_throw_dice=true
	if self.current_player.ia==true or Globals.settings.get("automatic", true)==true:
		self.current_player.dice.on_clicked()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		var object=get_object_under_mouse()
		if object == null:
			return
		if object is Piece:
			if object.player==self.current_player and object.player.can_move_pieces:
				object.on_clicked()
			else:
				$Click.play()
		if object is Dice:
			if object.player==self.current_player and object.player.can_throw_dice:
				object.on_clicked()
			else:
				$Click.play()

		
	if Input.is_action_just_pressed("orto_view"):
		camera.look_at_from_position(Vector3(0,47,0),Vector3(0,0,0.001),Vector3.UP)
		camera.global_rotate(Vector3(0,1,0),PI)
	if Input.is_action_just_pressed("yellow_view"):
		camera.look_at_from_position(Vector3(-30,50,-30),Vector3(0,3,0),Vector3.UP)
	if Input.is_action_just_pressed("blue_view"):
		camera.look_at_from_position(Vector3(-30,50,30),Vector3(0,3,0),Vector3.UP)
	if Input.is_action_just_pressed("red_view"):
		camera.look_at_from_position(Vector3(30,50,30),Vector3(0,3,0),Vector3.UP)
	if Input.is_action_just_pressed("green_view"):
		camera.look_at_from_position(Vector3(30,50,-30),Vector3(0,3,0),Vector3.UP)
	if Input.is_action_pressed("zoom_in"):
		camera.global_transform.origin.y=camera.global_transform.origin.y-1
	if Input.is_action_pressed("zoom_out"):
		camera.global_transform.origin.y=camera.global_transform.origin.y+1
	if Input.is_action_just_pressed("exit"):
		for player in self.players.values():
			if player.plays:
				player.dice.historical_report()
		
		get_tree().change_scene_to_file("res://scenes/Main.tscn")
	#if Input.is_action_just_pressed("full_screen"):
		#OS.window_fullscreen = !OS.window_fullscreen
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
				print("  + Threats after: ", object.threats_at(object.route.square_at(object.route_position+object.squares_to_move())))
				
		if object is Dice and OS.is_debug_build():
			$Popup.set_text(object.historical_report())
			

func change_current_player():
	if self.current==null:
		self.current= self.d["0"]
	elif self.current==self.d["0"]:
		self.current = self.d["1"]
	elif self.current==self.d["1"]:
		self.current = self.d["2"]
	elif self.current==self.d["2"]:
		self.current = self.d["3"]
	elif self.current==self.d["3"]:
		self.current = self.d["0"]
		
	print("Current player now is ", self.current.name)
		
	if self.current.plays==false:
		self.change_current_player()
		return
		
	self.current.last_piece_moved=null
	self.current.can_move_pieces=false
	self.current.dice_throws=[]
	self.current.extra_moves=[]
	self.current.can_throw_dice=true
	if self.current.ia==true:
		self.current.dice.on_clicked()
	else:#Not ia
		print(self.current.game)
		Globals.save_game(self.current.game)
		if Globals.settings.get("automatic",true)==true:
			self.current.dice.on_clicked()
	
