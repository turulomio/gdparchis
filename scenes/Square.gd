class_name Square

var id: int 
var type # eSquareTypes enum
var color # Color object
var max_ 
var pieces = [] # Fixed size array initialized with null values
var last_piece_to_arrive


## String representation helper.
## @return String identifier.
func _to_string():
	return "[Square: " + str(self.id) + "]"


## Constructor assigning square types, colors, and piece array capacity.
## @param node_id Unique square ID integer.
func _init(node_id):
	self.id = node_id

	match(self.id):
		5:
			self.type = Globals.eSquareTypes.FIRST
			self.color = Color.YELLOW
		22:
			self.type = Globals.eSquareTypes.FIRST
			self.color = Color.BLUE
		39:
			self.type = Globals.eSquareTypes.FIRST
			self.color = Globals.ePlayer2Color(2)
		56:
			self.type = Globals.eSquareTypes.FIRST
			self.color = Globals.ePlayer2Color(3)
			
		12, 17, 29, 34, 46, 51, 63, 68:
			self.type = Globals.eSquareTypes.SECURE
		
		59, 76:
			self.type = Globals.eSquareTypes.END
			self.color = Color.YELLOW
		67, 84:
			self.type = Globals.eSquareTypes.END
			self.color = Color.BLUE
		75, 92:
			self.type = Globals.eSquareTypes.END
			self.color = Globals.ePlayer2Color(2)
		100:
			self.type = Globals.eSquareTypes.END
			self.color = Globals.ePlayer2Color(3)
		101:
			self.type = Globals.eSquareTypes.START
			self.color = Color.YELLOW
		102:
			self.type = Globals.eSquareTypes.START
			self.color = Color.BLUE
		103:
			self.type = Globals.eSquareTypes.START
			self.color = Globals.ePlayer2Color(2)
		104:
			self.type = Globals.eSquareTypes.START
			self.color = Globals.ePlayer2Color(3)
		_:
			self.type = Globals.eSquareTypes.NORMAL
			
	# Initialize pieces array with null slots up to max capacity
	for _i in range(self.max_pieces()):
		self.pieces.append(null)


## Returns maximum allowed piece capacity for this square type.
## @return Integer capacity (4 for home/end, 2 for normal/secure).
func max_pieces():
	if self.type in [Globals.eSquareTypes.START, Globals.eSquareTypes.END]:
		return 4
	return 2


## Returns the active non-null piece count standing on this square.
## @return Integer count of active pieces.
func pieces_count():
	var r = 0
	for p in self.pieces:
		if p != null:
			r = r + 1
	return r


## Checks if a barrier (2 pieces of same player) is currently formed on this square.
## @return True if a barrier is present.
func has_barrier():
	if self.type in [Globals.eSquareTypes.START, Globals.eSquareTypes.END]:
		return false
	if self.pieces_count() == 2 and self.pieces[0].player() == self.pieces[1].player():
		return true
	return false


## Checks if a barrier belonging to a specific player is present on this square.
## @param _player Target player object.
## @return True if player owns barrier on this square.
func has_barrier_of_this_player(_player):
	if self.has_barrier() and self.pieces[0].player() == _player and self.pieces[1].player() == _player:
		return true
	return false


## Returns index of first available empty slot, or -1 if square is full.
## @return Slot index or -1.
func empty_position():
	for position in range(self.max_pieces()):
		if self.pieces[position] == null:
			return position
	return -1


## Returns opponent pieces standing on this square ordered with most recent arrival first.
## @param _player Owner player to filter out.
## @return Array of opponent pieces or null.
func pieces_different_to_me_ordered(_player):
	var pieces_different = []
	for p in self.pieces:
		if p != null and p.player() != _player:
			pieces_different.append(p)
		
	if pieces_different.size() == 0:
		return null
	if pieces_different.size() == 2:
		if pieces_different[0] == self.last_piece_to_arrive:
			return pieces_different
		else:
			return [pieces_different[1], pieces_different[0]]
	return pieces_different


## Sets a piece in a specific square slot and tracks arrival order.
## @param square_position Slot index (0-3).
## @param piece Piece object or null.
func set_piece_at_square_position(square_position, piece):
	self.pieces[square_position] = piece
	self.last_piece_to_arrive = piece


## Returns list of active non-null Piece objects standing on this square.
## @return Array of active Piece objects.
func pieces_objects():
	var r = []
	for p in pieces:
		if p != null:
			r.append(p)
	return r
