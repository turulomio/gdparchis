
class_name Dice
extends RigidBody3D

signal dice_got_value
var vel : Vector3 = Vector3(0,-30,0)
var value=0#To avoid failling values must be 0, null to start getting value, 1-6 has got a value
var has_touch=false
var collision_count: int = 0
var historical=[] #List to store all throws to get statistics
var tween_waiting


func player():
	return self.get_parent_node_3d()
	
func set_my_position(h):
	match(self.player().id):
		0:
			self.global_transform.origin=Vector3(-20,h,-25)
		1:
			self.global_transform.origin=Vector3(-25,h,20)
		2:
			self.global_transform.origin=Vector3(20,h,25)
		3:
			self.global_transform.origin=Vector3(25,h,-20)
			
## Rotate dice to set value at the top of the dice
func simulate_value(v:int) -> void:
	self.global_rotate(Vector3(1,1,1).normalized(),0)
	match(v):
		1:
			self.global_rotate(Vector3(1,0,0).normalized(), PI)
		2:
			self.global_rotate(Vector3(0,0,1).normalized(), 3*PI/2)
		3:
			self.global_rotate(Vector3(1,0,0).normalized(), PI/2)
		4:
			self.global_rotate(Vector3(1,0,0).normalized(), 3*PI/2)
		5:
			self.global_rotate(Vector3(0,0,1).normalized(), PI/2)
		6:
			self.global_rotate(Vector3(1,0,0).normalized(), 0)
			
			
func launch():
	$RelaunchTimer.start(5)
	self.player().can_throw_dice=false
	self.value=null
	self.has_touch=false
	self.collision_count=0
	self.freeze = false
	
	self.set_physics_process(true)
	## Fake dice
	if len(Globals.game_data["fake_dice"])>0:
		var fake=int(Globals.game_data["fake_dice"][0])#no lo borra solo dibuja
		self.simulate_value(fake)
		self.set_my_position(5)
		var dir = (Vector3(0, 0, 0) - Vector3(self.global_transform.origin.x, 0, self.global_transform.origin.z)).normalized()
		self.set_linear_velocity(dir * 12.0 + Vector3(0, 2.0, 0))
		self.set_angular_velocity(Vector3(randf_range(-20.0, 20.0), randf_range(-3.0, 3.0), randf_range(-20.0, 20.0)))
	else:
		randomize()
		self.set_my_position(randf_range(4.5, 6.5))
		self.simulate_value(int(randf_range(1,6.99)))
		
		var spawn_pos = self.global_transform.origin
		var dir_to_center = (Vector3(0, 0, 0) - Vector3(spawn_pos.x, 0, spawn_pos.z)).normalized()
		var toss_speed = randf_range(9.0, 14.0)
		var upward_force = randf_range(1.5, 3.0)
		
		self.set_linear_velocity(dir_to_center * toss_speed + Vector3(0, upward_force, 0))
		# Tumbling rotation across X and Z with controlled Y spin
		self.set_angular_velocity(Vector3(randf_range(-25.0, 25.0), randf_range(-4.0, 4.0), randf_range(-25.0, 25.0)))


func _on_body_entered(_body):
	if self.collision_count < 4:
		self.collision_count += 1
		$Touched.pitch_scale = randf_range(0.9, 1.1)
		$Touched.volume_db = 0.0
		$Touched.play()


func _physics_process(_delta):
	if self.value==0:
		return

	# Out of bounds safety recovery
	if self.global_transform.origin.y < -5.0:
		self.global_transform.origin.y = 8.0
		self.set_linear_velocity(Vector3.ZERO)
		self.launch()
		return
	
	var is_tumbling_stopped = abs(self.angular_velocity.x) < 0.2 and abs(self.angular_velocity.z) < 0.2
	var is_linear_stopped = Globals.vector_is_almost_zero(self.linear_velocity, 0.2)
	
	if self.value!=null and is_tumbling_stopped and is_linear_stopped:
		var s="Dice " + str(self.player().id) + " gets a "+ str(self.value)
		print(s)
		$RelaunchTimer.stop()
		
		self.set_linear_velocity(Vector3.ZERO)
		self.set_angular_velocity(Vector3.ZERO)
		self.freeze = true
		self.set_physics_process(false)
		## Fake dice
		if len(Globals.game_data["fake_dice"])>0:
			self.value=int(Globals.game_data["fake_dice"].pop_front())
			print("Fake dice: {0}".format([self.value]))

			## Registering end of game
			print("Registering fake of game:")
			var fields = {
				"game_uuid": Globals.game_data.game_uuid,
				"faked": true,
			}
			Globals.request_put($RequestGameEnd, Globals.APIROOT+"/games/", fields)

			
			
			$FloatingText.show_text(tr("Fake dice: {0}").format([self.value]), self.player().color)
			#await $FloatingText.text_disappear
		self.player().dice_throws.append(self.value)
		self.historical.append(self.value)
		emit_signal("dice_got_value")

	else:
		if $RC1.is_colliding():
			self.value=6
			self.has_touch=true
		if $RC2.is_colliding():
			self.value=5
			self.has_touch=true
		if $RC3.is_colliding():
			self.value=4
			self.has_touch=true
		if $RC4.is_colliding():
			self.value=3
			self.has_touch=true
		if $RC5.is_colliding():
			self.value=2
			self.has_touch=true
		if $RC6.is_colliding():
			self.value=1
			self.has_touch=true

