extends Spatial
class_name Game4

onready var camera = $Camera
var players
var pieces 
var max_players
var squares
var routes

func get_object_under_mouse():
	var mouse_pos=get_viewport().get_mouse_position()
	var ray_from=camera.project_ray_origin(mouse_pos)
	var ray_to= ray_from + camera.project_ray_normal(mouse_pos)*100
	var space_state=get_world().direct_space_state
	var selection=space_state.intersect_ray(ray_from,ray_to)
	print(camera,selection)
	if len(selection)==0:
		return null
	return selection.collider

# Called when the node enters the scene tree for the first time.
func _ready():	
	
	## Came from playersselection or load_directly
	var d=Globals.game_data
	
	## Creating players
	self.max_players=4
	
	## Creating squares
	self.squares=SquareManager.new()
	for i in range(1,105):
		self.squares.append(Square.new(i))

	## Creating routes
	self.routes={}
	for e_color in Globals.e_colors(self.max_players):
		self.routes[str(e_color)]=Route.new(self.max_players, e_color, self.squares)

	self.players=PlayerManager.new(self.max_players)
	for d_player in d["players"]:
		var player=Player.new(int(d_player["id"]),d_player["plays"],d_player["ia"])
		player.set_route(self.routes[str(player.id)])
		self.players.append(player)
		
	self.players.set_assistant($Assistant)
	
	for p in self.players.values():
		p.set_game(self)
		if p.plays==true:
			var dice=Globals.SCENE_DICE.instance()
			self.add_child(dice)
			dice.set_id(p.id)
			dice.set_player(p)
			p.set_dice(dice)

	# Create players pieces
	for d_player in d["players"]:
		var square_position=0
		var player=self.players.get(d_player["id"])
		if player.plays:  
			for d_piece in d_player["pieces"]:
				var route=self.routes[str(player.id)]
				var piece=Globals.SCENE_PIECE.instance()
				self.add_child(piece)
				piece.set_id(d_piece["id"],player,route.end_position(),square_position)
				player.append_piece(piece) #Link piece to player bidirectional
				square_position=square_position+1
				piece.move_to_route_position(route.end_position(),1) 
				yield(piece,"piece_moved")
				piece.move_to_route_position(d_piece["route_position"],8) 
				yield(piece,"piece_moved")

	# Start game
	self.players.current=self.players.get(str(d["current"]))
	$Assistant.set_color(Globals.colorn(self.players.current.id))
	self.players.current.can_move_pieces=false
	self.players.current.dice_throws=[]
	self.players.current.dice.prepare_to_launch()
	if self.players.current.ia==true:
		self.players.current.dice.on_clicked()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		var object=get_object_under_mouse()
		if object == null:
			return
		if object.filename=="res://scenes/Piece.tscn":
			if object.player==self.players.current and object.player.can_move_pieces:
				object.on_clicked()
			else:
				$Click.play()
		if object.filename=="res://scenes/Dice.tscn":
			if object.player==self.players.current and object.player.can_move_dice:
				object.on_clicked()
			else:
				$Click.play()
		if object.filename=="res://scenes/Assistant.tscn":
			self.players.change_current_player()

		
	if Input.is_action_just_pressed("orto_view"):
		camera.look_at_from_position(Vector3(0,47,0),Vector3(0,0,0.1),Vector3.UP)
	if Input.is_action_just_pressed("blue_view"):
		camera.look_at_from_position(Vector3(-30,30,30),Vector3(0,3,0),Vector3.UP)
	if Input.is_action_pressed("zoom_in"):
		camera.global_transform.origin.y=camera.global_transform.origin.y-1
	if Input.is_action_pressed("zoom_out"):
		camera.global_transform.origin.y=camera.global_transform.origin.y+1
	if Input.is_action_just_pressed("exit"):
		for player in self.players.values():
			player.dice.historical_report()
		
		get_tree().change_scene("res://scenes/Main.tscn")
	if Input.is_action_just_pressed("full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
