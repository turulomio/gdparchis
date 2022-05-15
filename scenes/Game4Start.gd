extends Spatial
class_name Game4Start

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
	
	var new_material = SpatialMaterial.new()
	new_material.albedo_texture = Globals.IMAGE_WOOD
	new_material.albedo_color = ColorN("white",1)
	$Board4/MeshInstance.material_override=new_material
	
	if Globals.game_data==null: #New game
		Globals.game_data=Globals.new_game(4)
	
	var d=Globals.game_data
	print("DATA", d)
	
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
		var player=Player.new(d_player["id"],d_player["plays"])
		player.set_route(self.routes[str(player.id)])
		self.players.append(player)
		
	for p in self.players.values():
		p.set_game(self)
		var dice=Globals.SCENE_DICE.instance()
		self.add_child(dice)
		dice.set_id(p.id)
		dice.set_player(p)
		p.set_dice(dice)


	# Start game
	self.players.current=self.players.get(str(d["current"]))
	self.players.current.dice_throws=[]
	self.players.current.dice.prepare_to_launch()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if Input.is_action_just_pressed("left_click"):
		var object=get_object_under_mouse()
		if object.filename=="res://scenes/Dice.tscn":
			if object.player==self.players.current and object.player.can_move_dice:
				object.on_clicked()
			else:
				$Click.play()

	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene("res://scenes/Main.tscn")
