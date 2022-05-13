class_name Dice
extends RigidBody
var vel : Vector3 = Vector3(0,-30,0)
var id: int
var value=null
var player

	
## Sets id, and initial properties and position
func set_id(node_id):
	self.id=node_id
	self.set_position(1)
	
func set_player(_player):
	self.player=_player
	
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
	self.player.can_move_dice=false
	self.value=null
	self.set_physics_process(true)
	self.set_position(10)
	randomize()

	var x = rand_range(-10,10)
	var y = rand_range(-10,10)
	var z = rand_range(-10,10)
	set_angular_velocity(Vector3(x,y,z))
	
	
func vector_is_almost_zero(v,precision=0.001):
	if self.value_almost_zero(v.x,precision) and self.value_almost_zero(v.y,precision) and self.value_almost_zero(v.z,precision):
		return true
	return false
	
func value_almost_zero(_value,precision=0.001):
	if abs(_value)<=precision:
		return true
	return false
	
func _physics_process(_delta):
	if self.value!=null and self.vector_is_almost_zero(self.angular_velocity) and self.vector_is_almost_zero(self.linear_velocity):
		print("Dice " + str(self.id) + " gets a "+ str(self.value))
		self.set_physics_process(false)
		self.player.dice_throws.append(self.value)
		self.player.can_move_pieces=true
	else:
		if $RC1.is_colliding():
			self.value=6
			$Dices.play()
		if $RC2.is_colliding():
			self.value=5
			$Dices.play()
		if $RC3.is_colliding():
			self.value=4
			$Dices.play()
		if $RC4.is_colliding():
			self.value=3
			$Dices.play()
		if $RC5.is_colliding():
			self.value=2
			$Dices.play()
		if $RC6.is_colliding():
			self.value=1
			$Dices.play()
		

	
