class_name Square
## This is a passive container movements must be set in Piece


var id : int 
var type #eSquareTypes
var color#: Color
var max_ 
var pieces =[]# Filled with null values to mantain positions
var last_piece_to_arrive

func _to_string():
	return "[Square: "+ str(self.id) + "]"
	
func _init(node_id):
	self.id=node_id

	match(self.id):
		5:
			self.type=Globals.eSquareTypes.FIRST
			self.color=Color.YELLOW
		22:
			self.type=Globals.eSquareTypes.FIRST
			self.color=Color.BLUE
		39:
			self.type=Globals.eSquareTypes.FIRST
			self.color=Color.RED
		56:
			self.type=Globals.eSquareTypes.FIRST
			self.color=Color.GREEN
			
		12:
			self.type=Globals.eSquareTypes.SECURE
		17:
			self.type=Globals.eSquareTypes.SECURE
		29:
			self.type=Globals.eSquareTypes.SECURE
		34:
			self.type=Globals.eSquareTypes.SECURE
		46:
			self.type=Globals.eSquareTypes.SECURE
		51:
			self.type=Globals.eSquareTypes.SECURE
		63:
			self.type=Globals.eSquareTypes.SECURE
		68:
			self.type=Globals.eSquareTypes.SECURE
		
		76:
			self.type=Globals.eSquareTypes.END
			self.color=Color.YELLOW
		84:
			self.type=Globals.eSquareTypes.END
			self.color=Color.BLUE
		92:
			self.type=Globals.eSquareTypes.END
			self.color=Color.RED
		100:
			self.type=Globals.eSquareTypes.END
			self.color=Color.GREEN
		101:
			self.type=Globals.eSquareTypes.START
			self.color=Color.YELLOW
		102:
			self.type=Globals.eSquareTypes.START
			self.color=Color.BLUE
		103:
			self.type=Globals.eSquareTypes.START
			self.color=Color.RED
		104:
			self.type=Globals.eSquareTypes.START
			self.color=Color.GREEN
		_:
			self.type=Globals.eSquareTypes.NORMAL
			
	
	for _i in range(self.max_pieces()):
		self.pieces.append(null)

func max_pieces():
	if self.type in [Globals.eSquareTypes.START,Globals.eSquareTypes.END]:
		return 4
	return 2

## size is always 2 or 4, we must count pieces.
func pieces_count():
	var r=0
	for p in self.pieces:
		if p!=null:
			r=r+1
	return r
	
func has_barrier():
	if self.type in [Globals.eSquareTypes.START,Globals.eSquareTypes.END]:
		return false
	if self.pieces_count()==2 and self.pieces[0].player==self.pieces[1].player:
		return true
	return false
	
func has_barrier_of_this_player(_player):
	if self.has_barrier() and self.pieces[0].player==_player and self.pieces[1].player==_player:
		return true
	return false

## Devuelve -1 si no encuentra sitio libre o la posicion
func empty_position():
	for position in range(self.max_pieces()):
		if self.pieces[position] == null:
			return position
	return -1
	
	
## Muestra las casillas diferentes a mi player.
## Pone primero [0] la ultime en llegar
func pieces_different_to_me_ordered(_player):
	var pieces_different=[]
	for p in self.pieces:
		if p!=null and p.player()!=_player:
			pieces_different.append(p)
		
	if pieces_different.size()==0:
		return null
	if pieces_different.size()==2:
		if pieces_different[0]==self.last_piece_to_arrive:#Esta ordenado
			return pieces_different
		else:
			return [pieces_different[1],pieces_different[0]]
	return pieces_different#Size 1
	
## Para meter piezas se debe usar esto para que se controle la
## ultima ficha que entra
## Esta función no ccomprueba nada ha debido usar empty_position antes
## Tambien debe ser usada para poner null
func set_piece_at_square_position(square_position,piece):
	self.pieces[square_position]=piece
	self.last_piece_to_arrive=piece
	
## Due to pieces has null values, returns all not null values
func pieces_objects():
	var r=[]
	for p in pieces:
		if p!=null:
			r.append(p)
	return r
