extends KinematicBody
class_name Piece

var vel : Vector3 = Vector3(0,-30,0)

var animation_to=null
var animation_step=0
var id : int = 0
var player: Player
var route: Route
var route_position: int 
var square_position: int = 0

var animation_num_steps=10


func _physics_process(_delta): 
	
	if animation_to!=null:
		self.animation_to.y=10
		var current=self.global_transform.origin
		var new_pos=(self.animation_to-current)*animation_step/self.animation_num_steps +current
		self.animation_step=self.animation_step+1
		self.global_transform.origin=new_pos
		print(self.animation_step, new_pos, self.animation_to)
		if self.animation_step==10:
			self.global_transform.origin=self.animation_to
			self.animation_step=0
			self.animation_to=null
	else:		
	#self.global_transform.origin=Globals.position4(square_final.id,new_square_position)	
		
		return move_and_slide(vel,Vector3.UP)

func _to_string():
	return "[Piece: "+ str(self.id) + "]"
	
## Sets id, and initial properties and position
func set_id(node_id):
	
	if Globals.debug:
		self.route_position=-1# Al iniciar mejor que no sea la primera para que se vea bien el debug y da igual
	else:
		self.route_position=0
	self.id=node_id
	
	match(self.id):
		0:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Globals.position4(101,0)
		1:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Globals.position4(101,1)
		2:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Globals.position4(101,2)
		3:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Globals.position4(101,3)
		4:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Globals.position4(102,0)
		5:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Globals.position4(102,1)
		6:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Globals.position4(102,2)
		7:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Globals.position4(102,3)
		8:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Globals.position4(103,0)
		9:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Globals.position4(103,1)
		10:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Globals.position4(103,2)
		11:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Globals.position4(103,3)
		12:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Globals.position4(104,0)
		13:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Globals.position4(104,1)
		14:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Globals.position4(104,2)
		15:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Globals.position4(104,3)
	
func square():
	return self.route.square_at(self.route_position)
	
# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
func set_color(s):
	var image = load("res://images/wood.png")
	
	var new_material = SpatialMaterial.new()
	new_material.albedo_texture = image
	new_material.albedo_color = s
	$MeshInstance.material_override=new_material
	
func set_player(p):
	self.player=p

func set_route(p):
	self.route=p
		
## Returns true if move was successful, else false
func move_to_route_position(_route_position, animation=false):
	var square_final=self.route.square_at(_route_position)
	var square_initial=self.square()
	
	if square_final==null:
		return false
	
	#Check if can move	
	var new_square_position=square_final.empty_position()
	if new_square_position ==-1:
		return false
		
	#Logical move
	if square_initial!=null: #Debug only
		square_initial.pieces[self.square_position]=null
	
	square_final.pieces[new_square_position]=self
	self.square_position=new_square_position
	
	self.route_position=_route_position
	
	#Interface move
	if animation == false:
		self.global_transform.origin=Globals.position4(square_final.id,new_square_position)	
	else:
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

