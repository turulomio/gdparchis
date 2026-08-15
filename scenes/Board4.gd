extends BoardBase
class_name Board4

@onready var BoardNode = $Board if has_node("Board") else null
@onready var Player0 = $Player0 if has_node("Player0") else null
@onready var Player1 = $Player1 if has_node("Player1") else null
@onready var Player2 = $Player2 if has_node("Player2") else null
@onready var Player3 = $Player3 if has_node("Player3") else null


func _init():
	self.max_players = 4


## Specialized 3D position calculator for 4-player board geometry encapsulated in Board4.
func get_position3d(square_id: int, square_position: int, h: float = 0.2) -> Vector3:
	match square_id:
		1:
			return [Vector3(-4.9,h,-30.7), Vector3(-7.8,h,-30.7)][square_position]
		2:
			return [Vector3(-4.9,h,-27.5), Vector3(-7.8,h,-27.5)][square_position]
		3:
			return [Vector3(-4.9,h,-24.2), Vector3(-7.8,h,-24.2)][square_position]
		4:
			return [Vector3(-4.9,h,-21.0), Vector3(-7.8,h,-21.0)][square_position]
		5:
			return [Vector3(-4.9,h,-17.7), Vector3(-7.8,h,-17.7)][square_position]
		6:
			return [Vector3(-4.9,h,-14.5), Vector3(-7.8,h,-14.5)][square_position]
		7:
			return [Vector3(-4.9,h,-11.3), Vector3(-7.8,h,-11.3)][square_position]
		8:
			return [Vector3(-4.4,h,-8.1), Vector3(-6.5,h,-8.1)][square_position]
		9:
			return [Vector3(-8.1,h,-4.4), Vector3(-8.1,h,-6.5)][square_position]
		10:
			return [Vector3(-11.3,h,-4.9), Vector3(-11.3,h,-7.8)][square_position]
		11:
			return [Vector3(-14.5,h,-4.9), Vector3(-14.5,h,-7.8)][square_position]
		12:
			return [Vector3(-17.7,h,-4.9), Vector3(-17.7,h,-7.8)][square_position]
		13:
			return [Vector3(-21.0,h,-4.9), Vector3(-21.0,h,-7.8)][square_position]
		14:
			return [Vector3(-24.2,h,-4.9), Vector3(-24.2,h,-7.8)][square_position]
		15:
			return [Vector3(-27.5,h,-4.9), Vector3(-27.5,h,-7.8)][square_position]
		16:
			return [Vector3(-30.7,h,-4.9), Vector3(-30.7,h,-7.8)][square_position]
		17:
			return [Vector3(-30.7,h,1.5), Vector3(-30.7,h,-1.4)][square_position]
		18:
			return [Vector3(-30.7,h,4.9), Vector3(-30.7,h,7.8)][square_position]
		19:
			return [Vector3(-27.5,h,4.9), Vector3(-27.5,h,7.8)][square_position]
		20:
			return [Vector3(-24.2,h,4.9), Vector3(-24.2,h,7.8)][square_position]
		21:
			return [Vector3(-21.0,h,4.9), Vector3(-21.0,h,7.8)][square_position]
		22:
			return [Vector3(-17.7,h,4.9), Vector3(-17.7,h,7.8)][square_position]
		23:
			return [Vector3(-14.5,h,4.9), Vector3(-14.5,h,7.8)][square_position]
		24:
			return [Vector3(-11.3,h,4.9), Vector3(-11.3,h,7.8)][square_position]
		25:
			return [Vector3(-8.1,h,4.4), Vector3(-8.1,h,6.5)][square_position]
		26:
			return [Vector3(-4.4,h,8.1), Vector3(-6.5,h,8.1)][square_position]
		27:
			return [Vector3(-4.9,h,11.3), Vector3(-7.8,h,11.3)][square_position]
		28:
			return [Vector3(-4.9,h,14.5), Vector3(-7.8,h,14.5)][square_position]
		29:
			return [Vector3(-4.9,h,17.7), Vector3(-7.8,h,17.7)][square_position]
		30:
			return [Vector3(-4.9,h,21.0), Vector3(-7.8,h,21.0)][square_position]
		31:
			return [Vector3(-4.9,h,24.2), Vector3(-7.8,h,24.2)][square_position]
		32:
			return [Vector3(-4.9,h,27.5), Vector3(-7.8,h,27.5)][square_position]
		33:
			return [Vector3(-4.9,h,30.7), Vector3(-7.8,h,30.7)][square_position]
		34:
			return [Vector3(1.5,h,30.7), Vector3(-1.4,h,30.7)][square_position]
		35:
			return [Vector3(4.9,h,30.7), Vector3(7.8,h,30.7)][square_position]
		36:
			return [Vector3(4.9,h,27.5), Vector3(7.8,h,27.5)][square_position]
		37:
			return [Vector3(4.9,h,24.2), Vector3(7.8,h,24.2)][square_position]
		38:
			return [Vector3(4.9,h,21.0), Vector3(7.8,h,21.0)][square_position]
		39:
			return [Vector3(4.9,h,17.7), Vector3(7.8,h,17.7)][square_position]
		40:
			return [Vector3(4.9,h,14.5), Vector3(7.8,h,14.5)][square_position]
		41:
			return [Vector3(4.9,h,11.3), Vector3(7.8,h,11.3)][square_position]
		42:
			return [Vector3(4.4,h,8.1), Vector3(6.5,h,8.1)][square_position]
		59:
			return [Vector3(8.1,h,-4.4), Vector3(8.1,h,-6.5)][square_position]
		58:
			return [Vector3(11.3,h,-4.9), Vector3(11.3,h,-7.8)][square_position]
		57:
			return [Vector3(14.5,h,-4.9), Vector3(14.5,h,-7.8)][square_position]
		56:
			return [Vector3(17.7,h,-4.9), Vector3(17.7,h,-7.8)][square_position]
		55:
			return [Vector3(21.0,h,-4.9), Vector3(21.0,h,-7.8)][square_position]
		54:
			return [Vector3(24.2,h,-4.9), Vector3(24.2,h,-7.8)][square_position]
		53:
			return [Vector3(27.5,h,-4.9), Vector3(27.5,h,-7.8)][square_position]
		52:
			return [Vector3(30.7,h,-4.9), Vector3(30.7,h,-7.8)][square_position]
		51:
			return [Vector3(30.7,h,1.5), Vector3(30.7,h,-1.4)][square_position]
		50:
			return [Vector3(30.7,h,4.9), Vector3(30.7,h,7.8)][square_position]
		49:
			return [Vector3(27.5,h,4.9), Vector3(27.5,h,7.8)][square_position]
		48:
			return [Vector3(24.2,h,4.9), Vector3(24.2,h,7.8)][square_position]
		47:
			return [Vector3(21.0,h,4.9), Vector3(21.0,h,7.8)][square_position]
		46:
			return [Vector3(17.7,h,4.9), Vector3(17.7,h,7.8)][square_position]
		45:
			return [Vector3(14.5,h,4.9), Vector3(14.5,h,7.8)][square_position]
		44:
			return [Vector3(11.3,h,4.9), Vector3(11.3,h,7.8)][square_position]
		43:
			return [Vector3(8.1,h,4.4), Vector3(8.1,h,6.5)][square_position]
		60:
			return [Vector3(4.4,h,-8.1), Vector3(6.5,h,-8.1)][square_position]
		61:
			return [Vector3(4.9,h,-11.3), Vector3(7.8,h,-11.3)][square_position]
		62:
			return [Vector3(4.9,h,-14.5), Vector3(7.8,h,-14.5)][square_position]
		63:
			return [Vector3(4.9,h,-17.7), Vector3(7.8,h,-17.7)][square_position]
		64:
			return [Vector3(4.9,h,-21.0), Vector3(7.8,h,-21.0)][square_position]
		65:
			return [Vector3(4.9,h,-24.2), Vector3(7.8,h,-24.2)][square_position]
		66:
			return [Vector3(4.9,h,-27.5), Vector3(7.8,h,-27.5)][square_position]
		67:
			return [Vector3(4.9,h,-30.7), Vector3(7.8,h,-30.7)][square_position]
		68:
			return [Vector3(1.5,h,-30.7), Vector3(-1.4,h,-30.7)][square_position]
		69:
			return [Vector3(1.5,h,-27.5), Vector3(-1.4,h,-27.5)][square_position]
		70:
			return [Vector3(1.5,h,-24.2), Vector3(-1.4,h,-24.2)][square_position]
		71:
			return [Vector3(1.5,h,-21.0), Vector3(-1.4,h,-21.0)][square_position]
		72:
			return [Vector3(1.5,h,-17.7), Vector3(-1.4,h,-17.7)][square_position]
		73:
			return [Vector3(1.5,h,-14.5), Vector3(-1.4,h,-14.5)][square_position]
		74:
			return [Vector3(1.5,h,-11.3), Vector3(-1.4,h,-11.3)][square_position]
		75:
			return [Vector3(1.5,h,-8.0), Vector3(-1.4,h,-8.0)][square_position]		
		76:
			return [Vector3(3,h,-5), Vector3(0,h, -5), Vector3(-3,h,-5), Vector3(0,h,-2.2)][square_position]			
		77:
			return [Vector3(-27.5,h,1.5), Vector3(-27.5,h,-1.4)][square_position]
		78:
			return [Vector3(-24.2,h,1.5), Vector3(-24.2,h,-1.4)][square_position]
		79:
			return [Vector3(-21.0,h,1.5), Vector3(-21.0,h,-1.4)][square_position]
		80:
			return [Vector3(-17.7,h,1.5), Vector3(-17.7,h,-1.4)][square_position]
		81:
			return [Vector3(-14.5,h,1.5), Vector3(-14.5,h,-1.4)][square_position]
		82:
			return [Vector3(-11.3,h,1.5), Vector3(-11.3,h,-1.4)][square_position]
		83:
			return [Vector3(-8.0,h,1.5), Vector3(-8.0,h,-1.4)][square_position]
		84:
			return [Vector3(-5,h,-3), Vector3(-5,h, 0), Vector3(-5,h,3), Vector3(-2.2,h,0)][square_position]			
		85:
			return [Vector3(1.5,h,27.5), Vector3(-1.4,h,27.5)][square_position]
		86:
			return [Vector3(1.5,h,24.2), Vector3(-1.4,h,24.2)][square_position]
		87:
			return [Vector3(1.5,h,21.0), Vector3(-1.4,h,21.0)][square_position]
		88:
			return [Vector3(1.5,h,17.7), Vector3(-1.4,h,17.7)][square_position]
		89:
			return [Vector3(1.5,h,14.5), Vector3(-1.4,h,14.5)][square_position]
		90:
			return [Vector3(1.5,h,11.3), Vector3(-1.4,h,11.3)][square_position]
		91:
			return [Vector3(1.5,h,8.0), Vector3(-1.4,h,8.0)][square_position]
		92:
			return [Vector3(-3,h,5), Vector3(0,h, 5), Vector3(3,h,5), Vector3(0,h,2.2)][square_position]			
		93:
			return [Vector3(27.5,h,1.5), Vector3(27.5,h,-1.4)][square_position]
		94:
			return [Vector3(24.2,h,1.5), Vector3(24.2,h,-1.4)][square_position]
		95:
			return [Vector3(21.0,h,1.5), Vector3(21.0,h,-1.4)][square_position]
		96:
			return [Vector3(17.7,h,1.5), Vector3(17.7,h,-1.4)][square_position]
		97:
			return [Vector3(14.5,h,1.5), Vector3(14.5,h,-1.4)][square_position]
		98:
			return [Vector3(11.3,h,1.5), Vector3(11.3,h,-1.4)][square_position]
		99:
			return [Vector3(8.0,h,1.5), Vector3(8.0,h,-1.4)][square_position]
		100:
			return [Vector3(5,h,3), Vector3(5,h, 0), Vector3(5,h,-3), Vector3(2.2,h,0)][square_position]
		101:
			return [Vector3(-21,h,-21+3.2), Vector3(-21+3,h,-21+3.2),Vector3(-21+6,h,-21+3.2),Vector3(-21+9,h,-21+3.2)][square_position]
		102:
			return [Vector3(-17.5,h,11.7), Vector3(-17.5,h,14.7),Vector3(-17.5,h,17.7),Vector3(-17.5,h,20.7)][square_position]
		103:
			return [Vector3(21,h,21-3.2), Vector3(21-3,h,21-3.2),Vector3(21-6,h,21-3.2),Vector3(21-9,h,21-3.2)][square_position]
		104:
			return [Vector3(17.5,h,-11.7), Vector3(17.5,h,-14.7),Vector3(17.5,h,-17.7),Vector3(17.5,h,-20.7)][square_position]
		_:
			return [Vector3(0,h+square_id*1,33),Vector3(5,h+square_id*1,33),Vector3(10,h+square_id*1,33),Vector3(15,h+square_id*1,33)][square_position]
