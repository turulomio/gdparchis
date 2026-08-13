extends Node3D
class_name Board4

@onready var Board = $Board
@onready var Player0 = $Player0
@onready var Player1 = $Player1
@onready var Player2 = $Player2
@onready var Player3 = $Player3

var squares
var max_players: int = 4
var show_pieces


## Node ready lifecycle callback.
func _ready():
	pass


## Initializes the 4-player board, squares dictionary, routes, and initial piece positions.
## @param _show_pieces Boolean indicating whether piece visual meshes should be visible.
func initialize(_show_pieces):
	self.show_pieces = _show_pieces
	
	# Instantiate all 104 board squares into dictionary indexed by ID
	self.squares = {}
	for i in range(1, 105):
		self.squares[i] = Square.new(i)

	# Initialize players, assign routes, and place pieces on final home squares
	for player in self.players():
		player.initialize(self.show_pieces)
		player.set_route(Route.new(self.max_players, player.id, self.squares))
		
		# Set piece starting positions on home route end
		var square_position = 0
		for piece in player.pieces():
			piece.set_final_position(player.route().end_position(), square_position, player.route().square_at(player.route().end_position()).id)
			square_position += 1

	# Export python configuration data for backend integration
	self.write_python_files()


## Exports squares4.py and routes4.py configuration files used by backend endpoints.
func write_python_files():
	# Generate squares dictionary script for backend
	var file_new = FileAccess.open("squares4.py", FileAccess.WRITE)
	var r = "squares4={\n"
	for square in self.squares.values():
		r += "{0}:{'id':{0},'type':{1},'color':{2},'max_pieces':{3}},\n".format([square.id, square.type, Globals.Color2ePlayer(square.color), square.max_pieces()])
	r = r.replace("<null>", "None")
	r += "}\n"
	file_new.store_line(r)
	file_new.close()
	
	# Generate routes dictionary script for backend
	var file_new2 = FileAccess.open("routes4.py", FileAccess.WRITE)
	var r2 = "routes4={\n"
	for player in self.players():
		var route = []
		for square in player.route().arr:
			route.append(square.id)
		r2 += "{0}:{'id':{0},'route': {1}},\n".format([player.id, str(route)])
	r2 += "}\n"
	file_new2.store_line(r2)
	file_new2.close()


## Sets piece visibility state.
## @param value Boolean visibility flag.
func set_show_pieces(value):
	show_pieces = value


## Returns an array of all Player child nodes.
## @return Array of Player objects.
func players():
	var r = []
	for children in self.get_children():
		if children is Player:
			r.append(children)
	return r


## Returns an array of active players participating in the current game.
## @return Array of participating Player objects.
func players_than_plays():
	var r = []
	for player in self.players():
		if player.plays:
			r.append(player)
	return r


## Finds and returns a Player object by numeric ID.
## @param id Player ID integer (0-3).
## @return Player object or null.
func get_player_by_id(id):
	for player in self.players():
		if player.id == id:
			return player
	print("NO SE HA ENCONTRADO PLAYER", id)
	return null


## Finds and returns a Piece object matching player ID and piece sub-ID.
## @param player_id Owner player ID.
## @param piece_id Sub-index piece ID (0-3).
## @return Piece object or null.
func get_piece_by_player_id_and_id(player_id, piece_id):
	for player in self.players():
		if player.id == player_id:
			for piece in player.pieces():
				if piece.id == piece_id:
					return piece
	print("NO SE HA ENCONTRADO PIEZA", player_id, piece_id)
	return null
