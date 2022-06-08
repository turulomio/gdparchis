class_name Dice
extends RigidBody
signal dice_got_value
var vel : Vector3 = Vector3(0,-30,0)
var id: int
var value=null
var player
var animation_waiting_grades=0
var has_touch=false

	
## Sets id, and initial properties and position
func set_id(node_id):
	self.id=node_id
	self.set_position(1)
	
func set_player(_player):
	self.player=_player
	
func set_position(h):
	match(self.id):
		0:
			self.global_transform.origin=Vector3(-20,h,-25)
		1:
			self.global_transform.origin=Vector3(-25,h,20)
		2:
			self.global_transform.origin=Vector3(20,h,25)
		3:
			self.global_transform.origin=Vector3(25,h,-20)
			
			
func launch():
	self.animation_waiting_grades=0
	self.player.can_move_dice=false
	self.value=null
	self.set_physics_process(true)
	self.set_position(10)
	randomize()
	
	var x = rand_range(-10,10)
	var y = rand_range(-10,10)
	var z = rand_range(-10,10)
	self.transform.rotated(Vector3(x,y,z).normalized(), rand_range(0, 2*PI))
	self.set_axis_velocity(Vector3(0, rand_range(0,3) ,0))
	set_angular_velocity(Vector3(x,y,z))
	

	
func _physics_process(_delta):
	if self.value!=null and Globals.vector_is_almost_zero(self.angular_velocity) and Globals.vector_is_almost_zero(self.linear_velocity):
		print("Dice " + str(self.id) + " gets a "+ str(self.value))
		self.set_physics_process(false)
		self.player.dice_throws.append(self.value)
		emit_signal("dice_got_value")
		
	elif self.player.is_current() and self.player.can_move_dice== true:
		self.animation_waiting_grades=self.animation_waiting_grades+5
		self.global_transform.origin.y=2+sin(deg2rad(self.animation_waiting_grades))/2
		
	elif self.animation_waiting_grades==0:
		if $RC1.is_colliding():
			self.value=6
			if self.has_touch==false:
				$Touched.play()
				self.has_touch=true
		if $RC2.is_colliding():
			self.value=5
			if self.has_touch==false:
				$Touched.play()
				self.has_touch=true
		if $RC3.is_colliding():
			self.value=4
			if self.has_touch==false:
				$Touched.play()
				self.has_touch=true
		if $RC4.is_colliding():
			self.value=3
			if self.has_touch==false:
				$Touched.play()
				self.has_touch=true
		if $RC5.is_colliding():
			self.value=2
			if self.has_touch==false:
				$Touched.play()
				self.has_touch=true
		if $RC6.is_colliding():
			self.value=1
			if self.has_touch==false:
				$Touched.play()
				self.has_touch=true

func prepare_to_launch():
	self.player.can_move_dice=true
	self.value=null
	self.has_touch=false
	self.set_physics_process(true)
	
			
func on_clicked():
	self.animation_waiting_grades=0
	self.launch()
	yield(self, "dice_got_value")
	
	var lpm=self.player.last_piece_moved
	
	if self.player.dice_throws_has_three_sixes() and lpm!=null:
		if self.player.route.is_ramp(lpm.route_position)==true:
			self.player.game.players.change_current_player()
			return
		elif lpm.can_move_to_route_position(lpm.route_position+lpm.squares_to_move())==false:
			self.player.game.players.change_current_player()
			return
		elif self.player.route.is_ramp(self.player.last_piece_moved.route_position)==false:
			$ThreeSix.play()		
			self.player.last_piece_moved.move_to_route_position(0,40)
			yield(self.player.last_piece_moved,"piece_moved")
			self.player.game.players.change_current_player()
			return
		
	if self.player.can_some_piece_move():
		self.player.can_move_pieces=true
		if self.player.ia==true:
			self.player.ia_selects_piece_to_move().on_clicked()
	else:
		if self.player.can_move_dice_again():
			self.player.dice.prepare_to_launch()
			if self.player.ia==true:
				self.player.dice.on_clicked()
		else:
			self.player.game.players.change_current_player()

		

	
