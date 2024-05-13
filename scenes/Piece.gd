extends RigidBody3D
class_name Piece

@export var id: int: 
	set(value):
		id=value

signal piece_moved
var vel : Vector3 = Vector3(0,-30,0)
@onready var MeshInstance=$MeshInstance

var color: Color
var route_position: int 
var square_position: int

#animation movement
#var animation_positions=null #Will be an array of positions
var TweenWaiting
	
func initialize( color_):
	self.color=color_
	var new_material = StandardMaterial3D.new()
	new_material.albedo_texture = Globals.IMAGE_WOOD
	new_material.albedo_color = self.color
	MeshInstance.material_override=new_material

func set_final_position(_route_position, _square_position,square_id):
	self.route_position=_route_position
	self.square_position=_square_position
	self.global_transform.origin=Globals.position4(square_id,self.square_position)

func player():
	return self.get_parent_node_3d()
	
func board():
	return self.player().get_parent_node_3d()

func game():
	return self.board().get_parent_node_3d()
	
func route():
	return self.player().route()
	
func total_id():
	# Returns the total id 0-16 in board4
	return self.player().id*4+self.id
	
#func _physics_process(_delta): 
	##return move_and_slide(vel,Vector3.UP)
	#return move_and_slide()

func _to_string():
	return "[Piece: "+ str(self.id) + "]"
	
func square():
	return self.route().square_at(self.route_position)
	
			
func can_move_to_route_position(_route_position):
	var square_initial=self.square()
	var square_final=self.route().square_at(_route_position)
	
	##DEbe sacar si es un 5
	if self.route().square_at(1).has_barrier_of_this_player(self.player())==false and  self.must_move_to_first_square()==false and self.player().can_some_piece_move_to_first_square()==true:
		#print("Piece.can_move_to_route_position can_move_to_first becouse other can")
		return false
	
	#Solo sale con un 5
	if square_initial.type==Globals.eSquareTypes.START and self.player().last_throw()!=5:
		#print("Piece.can_move_to_route_position Solo sale con un 5")
		return false

	
	
	# Check if went more far that end
	if square_final==null:		
		#print("Piece.can_move_to_route_position square_final null ")
		return false
		
	# Check if there is a barrier and must open with a six
	if self.player().last_throw()==6 and self.player().some_piece_is_in_barrier_of_my_player()==true and self.am_i_in_a_barrier_of_my_player()==false:
		#print("Piece.can_move_to_route_position debe abrir barrera por 6 ")
		return false
		
	#Check if there is barrier
	if self.route().is_there_barrier(self.route_position, _route_position):
		#print("Piece.can_move_to_route_position Hay bbarrera en ruta ")
		return false
		
	#Comprueba si hay  posición libre en casilla
	var new_square_position=square_final.empty_position()
	if self.must_move_to_first_square()==false and new_square_position ==-1:
		#print("Piece.can_move_to_route_position No tiene posición libre en la casilla")
		return false
		
	#print("Piece.can_move_to_route_position Piece can move")
	return true
		
## Before this method always have to check if piece can move
func move_to_route_position(_route_position, duration=0.5, max_height=15):
	#duration=5
	#max_height=20
	var square_final=self.route().square_at(_route_position)
	var square_initial=self.square()
	var square_position_initial=self.square_position

	
	square_initial.set_piece_at_square_position(square_position_initial,null)
	var square_position_final=square_final.empty_position()
	square_final.set_piece_at_square_position(square_position_final,self)
	self.square_position=square_position_final
	self.route_position=_route_position	
	
	# if square_final==square_initial and square_position_final==square_position_initial:#Casos al inicio de los juegos
	# 	print("No se mueve por ser el mismo destino", self.player(), self, square_initial,square_position_initial)
	# 	self.player().can_move_pieces=false	
	# 	emit_signal("piece_moved")
	# 	self.change_scale_on_specials_squares()
	# 	return

	print("Moviendo ", self.player(), " ", self, " ", square_initial, " ", square_position_initial, " ", square_final, " ",square_position_final)
	
	#TWeen moving
	self.player().can_move_pieces=false
	if duration>0:
		#var animation_from:Vector3=self.global_transform.origin
		var animation_from=Globals.position4(square_initial.id, square_position_initial)
		var animation_to=Globals.position4(square_final.id, square_position_final)
		var animation_diff=animation_to-animation_from
		var animation_middle=animation_from+animation_diff/2.0
		animation_middle.y=max_height
			
		#print("STarting tweenmoving", self.player(),self)
		var TweenMoving= get_tree().create_tween()
		TweenMoving.tween_property(self,"global_transform:origin",animation_middle,duration/2.0)
		TweenMoving.tween_property(self,"global_transform:origin",animation_to,duration/2.0)
		await TweenMoving.finished
	self.change_scale_on_specials_squares()
	emit_signal("piece_moved")
	#print("Stoping tweenmoving", self.player(),self)

