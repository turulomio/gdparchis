extends KinematicBody
class_name SquareNormal4

var vel : Vector3 = Vector3(0,-100,0)
var id : int = 0

func _physics_process(_delta): 
	return move_and_slide(vel,Vector3.UP)

	
# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
func set_color(s):
	var image = load("res://images/wood.png")
	
	var new_material = SpatialMaterial.new()
	new_material.albedo_texture = image
	new_material.albedo_color = s
	$MeshInstance.material_override=new_material

func set_id(node_id):
	self.id=node_id

	match(self.id):
		0:
			self.set_color(ColorN("yellow",1))
			self.global_transform.origin=Vector3(-3*self.id+5, self.id*8, 10)
		_:
			self.set_color(ColorN("white",1))
			self.global_transform.origin=Vector3(-3*self.id+5, self.id*8, 10)
