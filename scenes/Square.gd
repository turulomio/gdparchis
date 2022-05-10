class_name Square
## This is a passive container movements must be set in Piece


var id : int = 0
var type #eSquareTypes
var color#: Globals.eColors
var max_ 
var pieces =[]# Filled with null values to mantain positions

func _to_string():
	return "[Square: "+ str(self.id) + "]"
func _init(node_id):
	self.id=node_id

	match(self.id):
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
	
	for _i in range(self.max_pieces()):
		self.pieces.append(null)
	print(self.pieces)
func max_pieces():
	if self.type in [Globals.eSquareTypes.START,Globals.eSquareTypes.END]:
		return 4
	return 2

## Devuelve -1 si no encuentra sitio libre o la posicion
func empty_position():
	for position in range(self.max_pieces()):
		if self.pieces[position] == null:
			return position
	return -1