#Para casillas estrechas
func change_scale_on_specials_squares():
	if self.board().max_players==4:
		if self.square().id in [8,9,25,26,42,43,59,60]:
			self.scale=Vector3(0.75	, 0.75, 0.75)
		else:
			self.scale=Vector3(1,1,1)

func squares_to_move():
	if self.player().extra_moves.size()>0:
		return self.player().extra_moves[0]
	
	if self.square().type==Globals.eSquareTypes.START and self.player().last_throw()==5:
		return 1
	elif self.player().are_all_pieces_out_of_home() and self.player().last_throw()==6:
		return 7
	else:
		return self.player().last_throw()
	
	
func am_i_in_a_barrier_of_my_player():
	var s=self.square()
	if s.has_barrier()==true:
		if s.pieces[0].player()==self.player() and s.pieces[1].player()==self.player():
			return true
	return false
	
## Returns true if before move has eaten
## Para comer a veces se necesita comer antes del movimiento
## Por ejemplo sacar un 5 con una casilla en START y habiendo dos ficheas distintas al usuario que sale
## Devuelve null o la ficha a comer
func piece_to_eat_before_move():
	var square_initial=self.square()
	var square_final=self.route().square_at(self.route_position+self.squares_to_move())#After move

	if square_final.pieces_count()==2 and self.player().dice.value==5 and square_initial.type==Globals.eSquareTypes.START:
		var ordered= square_final.pieces_different_to_me_ordered(self.player())
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
			$FloatingText.show_text(tr("{0}, I did it unintentionally").format([eaten_before.player.name]), self.player().color)
			eaten_before.move_to_route_position(0)
			await eaten_before.piece_moved
		
		self.move_to_route_position(self.route_position+self.squares_to_move())
		await self.piece_moved
		
		#Must be before has_eaten, pero no before
		if self.squares_to_move() in [10,20]:#Ya se ha movido luego lo quita
			self.player().extra_moves.pop_front()
			
		if has_eaten_before==false and self.can_eat_at_route_position(self.route_position,true)==true:#Si come antes no come después. y lo hace ya en el nuevo route_position despues del movimiento
			has_eaten_after=true
			$Eat.play()			
			var piece_eaten=self.square().pieces_different_to_me_ordered(self.player())[0]
			$FloatingText.show_text(tr("{0}, you're so tasty").format([piece_eaten.player().name]), self.player().color)
			piece_eaten.move_to_route_position(0)
			await piece_eaten.piece_moved

		#Muest be after move
		if has_eaten_before==true or has_eaten_after==true:
			self.player().extra_moves.append(20)
			
			
			
		
		## After move
		if self.player().has_won():
			$Won.play()
			
			$FloatingText.show_text(tr("Player {0} wins").format([self.player().name]), self.player().color)
			await $FloatingText.text_disappear
	
				
			## Registering end of game
			print("Registering end of game:")	
			var fields = {
				"game_uuid": Globals.game_data.game_uuid,
				"human_won": not self.player().ia,
			}
			print(fields)
			Globals.request_put($RequestGameEnd, Globals.APIROOT+"/games/", fields)
			await $RequestGameEnd.request_completed
			
			
			get_tree().change_scene_to_file("res://scenes/Main.tscn")
			return
			
			
		if self.square().type==Globals.eSquareTypes.END:
			$EndRoute.play()
			self.player().extra_moves.append(10)
			
		self.player().last_piece_moved=self
	else: # Ha pulsado una ficha que no se puede mover
		$Click.play()
		return
	
	## Estos if son excluyentes
	if self.player().can_move_other_piece_stm()==true:
		self.player().can_move_pieces=true
		if self.player().ia==true:
			self.player().ia_selects_piece_to_move().on_clicked()
		else: #player.ia false
			var pieces_can_move_stm=self.player().pieces_can_move_stm()
			print(self.player().name, " PIECES CAN MOVE ", pieces_can_move_stm)
			if pieces_can_move_stm.size()==1: #Mandatory movement
				pieces_can_move_stm[0].on_clicked()
		
	elif self.player().can_throw_dice_again():
		self.player().can_throw_dice=true
		if self.player().ia==true:
			self.player().dice().on_clicked()
		else:#Not ia
			if Globals.settings.get("automatic",true)==true:
				self.player().dice().on_clicked()
	else:
		self.game().change_current_player()
		
