extends RefCounted

var board_node: Board4
var squares: Dictionary = {}
var players: Array = []


## Initializes test simulator with a headless Board4 instance and 104 squares.
func _init():
	self.board_node = Board4.new()
	self.board_node.max_players = 4
	self.board_node.show_pieces = false
	
	# Create 104 board squares
	for i in range(1, 105):
		self.squares[i] = Square.new(i)
		
	# Create 4 players (0: Yellow, 1: Blue, 2: Red, 3: Green)
	for i in range(4):
		var p = Player.new()
		p.id = i
		p.plays = true
		p.ia = false
		p.color = Globals.ePlayer2Color(i)
		p.playername = Globals.ePlayerDefaultName(i)
		p.set_route(Route.new(4, i, self.squares))
		
		var d = Dice.new()
		p.add_child(d)
		p._Dice = d
		
		self.players.append(p)
		self.board_node.add_child(p)
		
		# Create 4 pieces per player
		var piece_scene = preload("res://scenes/Piece.tscn")
		for piece_idx in range(4):
			var piece = piece_scene.instantiate()
			piece.id = piece_idx
			p.add_child(piece)
			piece.initialize(p.color)


## Returns the Board4 instance.
## @return Board4 instance.
func get_board() -> Board4:
	return self.board_node


## Returns player by numeric ID (0-3).
## @param player_id Player numeric ID.
## @return Player object.
func get_player(player_id: int) -> Player:
	return self.players[player_id]


## Returns a specific piece belonging to a player.
## @param player_id Player numeric ID.
## @param piece_idx Piece index (0-3).
## @return Piece object.
func get_piece(player_id: int, piece_idx: int) -> Piece:
	return self.players[player_id].pieces()[piece_idx]


## Seeds a piece at a specific route position for a player.
## @param player_id Player numeric ID.
## @param piece_idx Piece index (0-3).
## @param route_pos Target route position index.
func seed_piece_at_route_position(player_id: int, piece_idx: int, route_pos: int) -> void:
	var piece = self.get_piece(player_id, piece_idx)
	var player = self.get_player(player_id)
	var square_target = player.route().square_at(route_pos)
	
	# Find empty slot on square
	var slot = square_target.empty_position()
	if slot >= 0:
		square_target.set_piece_at_square_position(slot, piece)
		piece.square_position = slot
		piece.route_position = route_pos


## Returns square instance by ID (1-104).
## @param square_id Square ID.
## @return Square object.
func get_square(square_id: int) -> Square:
	return self.squares[square_id]


## Frees all created Node3D instances to prevent ObjectDB and RID memory leaks.
func cleanup() -> void:
	if self.board_node != null and is_instance_valid(self.board_node):
		self.board_node.free()
		self.board_node = null
	self.squares.clear()
	self.players.clear()
