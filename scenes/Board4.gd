
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
		

	for player in self.players():
		player.initialize(self.show_pieces)#Debeb inicializarse todos primeros
		player.set_route(Route.new(self.max_players, player.id, self.squares))
		#Sets pieces at final square
		var square_position=0
		for piece in player.pieces():
			piece.set_final_position(player.route().end_position(), square_position, player.route().square_at(player.route().end_position()).id) #Coloca las piezas en casillas al final, en posiciones de casillas sin mover
			square_position+=1


	self.write_python_files()
	

func write_python_files():
	# Used for django_gdparchis to generate file of squares
	var file_new=FileAccess.open("squares4.py", FileAccess.WRITE)
	var r="squares4={\n"
	for square in self.squares.values():
		r+="{0}:{'id':{0},'type':{1},'color':{2},'max_pieces':{3}},\n".format([square.id,square.type,Globals.Color2ePlayer(square.color),square.max_pieces()])
	r=r.replace("<null>","None")
	r+="}\n"
	file_new.store_line(r)
	file_new.close()
	# Used for django_gdparchis to generate file of squares
	var file_new2=FileAccess.open("routes4.py", FileAccess.WRITE)
	var r2="routes4={\n"
	for player in self.players():
		var route=[]
		for square in player.route().arr:
			route.append(square.id)
		r2+="{0}:{'id':{0},'route': {1}},\n".format([player.id, str(route)])
	r2+="}\n"
	file_new2.store_line(r2)
	file_new2.close()

func set_show_pieces(value):
	show_pieces=value

func players():
	var r= []
	for children in self.get_children():
		if children is Player:
			r.append(children)
	return r



func players_than_plays():
	var r=[]
	for player in self.players():
		if player.plays:
			r.append(player)
	return r


func get_player_by_id(id):
	for player in self.players():
		if player.id==id:
			return player
	print("NO SE HA ENCONTRADO PLAYER", id)
	return null



func get_piece_by_player_id_and_id(player_id, piece_id):
	for player in self.players():
		if player.id==player_id:
			for piece in player.pieces():
				if piece.id==piece_id:
					return piece
	print("NO SE HA ENCONTRADO PIEZA", player_id, piece_id)
	return null

# func get_piece_by_total_id(total_id):
# 	for piece in get_tree().get_nodes_in_group("pieces"):
# 		if piece.total_id()==total_id:
# 			return piece
# 	print("NO SE HA ENCONTRADO PIEZA POR TOTAL ID", total_id)
# 	return null