#Casilla First.Siempre que se mueve a FIRST es una obligación si se puede
func must_move_to_first_square():
	if self.route_position!=0:
		return false
	var square_first=self.route().square_at(1)
	#Si tiene extra moves no está sacando un 5 si no moviendo
	if self.player().extra_moves.size()==0 and  self.player().dice().value==5 and self.player().are_all_pieces_out_of_home()==false:
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
	if self.visible==false:
		return
		
	self.set_physics_process(false)	
	TweenWaiting= create_tween()
	TweenWaiting.set_loops()
	TweenWaiting.tween_method(TweenWaiting_method, 0, 2*PI, 2)
	TweenWaiting.tween_callback(TweenWaiting_stop)
	
func TweenWaiting_stop():
	self.set_physics_process(true)
	if self.visible==false :
		return
	if TweenWaiting:
		TweenWaiting.kill()
		TweenWaiting=null
	


## getter of can_move
func can_move_stm():
	return self.can_move_to_route_position(self.route_position+self.squares_to_move())

# Returns a boolean if can_eat_at_that_position
# @param check_after_movement, por defecto true, primero mueve y luego comprueba
func can_eat_at_route_position(_route_position, check_after_movement):
	var square_=self.route().square_at(_route_position)
	if check_after_movement==false and self.can_move_to_route_position(_route_position): #chequeo antes de mover y comprueba que3 mueve
		if square_.pieces_count()==1 and square_.type==Globals.eSquareTypes.NORMAL and square_.pieces_objects()[0].player!=self.player():
			return true
	else: #chequeo despues de mover
		if square_.pieces_count()==2 and square_.type==Globals.eSquareTypes.NORMAL and square_.pieces_different_to_me_ordered(self.player())!=null:
			return true
	return false

func can_eat_before_stm():
	if piece_to_eat_before_move()==null:
		return false
	else:
		return true

## Returns if a piece can arrive to final square with 1,2,3,4,5 or 6,7
func can_go_final_square_with_dice_movement():
	if self.route_position+1==self.route().end_position():
		return true
	if self.route_position+2==self.route().end_position():
		return true
	if self.route_position+3==self.route().end_position():
		return true
	if self.route_position+4==self.route().end_position():
		return true
	if self.player().are_all_pieces_out_of_home():
		if self.route_position+5==self.route().end_position():
			return true
		if self.route_position+7==self.route().end_position():
			return true
	else:
		if self.route_position+6==self.route().end_position():
			return true
		
	return false


## Checks if a stalker piece threats me at a square
func is_threating_me(stalker, _square):
	var stalker_square=stalker.square()
	
	if stalker_square==_square:
		return false
	
	if stalker.route().position_in_route(_square)==-1:
		return false
		
	var distance=self.route().distance_between_squares(stalker_square,_square)
		
	if distance==null:
		return false
	
	if _square.type in [Globals.eSquareTypes.START,Globals.eSquareTypes.RAMP,Globals.eSquareTypes.SECURE,Globals.eSquareTypes.END]:
		return false

	if _square.has_barrier_of_this_player(self.player()):
		return false
		
	var stalker_pieces_all_out=stalker.player().are_all_pieces_out_of_home()


	var mysix
	if stalker_pieces_all_out:
		mysix=7
	else:
		mysix=6

	if _square.type in [Globals.eSquareTypes.NORMAL] and distance in [1,2,3,4,20,mysix]:
		return true

	if stalker_pieces_all_out==true and _square.type in [Globals.eSquareTypes.NORMAL] and distance==5:
		return true

	if stalker.player().can_some_piece_go_final_square_with_dice_movement():
		if _square.type in [Globals.eSquareTypes.NORMAL] and distance==10:
			return true


	if _square.type==Globals.eSquareTypes.FIRST and stalker.player().color==_square.color and _square.pieces_count()==2 and _square.has_barrier_of_this_player(self.player())==false:
		return true

	return false
	

func threats_at(square):
	var r=[]
	for player_ in self.player().board().players():
		if player_==self.player(): #Ignores piece player
			continue
		for stalker in player_.pieces():
			if self.is_threating_me(stalker, square):
				r.append(stalker)
	return r


func _on_RequestGameEnd_request_completed(result, response_code, headers, body):
	if result==0:
		var r=JSON.parse_string(body.get_string_from_utf8())
		print ("  - ", r["success"],": ", r["detail"])
	else:
		print ("  -  Couldn't connect")

