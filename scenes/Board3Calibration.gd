extends BoardCalibrationBase
class_name Board3Calibration

## Specialized 3-player board calibration tool inheriting from BoardCalibrationBase.

func _init() -> void:
	save_path = "res://scenes/board3_calibrated_positions.json"


func _ready() -> void:
	super._ready()
	reset_camera_view()


## Resets camera height and horizontal pan position back to center for Board 3.
func reset_camera_view() -> void:
	super.reset_camera_view()


## Instantiates 3-player board geometry with wooden frame and board materials.
func load_board_instance() -> void:
	var board_scene = load("res://scenes/Board3.tscn")
	if board_scene:
		board_inst = board_scene.instantiate()
		if board_inst.has_method("setup_wooden_frame"):
			board_inst.setup_wooden_frame()
		board_inst.setup_board_materials()
		add_child(board_inst)


## Returns all 78 square IDs of 3-player board (1..75, 101..103).
func get_square_ids() -> Array[int]:
	var square_ids: Array[int] = []
	for i in range(1, 76): square_ids.append(i)
	square_ids.append(101); square_ids.append(102); square_ids.append(103)
	return square_ids



## Returns route square IDs for player on 3-player board.
func get_player_route_square_ids(player_id: int) -> Array:
	var route_inst = Route3.new(3, player_id, {})
	return route_inst._get_route_square_ids()
