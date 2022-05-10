extends Spatial


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
	
	## Creating players
	self.max_players=4
	self.players=PlayerManager.new(self.max_players)
	
	## Creating squares
	self.squares=SquareManager.new()
	for i in range(1,105):
		self.squares.append(Square.new(i))
		
	## Creating routes
	self.routes={}
	for e_color in Globals.e_colors(self.max_players):
		self.routes[str(e_color)]=Route.new(self.max_players, e_color, self.squares)
	
	# Create players pieces
	var piece_scene=load("res://scenes/Piece.tscn")
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
	
	for p in players.d.values():
		print (p.pieces)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("piece_click"):
		var object=get_object_under_mouse()
		if object.filename=="res://scenes/Piece.tscn":
			object.global_transform.origin.y=20
			print(object.id)

		
	if Input.is_action_just_pressed("zoom_in"):
		camera.global_transform.origin.y=camera.global_transform.origin.y-20
	if Input.is_action_just_pressed("zoom_out"):
		camera.global_transform.origin.y=camera.global_transform.origin.y+20
