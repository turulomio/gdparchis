extends BoardBase
class_name Board4

@onready var BoardNode = $Board if has_node("Board") else null
@onready var Player0 = $Player0 if has_node("Player0") else null
@onready var Player1 = $Player1 if has_node("Player1") else null
@onready var Player2 = $Player2 if has_node("Player2") else null
@onready var Player3 = $Player3 if has_node("Player3") else null


func _init():
	self.max_players = 4


var user_calib_data: Dictionary = {}
var user_calib_loaded: bool = false


## Returns the custom calibrated piece scale (0.1 to 1.0) for a target square and slot.
func get_piece_scale(square_id: int, square_position: int) -> float:
	if not user_calib_loaded:
		load_user_calibration()
	var key_str = "%d_%d" % [square_id, square_position]
	if user_calib_data.has(key_str):
		var d = user_calib_data[key_str]
		if d is Dictionary and d.has("scale"):
			return float(d["scale"])
	return 1.0


## Loads calibrated position overrides from res://scenes/board4_calibrated_positions.json if present in the project.
func load_user_calibration() -> void:
	var path = "res://scenes/board4_calibrated_positions.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json_data = JSON.parse_string(file.get_as_text())
			if json_data is Dictionary:
				user_calib_data = json_data
			file.close()
	user_calib_loaded = true


## Specialized 3D position calculator for 4-player board geometry loaded directly from JSON calibration file.
func get_position3d(square_id: int, square_position: int, h: float = 0.2) -> Vector3:
	if not user_calib_loaded:
		load_user_calibration()
		
	var key_str = "%d_%d" % [square_id, square_position]
	if user_calib_data.has(key_str):
		var d = user_calib_data[key_str]
		if d is Dictionary and d.has("x") and d.has("z"):
			return Vector3(float(d["x"]), h, float(d["z"]))

	return Vector3(0, h, 0)


## Returns max slots per square (4 for goal triangles & home houses, 2 for arm squares).
func get_max_slots(sq_id: int) -> int:
	return 4 if sq_id in [76, 84, 92, 100, 101, 102, 103, 104] else 2


## Populates and configures squares dictionary for 4-player board geometry.
func setup_squares() -> void:
	self.squares = {}
	for i in range(1, 101):
		self.squares[i] = Square.new(i, Globals.eSquareTypes.NORMAL)
	for i in [101, 102, 103, 104]:
		self.squares[i] = Square.new(i, Globals.eSquareTypes.START)

	self.squares[5].type = Globals.eSquareTypes.FIRST
	self.squares[5].color = Color.YELLOW
	self.squares[22].type = Globals.eSquareTypes.FIRST
	self.squares[22].color = Color.BLUE
	self.squares[39].type = Globals.eSquareTypes.FIRST
	self.squares[39].color = Globals.ePlayer2Color(2)
	self.squares[56].type = Globals.eSquareTypes.FIRST
	self.squares[56].color = Globals.ePlayer2Color(3)

	for sq_id in [12, 17, 29, 34, 46, 51, 63, 68]:
		self.squares[sq_id].type = Globals.eSquareTypes.SECURE

	self.squares[76].type = Globals.eSquareTypes.END
	self.squares[76].color = Color.YELLOW
	self.squares[84].type = Globals.eSquareTypes.END
	self.squares[84].color = Color.BLUE
	self.squares[92].type = Globals.eSquareTypes.END
	self.squares[92].color = Globals.ePlayer2Color(2)
	self.squares[100].type = Globals.eSquareTypes.END
	self.squares[100].color = Globals.ePlayer2Color(3)

	self.squares[101].color = Color.YELLOW
	self.squares[102].color = Color.BLUE
	self.squares[103].color = Globals.ePlayer2Color(2)
	self.squares[104].color = Globals.ePlayer2Color(3)
