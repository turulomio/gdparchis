class_name Square
## This is a passive container movements must be set in Piece


var id : int 
var type #eSquareTypes
var color#: Globals.eColors
var max_ 
var pieces =[]# Filled with null values to mantain positions

func _to_string():
	return "[Square: "+ str(self.id) + "]"
	
func _init(node_id):
	self.id=node_id

	match(self.id):
		5:
			self.type=Globals.eSquareTypes.FIRST
			self.color=Globals.eColors.YELLOW
		22:
			self.type=Globals.eSquareTypes.FIRST
			self.color=Globals.eColors.BLUE
		39:
			self.type=Globals.eSquareTypes.FIRST
			self.color=Globals.eColors.RED
		56:
			self.type=Globals.eSquareTypes.FIRST
			self.color=Globals.eColors.GREEN
			
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
			self.color=Globals.eColors.YELLOW
		84:
			self.type=Globals.eSquareTypes.END
			self.color=Globals.eColors.BLUE
		92:
			self.type=Globals.eSquareTypes.END
			self.color=Globals.eColors.RED
		100:
			self.type=Globals.eSquareTypes.END
			self.color=Globals.eColors.GREEN
		101:
			self.type=Globals.eSquareTypes.START
			self.color=Globals.eColors.YELLOW
		102:
			self.type=Globals.eSquareTypes.START
			self.color=Globals.eColors.BLUE
		103:
			self.type=Globals.eSquareTypes.START
			self.color=Globals.eColors.RED
		104:
			self.type=Globals.eSquareTypes.START
			self.color=Globals.eColors.GREEN
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
		print("Square.has_barrier",self.pieces_count(),self.pieces[0].player,self.pieces[1].player,self)
		return true
	return false

## Devuelve -1 si no encuentra sitio libre o la posicion
func empty_position():
	for position in range(self.max_pieces()):
		if self.pieces[position] == null:
			return position
	return -1
	
func piece_different_to_me(_piece):
	for p in self.pieces:
		if p!=null and p!=_piece:
			return p
	return null
	
	
