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
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		1:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		2:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		3:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		4:
			self.set_color(ColorN("blueviolet",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		5:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		6:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		7:
			self.set_color(ColorN("blue",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		8:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		9:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		10:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		11:
			self.set_color(ColorN("red",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		12:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		13:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		14:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
		15:
			self.set_color(ColorN("green",1))
			self.global_transform.origin=Vector3(-3*self.id+3, self.id*8, 10)
	
# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
func set_color(s):
	var image = load("res://images/wood.png")
	
	var new_material = SpatialMaterial.new()
	new_material.albedo_texture = image
	new_material.albedo_color = s
	$MeshInstance.material_override=new_material

