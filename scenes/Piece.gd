extends KinematicBody
class_name Piece


signal piece_moved
var floating_text=preload("res://scenes/FloatingText.tscn")
var vel : Vector3 = Vector3(0,-30,0)

var animation_to=null
var animation_step=0
var id : int =1000
var player: Player
var route: Route
var route_position: int 
var square_position: int

var animation_num_steps=10
var animation_max_y=10


var animation_waiting_grades=0
var minor_fps=1000

func _physics_process(_delta): 
	var fps=1/_delta
	if minor_fps>fps:
		minor_fps=fps
	
	if animation_to!=null:
		var current=self.global_transform.origin
		var new_pos
		if self.animation_num_steps==0:
			new_pos=self.animation_to
		else:
			#Sets step
			new_pos=(self.animation_to-current)*self.animation_step/self.animation_num_steps +current
			#Sets y with sin function
			new_pos.y=self.animation_to.y+self.animation_max_y*sin(deg2rad(180*self.animation_step/self.animation_num_steps))
		self.animation_step=self.animation_step+1
		self.global_transform.origin=new_pos
		if self.animation_step==self.animation_num_steps:
			self.global_transform.origin=self.animation_to
			self.animation_step=0
			self.player.can_move_pieces=false
			emit_signal("piece_moved")
			self.animation_to=null
			print("Minor fps ", minor_fps)
	elif self.player.game.filename!="res://scenes/Game4Objects" and self.player.game.players.current== self.player and self.player.can_move_pieces== true:
		self.animation_waiting_grades=self.animation_waiting_grades+5
		self.global_transform.origin.y=1.2+sin(deg2rad(self.animation_waiting_grades))/2
	elif self.animation_waiting_grades==0:
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
func move_to_route_position(_route_position, _animation_num_steps=0):
	self.animation_waiting_grades=0
	self.animation_num_steps=_animation_num_steps
	var square_final=self.route.square_at(_route_position)
	var square_initial=self.square()
	
	square_initial.set_piece_at_square_position(self.square_position,null)
	
	var new_square_position=square_final.empty_position()
	square_final.set_piece_at_square_position(new_square_position,self)
	self.square_position=new_square_position
	
	self.route_position=_route_position
	
	self.animation_to=Globals.position4(square_final.id,new_square_position)
	self.animation_step=0
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
	
## Returns true if after move has eaten
func has_eaten_after_move():
	## In square after move
	var s=self.square()
	if s.pieces_count()==2 and s.type==Globals.eSquareTypes.NORMAL and s.pieces[0].player!=s.pieces[1].player:
		return true
	return false

	
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
func has_eaten_before_move():
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
	if self.can_move_to_route_position(self.route_position+self.squares_to_move()):
		

		var eaten_before=self.has_eaten_before_move() #Salida con 5 con dos fichas distintas, dbe haber hueco por eso come antes
		print("Eaten_before",eaten_before)
		if eaten_before!=null:
			has_eaten_before=true
			$Eat.play()
			eaten_before.move_to_route_position(0, 20)
			yield(eaten_before,"piece_moved")
		
		
		self.move_to_route_position(self.route_position+self.squares_to_move(), 20)
		yield(self,"piece_moved")
		
		
		#Must be before has_eaten, pero no before
		if self.squares_to_move() in [10,20]:#Ya se ha movido luego lo quita
			self.player.extra_moves.pop_front()
			
		if has_eaten_before==false and self.has_eaten_after_move():#Si come antes no come después
			has_eaten_after=true
			$Eat.play()
			var piece_eaten=self.square().pieces_different_to_me_ordered(self.player)[0]
			piece_eaten.move_to_route_position(0, 20)
			yield(piece_eaten,"piece_moved")
			
		#Muest be after move
		if has_eaten_before==true or has_eaten_after==true:
			self.player.extra_moves.append(20)
			
			
			
		
		## After move
		if self.player.has_won():
			$Won.play()
			var text=floating_text.instance()
			text.text="Player %s starts" % self.player.name
			self.add_child(text)
			yield($Won,"finished")
			yield(text,"text_disappear")
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
	if self.player.can_move_other_piece()==true:
		self.player.can_move_pieces=true
		if self.player.ia==true:
			self.player.ia_selects_piece_to_move().on_clicked()
		
	elif self.player.can_move_dice_again():
		self.player.dice.prepare_to_launch()
		if self.player.ia==true:
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