func on_clicked():
	
	self.launch()
	await self.dice_got_value
	
	var lpm=self.player().last_piece_moved
	if self.player().dice_throws_has_three_sixes() and lpm!=null:
		if self.player().route().is_ramp(lpm.route_position)==true:
			self.player().game().change_current_player()	
			$FloatingText.show_text(tr("Tree sixes: You're lucky you are in the final ramp"), self.player().color)
			await $FloatingText.text_disappear
			return
		elif lpm.can_move_stm()==false:
			self.player().game().change_current_player()			
			$FloatingText.show_text(tr("Tree sixes: You're lucky you can't move"), self.player().color)
			await $FloatingText.text_disappear
			return
		elif self.player().route().is_ramp(self.player().last_piece_moved.route_position)==false:
			$ThreeSix.play()
			self.player().last_piece_moved.move_to_route_position(0)
			await self.player().last_piece_moved.piece_moved
			$FloatingText.show_text(tr("Tree sixes: too fast too young"), self.player().color)
			await $FloatingText.text_disappear
			self.player().game().change_current_player()
			return
		
	if self.player().can_some_piece_move_stm():
		self.player().can_move_pieces=true
		if self.player().ia==true:
			var p =self.player().ia_selects_piece_to_move()
			p.on_clicked()
		else: #Self player.ia false
			var pieces_can_move_stm=self.player().pieces_can_move_stm()
			if pieces_can_move_stm.size()==1: #Mandatory movement
				pieces_can_move_stm[0].on_clicked()
	else:
		if self.player().can_throw_dice_again():
			self.player().can_throw_dice=true
			if self.player().ia==true or Globals.settings["automatic"]==true:
				self.player().dice().on_clicked()
		else:
			self.player().game().change_current_player()


func historical_report():
	var s=""
	if len(self.historical)>0:
		s+="Dice %s has been thrown %s times:\n" % [self.player().id, self.historical.size()]
		s+="  - 1: %d (%.2f%%)\n" % [ self.historical.count(1), float(self.historical.count(1))/len(self.historical)*100 ]
		s+="  - 2: %d (%.2f%%)\n" % [ self.historical.count(2), float(self.historical.count(2))/len(self.historical)*100 ]
		s+="  - 3: %d (%.2f%%)\n" % [ self.historical.count(3), float(self.historical.count(3))/len(self.historical)*100 ]
		s+="  - 4: %d (%.2f%%)\n" % [ self.historical.count(4), float(self.historical.count(4))/len(self.historical)*100 ]
		s+="  - 5: %d (%.2f%%)\n" % [ self.historical.count(5), float(self.historical.count(5))/len(self.historical)*100 ]
		s+="  - 6: %d (%.2f%%)\n" % [ self.historical.count(6), float(self.historical.count(6))/len(self.historical)*100 ]
		if len(self.historical)>1:
			var repetitions=0
			for i in range(1,len(self.historical)):
				if self.historical[i]==self.historical[i-1]:
					repetitions+=1
			s+="  - Repetitions: %d" % repetitions
	return s

func _on_RelaunchTimer_timeout():
	if $RelaunchTimer.is_stopped():
		return
	else:
		self.global_rotate(Vector3.UP, 0)
		self.set_linear_velocity(Vector3.ZERO)
		self.set_angular_velocity(Vector3.ZERO)
		$FloatingText.show_text(tr("Recovering dice"),self.player().color)
		self.player().can_throw_dice=true
		self.launch()
	

func TweenWaiting_method(rad):
	self.global_transform.origin.y=2.5+sin(rad)/2

func TweenWaiting_start():  
	self.set_physics_process(false)	
	self.freeze = true
	self.tween_waiting = create_tween()
	self.tween_waiting.set_loops()
	self.tween_waiting.tween_method(TweenWaiting_method, 0, 2*PI, 2)
	
func TweenWaiting_stop():
	#$TweenWaiting.stop_all() 
	self.tween_waiting.kill()
	self.freeze = false
	self.set_physics_process(true)


func _on_RequestGameFake_request_completed(result, response_code, headers, body):
	if result==0:
		var r=JSON.parse_string(body.get_string_from_utf8())
		print ("  - ", r["success"],": ", r["detail"])
	else:
		print ("  -  Couldn't connect")
