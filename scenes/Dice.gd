class_name Dice
extends RigidBody
var vel : Vector3 = Vector3(0,-30,0)
var id: int

	
## Sets id, and initial properties and position
func set_id(node_id):
	self.id=node_id
	self.set_position(1)
	
func set_position(h):
	match(self.id):
		0:
			self.global_transform.origin=Vector3(-14,h,-14)
		1:
			self.global_transform.origin=Vector3(-14,h,14)
		2:
			self.global_transform.origin=Vector3(14,h,14)
		3:
			self.global_transform.origin=Vector3(14,h,-14)
			
func launch():
	self.set_position(10)
	randomize()

	var x = rand_range(-10,10)
	var y = rand_range(-10,10)
	var z = rand_range(-10,10)
	set_angular_velocity(Vector3(x,y,z))
