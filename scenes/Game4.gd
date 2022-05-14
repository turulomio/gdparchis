extends Spatial
class_name Game4

onready var camera =$Camera
var players
var pieces 
var max_players
var squares
var routes

func get_object_under_mouse():
	var mouse_pos=get_viewport().get_mouse_position()
	var ray_from=$Camera.project_ray_origin(mouse_pos)
	var ray_to= ray_from + $Camera.project_ray_normal(mouse_pos)*1000
	var space_state=get_world().direct_space_state
	var selection=space_state.intersect_ray(ray_from,ray_to)
	return selection.collider

# Called when the node enters the scene tree for the first time.
func _ready():
	var piece_scene=load("res://scenes/Piece.tscn")
	var dice_scene=load("res://scenes/Dice.tscn")
	
	## Creating players
	self.max_players=4
	self.players=PlayerManager.new(self.max_players)
	self.players.set_assistant($Assistant)
	for p in self.players.values():
		p.set_game(self)
		var dice=dice_scene.instance()
		self.add_child(dice)
		dice.set_id(p.id)
		dice.set_player(p)
		p.set_dice(dice)
	
	## Creating squares
	self.squares=SquareManager.new()
	for i in range(1,105):
		self.squares.append(Square.new(i))

	## Creating routes
	self.routes={}
	for e_color in Globals.e_colors(self.max_players):
		self.routes[str(e_color)]=Route.new(self.max_players, e_color, self.squares)

	
	
	## DEBUG SHOWS ALL PIECES IN ALL SQUARES		
	if Globals.debug==true:
		for route in self.routes.values():
			var route_pos=0
			for s in route.arr:
				while s.empty_position()>=0:
					var piece=piece_scene.instance()
					self.add_child(piece)
					piece.set_color(Globals.colorn(s.empty_position()))
					piece.set_player(self.players.get(route.e_color))
					piece.set_route(route)
					piece.move_to_route_position(route_pos)
				route_pos=route_pos+1
		return
		
	# Create players pieces
	for i in range(16):
		var player=self.players.get(int(i / self.max_players)) 
		var route=self.routes[str(player.id)]
		var piece=piece_scene.instance()
		self.add_child(piece)
		piece.set_route(route)
		piece.set_player(player)
		piece.set_id(i)
		
		player.set_route(route)
		player.append_piece(piece) #Link piece to player bidirectional		

	# Start game
	self.players.current=self.players.get(3)
	self.players.change_current_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if Input.is_action_just_pressed("right_click"):
		var object=get_object_under_mouse()
		if object.filename=="res://scenes/Piece.tscn":
			object.global_transform.origin.y=20
			print(object.id)
	if Input.is_action_just_pressed("left_click"):
		var object=get_object_under_mouse()
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

		
	if Input.is_action_just_pressed("zoom_in"):
		camera.global_transform.origin.y=camera.global_transform.origin.y-20
	if Input.is_action_just_pressed("zoom_out"):
		camera.global_transform.origin.y=camera.global_transform.origin.y+20
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("full_screen"):
		OS.window_fullscreen = !OS.window_fullscreen
