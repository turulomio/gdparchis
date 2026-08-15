const BoardBase = preload("res://scenes/BoardBase.gd")
extends BoardBase
class_name Board3

@onready var BoardNode = $Board if has_node("Board") else null
@onready var Player0 = $Player0 if has_node("Player0") else null
@onready var Player1 = $Player1 if has_node("Player1") else null
@onready var Player2 = $Player2 if has_node("Player2") else null


func _init():
	self.max_players = 3


## Specialized 3D position calculator for 3-player board geometry.
func get_position3d(square_id: int, square_position: int, h: float = 0.2) -> Vector3:
	return Globals.position3(square_id, square_position, h)
