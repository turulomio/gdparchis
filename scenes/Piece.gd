extends KinematicBody
class_name Piece

var vel : Vector3 = Vector3(0,-30,0)
var id : int = 0

func _physics_process(_delta): 
	return move_and_slide(vel,Vector3.UP)

func set_id(node_id):
	self.id=node_id
	
	match(self.id):
		0:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		1:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		2:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
		3:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 50)
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
	
# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
func set_color(s):
	var image = load("res://images/wood.png")
	
	var new_material = SpatialMaterial.new()
	new_material.albedo_texture = image
	new_material.albedo_color = s
	$MeshInstance.material_override=new_material

