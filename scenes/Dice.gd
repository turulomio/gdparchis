
class_name Dice
extends RigidBody3D

signal dice_got_value
var vel : Vector3 = Vector3(0,-30,0)
var value=0#To avoid failling values must be 0, null to start getting value, 1-6 has got a value
var has_touch=false
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
	
	self.set_physics_process(true)
	## Fake dice
	if len(Globals.game_data["fake_dice"])>0:
		var fake=int(Globals.game_data["fake_dice"][0])#no lo borra solo dibuja
		self.simulate_value(fake)
		self.set_my_position(10)
		self.set_linear_velocity(Vector3(0,3,0)) ##Needs angular, physics condition
	else:
		randomize()
		self.set_my_position(randi_range(5,15))
		self.simulate_value(int(randf_range(1,6.99)))
		
		
		var x = randi_range(-10,10)
		var y = randi_range(-10,10)
		var z = randi_range(-10,10)
		self.set_linear_velocity(Vector3(randi_range(-3,3), randi_range(-3,3) ,randi_range(-3,3)))
		self.set_angular_velocity(Vector3(x,y,z))


func _physics_process(_delta):
	if self.value==0:
		return

	
	if self.value!=null and Globals.vector_is_almost_zero(self.angular_velocity) and Globals.vector_is_almost_zero(self.linear_velocity):
		var s="Dice " + str(self.player().id) + " gets a "+ str(self.value)
		print(s)
		$RelaunchTimer.stop()
		
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
		self.global_rotate(Vector3.ZERO, 0)
		self.set_linear_velocity(Vector3(0,0,0))
		self.set_angular_velocity(Vector3(0,0,0))
		$FloatingText.show_text(tr("Recovering dice"),self.player().color)
		self.player().can_throw_dice=true
		self.launch()
	

func TweenWaiting_method(rad):
	self.global_transform.origin.y=2.5+sin(rad)/2

func TweenWaiting_start():  
	self.set_physics_process(false)	
	self.tween_waiting = create_tween()
	self.tween_waiting.set_loops()
	self.tween_waiting.tween_method(TweenWaiting_method, 0, 2*PI, 2)
	
func TweenWaiting_stop():
	#$TweenWaiting.stop_all() 
	self.tween_waiting.kill()
	self.set_physics_process(true)


func _on_RequestGameFake_request_completed(result, response_code, headers, body):
	if result==0:
		var r=JSON.parse_string(body.get_string_from_utf8())
		print ("  - ", r["success"],": ", r["detail"])
	else:
		print ("  -  Couldn't connect")


