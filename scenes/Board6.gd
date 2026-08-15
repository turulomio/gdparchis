extends BoardBase
class_name Board6

@onready var BoardNode = $Board if has_node("Board") else null
@onready var Player0 = $Player0 if has_node("Player0") else null
@onready var Player1 = $Player1 if has_node("Player1") else null
@onready var Player2 = $Player2 if has_node("Player2") else null
@onready var Player3 = $Player3 if has_node("Player3") else null
@onready var Player4 = $Player4 if has_node("Player4") else null
@onready var Player5 = $Player5 if has_node("Player5") else null


func _init():
	self.max_players = 6


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


## Loads calibrated position overrides from res://scenes/board6_calibrated_positions.json if present in the project.
func load_user_calibration() -> void:
	var path = "res://scenes/board6_calibrated_positions.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json_data = JSON.parse_string(file.get_as_text())
			if json_data is Dictionary:
				user_calib_data = json_data
			file.close()
	user_calib_loaded = true


## Specialized 3D position calculator for 6-player board geometry loaded directly from JSON calibration file.
func get_position3d(square_id: int, square_position: int, h: float = 0.2) -> Vector3:
	if not user_calib_loaded:
		load_user_calibration()
		
	var key_str = "%d_%d" % [square_id, square_position]
	if user_calib_data.has(key_str):
		var d = user_calib_data[key_str]
		if d is Dictionary and d.has("x") and d.has("z"):
			return Vector3(float(d["x"]), h, float(d["z"]))

	return Vector3(0, h, 0)
