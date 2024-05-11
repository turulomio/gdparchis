@tool
extends Node3D

@onready var Player0=$Player0
@onready var Player1=$Player1
@onready var Player2=$Player2
@onready var Player3=$Player3

var squares
var routes
var max_players: int=4

# Node that joins board, pieces and dices for 4 max players

@export var show_pieces: bool=true: set=set_show_pieces #With id I should have everything to calculate data
# Called when the node enters the scene tree for the first time.
func _ready():
	
	## Creating squares
	self.squares=SquareManager.new()
	for i in range(1,105):
		self.squares.append(Square.new(i))
	
	## Creating routes
	self.routes={}
	for e_color in Globals.e_colors(self.max_players):
		self.routes[str(e_color)]=Route.new(self.max_players, e_color, self.squares)
	for player in self.players():
		player.set_route(self.routes[str(player.id)])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_show_pieces(value):
	show_pieces=value
	await self.ready ## Necesita esperar que los nodos hijos estén preparados
	for player in self.players():
		player.set_show_pieces(value)

func players():
	return [Player0, Player1,Player2,Player3]

func players_than_plays():
	var r=[]
	for player in self.players():
		if player.plays:
			r.append(player)
	return r
