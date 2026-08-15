extends RefCounted

var board_node
var squares: Dictionary = {}
var players: Array = []


## Initializes test simulator with a headless Board4 instance and 104 squares.
func _init():
	var BoardBaseScript = load("res://scenes/BoardBase.gd")
	var Board4Script = load("res://scenes/Board4.gd")
	var SquareScript = load("res://scenes/Square.gd")
	var PlayerScene = load("res://scenes/Player.tscn")
	var RouteScript = load("res://scenes/Route.gd")

	self.board_node = Board4Script.new()
	self.board_node.max_players = 4
	self.board_node.show_pieces = false
	self.board_node.setup_squares()
	self.squares = self.board_node.squares
		
	# Create 4 players (0: Yellow, 1: Blue, 2: Red, 3: Green)
	for i in range(4):
		var p = PlayerScene.instantiate()
		p.id = i
		p.plays = true
		p.ia = false
		p.color = Globals.ePlayer2Color(i)
		p.playername = Globals.ePlayerDefaultName(i)
		p.set_route(RouteScript.create(4, i, self.squares))
		
		self.players.append(p)
		self.board_node.add_child(p)


## Returns Square object at the given ID.
## @param square_id Integer square ID.
## @return Square object.
func get_square(square_id: int):
	return self.squares.get(square_id, null)


## Returns Player object at the given player index.
## @param player_id Integer player ID (0-3).
## @return Player object.
func get_player(player_id: int):
	if player_id >= 0 and player_id < self.players.size():
		return self.players[player_id]
	return null


## Returns Piece object for player_id and piece sub-index.
## @param player_id Integer player ID (0-3).
## @param piece_id Integer piece sub-index (0-3).
## @return Piece object.
func get_piece(player_id: int, piece_id: int):
	var p = self.get_player(player_id)
	if p:
		for pc in p.pieces():
			if pc.id == piece_id:
				return pc
	return null


## Frees memory by queueing node deletion for simulator board node.
func cleanup():
	if self.board_node and is_instance_valid(self.board_node):
		self.board_node.queue_free()
