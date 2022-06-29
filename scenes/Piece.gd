extends KinematicBody
class_name Piece


signal piece_moved
var vel : Vector3 = Vector3(0,-30,0)

var id : int =1000
var player
var route: Route
var route_position: int 
var square_position: int

#animation movement
var animation_positions=null #Will be an array of positions

func _physics_process(_delta): 
	return move_and_slide(vel,Vector3.UP)

func _to_string():
	return "[Piece: "+ str(self.id) + "]"
	
## Sets id, and initial properties and position
func set_id(_id,_player,_route_position, _square_position):
	self.route_position=_route_position
	self.id=_id
	self.player=_player
	self.route_position=_route_position
	self.square_position=_square_position
	self.set_color(Globals.colorn(self.player.id))
	self.route=self.player.route

	
func square():
	return self.route.square_at(self.route_position)
	
# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
func set_color(s):	
	var new_material = SpatialMaterial.new()
	new_material.albedo_texture = Globals.IMAGE_WOOD
	new_material.albedo_color = s
	$MeshInstance.material_override=new_material
			
func can_move_to_route_position(_route_position):
	var square_initial=self.square()
	var square_final=self.route.square_at(_route_position)
	
	##DEbe sacar si es un 5
	if self.route.square_at(1).has_barrier_of_this_player(self.player)==false and  self.must_move_to_first_square()==false and self.player.can_some_piece_move_to_first_square()==true:
		print("Piece.can_move_to_route_position can_move_to_first becouse other can")
		return false
	
	#Solo sale con un 5
	if square_initial.type==Globals.eSquareTypes.START and self.player.last_throw()!=5:
		print("Piece.can_move_to_route_position Solo sale con un 5")
		return false

	
	
	# Check if went more far that end
	if square_final==null:		
		print("Piece.can_move_to_route_position square_final null ")
		return false
		
	# Check if there is a barrier and must open with a six
	if self.player.last_throw()==6 and self.player.some_piece_is_in_barrier_of_my_player()==true and self.am_i_in_a_barrier_of_my_player()==false:
		print("Piece.can_move_to_route_position debe abrir barrera por 6 ")
		return false
		
	#Check if there is barrier
	if self.route.is_there_barrier(self.route_position, _route_position):
		print("Piece.can_move_to_route_position Hay bbarrera en ruta ")
		return false
		
	#Comprueba si hay  posición libre en casilla
	var new_square_position=square_final.empty_position()
	if self.must_move_to_first_square()==false and new_square_position ==-1:
		
		print("Piece.can_move_to_route_position No tiene posición libre en la casilla")
		return false
		
	print("Piece.can_move_to_route_position Piece can move")
	return true
		
## Before this method always have to check if piece can move
func move_to_route_position(_route_position, duration=0.4):
	var square_final=self.route.square_at(_route_position)
	var square_initial=self.square()
	
	square_initial.set_piece_at_square_position(self.square_position,null)
	
	var new_square_position=square_final.empty_position()
	square_final.set_piece_at_square_position(new_square_position,self)
	self.square_position=new_square_position
	
	self.route_position=_route_position
	
	
	self.TweenMoving_start(Globals.position4(square_final.id,new_square_position),duration)
	yield(self,"piece_moved")
	self.change_scale_on_specials_squares()
	
#Para casillas estrechas
func change_scale_on_specials_squares():
	if self.player.game.max_players==4:
		if self.square().id in [8,9,25,26,42,43,59,60]:
			self.scale=Vector3(0.8,1,0.8)
		else:
			self.scale=Vector3(1,1,1)

func squares_to_move():
	if self.player.extra_moves.size()>0:
		return self.player.extra_moves[0]
	
	if self.square().type==Globals.eSquareTypes.START and self.player.last_throw()==5:
		return 1
	elif self.player.are_all_pieces_out_of_home() and self.player.last_throw()==6:
		return 7
	else:
		return self.player.last_throw()
	
	
func am_i_in_a_barrier_of_my_player():
	var s=self.square()
	if s.has_barrier()==true:
		if s.pieces[0].player==self.player and s.pieces[1].player==self.player:
			return true
	return false
	
## Returns true if before move has eaten
## Para comer a veces se necesita comer antes del movimiento
## Por ejemplo sacar un 5 con una casilla en START y habiendo dos ficheas distintas al usuario que sale
## Devuelve null o la ficha a comer
func piece_to_eat_before_move():
	var square_initial=self.square()
	var square_final=self.route.square_at(self.route_position+self.squares_to_move())#After move

	if square_final.pieces_count()==2 and self.player.dice.value==5 and square_initial.type==Globals.eSquareTypes.START:
		var ordered= square_final.pieces_different_to_me_ordered(self.player)
		if ordered!=null:
			return ordered[0]
	return null

