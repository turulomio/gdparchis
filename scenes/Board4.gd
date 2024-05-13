
extends Node3D
class_name Board4

@onready var Board=$Board
@onready var Player0=$Player0
@onready var Player1=$Player1
@onready var Player2=$Player2
@onready var Player3=$Player3

var squares
var max_players: int=4

# Node that joins board, pieces and dices for 4 max players

var show_pieces
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func initialize(_show_pieces):
	self.show_pieces=_show_pieces
	## Creating squares dictionary. We normally access by square id
	self.squares={}
	for i in range(1,105):
		self.squares[i]=Square.new(i)
		
	for i in range(self.max_players):
		var player=self.players()[i]
		player.initialize(i,self.show_pieces)
		player.set_route(Route.new(self.max_players, player.id, self.squares))
		#Sets pieces at final square
		var piece_position=0
		for piece in player.pieces():
			piece.move_to_route_position(player.route().end_position(), 0)
			await piece.piece_moved
			#piece.global_transform.origin=Globals.position4(player.route().square_at(player.route().end_position()).id,piece_position)
			#piece_position+=1
		player.dice().set_my_position(5)
					#square_position=square_position+1
					#piece.move_to_route_position(player.route.end_position(),0.1) 
					#await piece.piece_moved

func set_show_pieces(value):
	show_pieces=value

func players():
	return get_tree().get_nodes_in_group("players")

func players_than_plays():
	var r=[]
	for player in self.players():
		if player.plays:
			r.append(player)
	return r
