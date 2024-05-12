
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

@export var show_pieces: bool=true: 
	set(value):
		show_pieces=value #With id I should have everything to calculate data
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func initialize():
	print("BOARD READY FINISH", self.is_node_ready())
	print(players())
	for player in self.players():
			print("READY PLAYER", player)
			player.show_pieces=self.show_pieces
	## Creating squares dictionary. We normally access by square id
	self.squares={}
	for i in range(1,105):
		self.squares[i]=Square.new(i)
	
	## Creating routes
	for player in self.players():
			player.set_route(Route.new(self.max_players, player.id, self.squares))
		

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
