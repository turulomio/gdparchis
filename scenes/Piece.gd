extends KinematicBody
class_name Piece

var vel : Vector3 = Vector3(0,-30,0)
var id : int = 0
var player: Player
var route: Route
var route_position: int = 0
var square_position: int = 0

func _physics_process(_delta): 
	return move_and_slide(vel,Vector3.UP)

func _to_string():
	return "[Piece: "+ str(self.id) + "]"
	
## Sets id, and initial properties and position
func set_id(node_id):
	self.id=node_id
	
	match(self.id):
		0:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Globals.position4(115,0)
		1:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Globals.position4(115,1)
		2:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Globals.position4(115,2)
		3:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Globals.position4(115,3)
		4:
			self.set_color(ColorN("blueviolet",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		5:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		6:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		7:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		8:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		9:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		10:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		11:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		12:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		13:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		14:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		15:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
	
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
func move_to_route_position(route_position):
	var square_final=self.route.square_at((route_position))
	var square_initial=self.route.square()
	
	#Check if can move	
	var new_square_position=square_final.empty_position()
	if new_square_position ==null:
		return false
		
	#Logical move
	square_initial.pieces[self.square_position]=null
	square_final.pieces[new_square_position]=self
	self.square_position=new_square_position
	
	#Interface move
	self.global_transform.origin=Globals.position4(square_final.id,new_square_position)	

