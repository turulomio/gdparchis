extends KinematicBody
class_name Piece


signal piece_moved
var vel : Vector3 = Vector3(0,-30,0)

var animation_to=null
var animation_step=0
var id : int =1000
var player: Player
var route: Route
var route_position: int 
var square_position: int

var animation_num_steps=10
var animation_max_y=10


var animation_waiting_grades=0


func _physics_process(_delta): 
	
	if animation_to!=null:
		var current=self.global_transform.origin
		var new_pos
		if self.animation_num_steps==0:
			new_pos=self.animation_to
		else:
			#Sets step
			new_pos=(self.animation_to-current)*self.animation_step/self.animation_num_steps +current
			#Sets y with sin function
			new_pos.y=self.animation_to.y+self.animation_max_y*sin(deg2rad(180*self.animation_step/self.animation_num_steps))
		self.animation_step=self.animation_step+1
		self.global_transform.origin=new_pos
		if self.animation_step==self.animation_num_steps:
			self.global_transform.origin=self.animation_to
			self.animation_step=0
			self.player.can_move_pieces=false
			emit_signal("piece_moved")
			self.animation_to=null
	elif self.player.game.filename!="res://scenes/Game4Objects" and self.player.game.players.current== self.player and self.player.can_move_pieces== true:
		self.animation_waiting_grades=self.animation_waiting_grades+5
		self.global_transform.origin.y=1.2+sin(deg2rad(self.animation_waiting_grades))/2
	elif self.animation_waiting_grades==0:
		return move_and_slide(vel,Vector3.UP)

		

func _to_string():
	return "[Piece: "+ str(self.id) + "]"
	
## Sets id, and initial properties and position
func set_id(_id,_player,_route_position, _square_position):
	self.route_position=_route_position
	self.id=_id
	self.player=_player
	self.route_position=_route_position
	self.square_position=_square_position
	self.set_color(Globals.colorn(self.player.id))
	self.route=self.player.route

	
func square():
	return self.route.square_at(self.route_position)
	
# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
func set_color(s):
	var image = load("res://images/wood.png")
	
	var new_material = SpatialMaterial.new()
	new_material.albedo_texture = image
	new_material.albedo_color = s
	$MeshInstance.material_override=new_material
			
func can_move_to_route_position(_route_position):
	var square_initial=self.square()
	var square_final=self.route.square_at(_route_position)
	##DEbe sacar si es un 5
	if self.player.last_throw()==5 and self.player.are_all_pieces_out_of_home()==false and self.route.square_at(1).pieces.size()<2 and self.position_route!=0:
		return false 
	
	if square_initial.type==Globals.eSquareTypes.START and self.player.last_throw()!=5:
		return false
	
	if square_final==null:
		return false
	#Check if can move	
	var new_square_position=square_final.empty_position()
	if new_square_position ==-1:
		return false
	return true
		
## Before this method always have to check if piece can move
func move_to_route_position(_route_position, _animation_num_steps=0):
	self.animation_waiting_grades=0
	self.animation_num_steps=_animation_num_steps
	var square_final=self.route.square_at(_route_position)
	var square_initial=self.square()
	
		
	square_initial.pieces[self.square_position]=null
	
	var new_square_position=square_final.empty_position()
	square_final.pieces[new_square_position]=self
	self.square_position=new_square_position
	
	self.route_position=_route_position
	
	self.animation_to=Globals.position4(square_final.id,new_square_position)
	self.animation_step=0
	self.change_scale_on_specials_squares()
	
#Para casillas estrechas
func change_scale_on_specials_squares():
	if self.player.game.max_players==4:
		if self.square().id in [8,9,25,26,42,43,59,60]:
			self.scale=Vector3(0.8,1,0.8)
		else:
			self.scale=Vector3(1,1,1)

func squares_to_move():
	if self.square().type==Globals.eSquareTypes.START and self.player.last_throw()==5:
		return 1
	elif self.player.are_all_pieces_out_of_home() and self.player.last_throw()==6:
		return 7
	else:
		return self.player.last_throw()
	

func on_clicked():
	if self.can_move_to_route_position(self.route_position+self.squares_to_move()):
		self.move_to_route_position(self.route_position+self.squares_to_move(), 20)
		yield(self,"piece_moved")
		self.player.last_piece_moved=self
	else: # Ha pulsado una ficha que no se puede mover
		$Click.play()
		return
		
	## Check if player can continue playing
	if self.player.can_move_other_piece()==true:
		self.player.can_move_pieces=true
		
	elif self.player.can_move_dice_again():
		self.player.can_move_dice=true
		self.player.dice.value=null
		self.player.dice.set_physics_process(true)
	else:
		self.player.game.players.change_current_player()
		
