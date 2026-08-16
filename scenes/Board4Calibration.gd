extends BoardCalibrationBase
class_name Board4Calibration

## Specialized 4-player board calibration tool inheriting from BoardCalibrationBase.

func _init() -> void:
	save_path = "res://scenes/board4_calibrated_positions.json"


## Instantiates 4-player board geometry with board materials.
func load_board_instance() -> void:
	var board_scene = load("res://scenes/Board4.tscn")
	if board_scene:
		board_inst = board_scene.instantiate()
		board_inst.setup_board_materials()
		add_child(board_inst)


## Returns all 104 square IDs of 4-player board (1..100, 101..104).
func get_square_ids() -> Array[int]:
	var square_ids: Array[int] = []
	for i in range(1, 101): square_ids.append(i)
	square_ids.append(101); square_ids.append(102); square_ids.append(103); square_ids.append(104)
	return square_ids



## Returns route square IDs for player on 4-player board.
func get_player_route_square_ids(player_id: int) -> Array:
	var route_inst = Route4.new(4, player_id, {})
	return route_inst._get_route_square_ids()