func on_clicked():
	var has_eaten_before=false	
	var has_eaten_after=false
	#print(self.can_move_stm,self.can_eat_before_stm,self.can_eat_after_stm)
	if self.can_move_stm()==true:
		if self.can_eat_before_stm()==true:
			var eaten_before=self.piece_to_eat_before_move() #Salida con 5 con dos fichas distintas, dbe haber hueco por eso come antes
			has_eaten_before=true
			$Eat.play()
			eaten_before.move_to_route_position(0)
			yield(eaten_before,"piece_moved")
		
		print(self.route_position)
		self.move_to_route_position(self.route_position+self.squares_to_move())
		yield(self,"piece_moved")		
		
		#Must be before has_eaten, pero no before
		if self.squares_to_move() in [10,20]:#Ya se ha movido luego lo quita
			self.player.extra_moves.pop_front()
			
			
		print(self.route_position)
		if has_eaten_before==false and self.can_eat_at_route_position(self.route_position,true)==true:#Si come antes no come después. y lo hace ya en el nuevo route_position despues del movimiento
			has_eaten_after=true
			$Eat.play()
			var piece_eaten=self.square().pieces_different_to_me_ordered(self.player)[0]
			piece_eaten.move_to_route_position(0)
			yield(piece_eaten,"piece_moved")
			
		#Muest be after move
		if has_eaten_before==true or has_eaten_after==true:
			self.player.extra_moves.append(20)
			
			
			
		
		## After move
		if self.player.has_won():
			$Won.play()
			
			$FloatingText.show_text("Player {0} wins".format([self.player.name]), self.player.color)
			yield($FloatingText,"text_disappear")
			get_tree().change_scene("res://scenes/Main.tscn")
			return
			
			
		if self.square().type==Globals.eSquareTypes.END:
			$EndRoute.play()
			self.player.extra_moves.append(10)
			
		self.player.last_piece_moved=self
	else: # Ha pulsado una ficha que no se puede mover
		$Click.play()
		return
	
	## Estos if son excluyentes
	if self.player.can_move_other_piece_stm()==true:
		self.player.can_move_pieces=true
		if self.player.ia==true:
			self.player.ia_selects_piece_to_move().on_clicked()
		else: #player.ia falseç
			var pieces_can_move_stm=self.player.pieces_can_move_stm()
			if pieces_can_move_stm.size()==1: #Mandatory movement
				pieces_can_move_stm[0].on_clicked()
		
	elif self.player.can_throw_dice_again():
		self.player.can_throw_dice=true
		if self.player.ia==true:
			self.player.dice.on_clicked()
		else:#Not ia
			if Globals.settings.get("automatic",true)==true:
				self.player.dice.on_clicked()
	else:
		self.player.game.players.change_current_player()
		
#Casilla First.Siempre que se mueve a FIRST es una obligación si se puede
func must_move_to_first_square():
	if self.route_position!=0:
		return false
	var square_first=self.route.square_at(1)
	#Si tiene extra moves no está sacando un 5 si no moviendo
	if self.player.extra_moves.size()==0 and  self.player.dice.value==5 and self.player.are_all_pieces_out_of_home()==false:
		if square_first.pieces_count()<2:
			return true
		else:#2 de size
			var ordered= square_first.pieces_different_to_me_ordered(self)
			if ordered==null: #Barrera mia
				return false
			else: #Otros jugadores
				return true
	return false

	
func TweenWaiting_method(rad):
	self.global_transform.origin.y=1.75+sin(rad)/2

func TweenWaiting_start():
	$TweenWaiting.interpolate_method(self,"TweenWaiting_method", 0, 2*PI, 1)
	$TweenWaiting.start()
	
func TweenWaiting_stop():
	$TweenWaiting.stop_all()
	
		
func TweenMoving_method(step):
	self.global_transform.origin=self.animation_positions[step]


func TweenMoving_start(animation_to: Vector3, duration):
	self.player.can_move_pieces=false
	var steps=20
	var animation_max_y=5
	self.animation_positions=[]
	#Piece movement animation
	for i in range(steps):
		var new_pos=(animation_to-self.global_transform.origin)*(i+1)/steps + self.global_transform.origin
		new_pos.y=animation_to.y+animation_max_y*sin(deg2rad(180*(i+1)/steps))
		self.animation_positions.append(new_pos)
	$TweenMoving.interpolate_method(self,"TweenMoving_method", 0, 19, duration)
	$TweenMoving.start()
	
func _on_TweenMoving_tween_all_completed():
	self.animation_positions=null
	emit_signal("piece_moved")
## getter of can_move
func can_move_stm():
	 return self.can_move_to_route_position(self.route_position+self.squares_to_move())

# Returns a boolean if can_eat_at_that_position
# @param check_after_movement, por defecto true, primero mueve y luego comprueba
func can_eat_at_route_position(_route_position, check_after_movement):
	var square=self.route.square_at(_route_position)
	if check_after_movement==false and self.can_move_to_route_position(_route_position): #chequeo antes de mover y comprueba que3 mueve
		if square.pieces_count()==1 and square.type==Globals.eSquareTypes.NORMAL and square.pieces_objects()[0].player!=self.player:
			return true
	else: #chequeo despues de mover
		if square.pieces_count()==2 and square.type==Globals.eSquareTypes.NORMAL and square.pieces_different_to_me_ordered(self.player)!=null:
			return true
	return false

func can_eat_before_stm():
	if piece_to_eat_before_move()==null:
		return false
	else:
		return true

func threats_before():
	var r=[]
	if self.square().type in [Globals.eSquareTypes.START,Globals.eSquareTypes.RAMP,Globals.eSquareTypes.SECURE,Globals.eSquareTypes.END]:
		return r
	if self.am_i_in_a_barrier_of_my_player():
		return r
	return r
	
func threats_after():
	var r=[]
	return r

