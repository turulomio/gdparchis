# extends Node3D
# class_name Game4Objects

# @onready var camera =$Camera
# var players
# var pieces 
# var max_players
# var squares
# var routes

# func get_object_under_mouse():
# 	var mouse_pos=get_viewport().get_mouse_position()
# 	var ray_from=$Camera.project_ray_origin(mouse_pos)
# 	var ray_to= ray_from + $Camera.project_ray_normal(mouse_pos)*1000
# 	var space_state=get_world_3d().direct_space_state
# 	var selection=space_state.intersect_ray(PhysicsRayQueryParameters3D.create(ray_from,ray_to))
# 	return selection.collider

# # Called when the node enters the scene tree for the first time.
# # func _ready():
	
# 	# ## Creating players
# 	# self.max_players=4
		
# 	# ## Creating squares
# 	# self.squares=SquareManager.new()
# 	# for i in range(1,105):
# 	# 	self.squares.append(Square.new(i))


# 	# ## Creating routes
# 	# self.routes={}
# 	# for e_color in Globals.e_colors(self.max_players):
# 	# 	self.routes[str(e_color)]=Route.new(self.max_players, e_color, self.squares)

	
	
	
# 	# self.players=PlayerManager.new(self.max_players)
# 	# for i in range(self.max_players):
# 	# 	var player=Player.new(i,true,true)
# 	# 	player.set_route(self.routes[str(player.id)])
# 	# 	self.players.append(player)
# 	# for p in self.players.values():
# 	# 	p.set_game(self)
# 	# 	var dice=Globals.SCENE_DICE.instance()
# 	# 	self.add_child(dice)
# 	# 	dice.set_id(p.id)
# 	# 	dice.set_player(p)
# 	# 	p.set_dice(dice)

# 	# ## DEBUG SHOWS ALL PIECES IN ALL SQUARES		
# 	# var id=1000
# 	# for route in self.routes.values():
# 	# 	var route_pos=0
# 	# 	for s in route.arr:
# 	# 		while s.empty_position()>=0:
# 	# 			var player=self.players.my_get(route.id)
# 	# 			var piece=Globals.SCENE_PIECE.instance()
# 	# 			piece.set_id(id,player,s.id,s.empty_position())
# 	# 			id=id+1
				
# 	# 			self.add_child(piece)
# 	# 			piece.set_color(Globals.colorn(s.empty_position()))
# 	# 			game4objects_move_to_route_position(piece,route_pos,0)
# 	# 		route_pos=route_pos+1
			
# ## Before this method always have to check if piece can move
# func game4objects_move_to_route_position(piece,_route_position, duration):
# 	var square_final=piece.route().square_at(_route_position)
	
# 	var new_square_position=square_final.empty_position()
# 	square_final.set_piece_at_square_position(new_square_position,piece)
# 	piece.square_position=new_square_position
	
# 	piece.route_position=_route_position
	
# 	piece.TweenMoving_start(Globals.position4(square_final.id,new_square_position), duration)
	
# 	piece.change_scale_on_specials_squares()

# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(_delta):	
# 	if Input.is_action_just_pressed("left_click"):
# 		var object=get_object_under_mouse()
# 		if object is Piece:
# 			object.global_transform.origin.y=10
# 		if object is Dice:
# 			object.global_transform.origin.y=10
# 			await object.dice_got_value
# 			object.set_physics_process(true)

		
# 	if Input.is_action_just_pressed("zoom_in"):
# 		camera.global_transform.origin.y=camera.global_transform.origin.y-20
# 	if Input.is_action_just_pressed("zoom_out"):
# 		camera.global_transform.origin.y=camera.global_transform.origin.y+20
# 	if Input.is_action_just_pressed("exit"):
# 		get_tree().change_scene_to_file("res://scenes/Main.tscn")
# 	#if Input.is_action_just_pressed("full_screen"):
# 		#OS.window_fullscreen = !OS.window_fullscreen
