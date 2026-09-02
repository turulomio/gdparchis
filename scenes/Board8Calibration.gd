extends BoardCalibrationBase
class_name Board8Calibration

## Specialized 8-player board calibration tool inheriting from BoardCalibrationBase.

func _init() -> void:
	save_path = "res://scenes/board8_calibrated_positions.json"


func _ready() -> void:
	super._ready()
	reset_camera_view()


## Resets camera height and horizontal pan position back to center for Board 8.
func reset_camera_view() -> void:
	super.reset_camera_view()


## Instantiates 8-player board geometry with board materials.
func load_board_instance() -> void:
	var board_scene = load("res://scenes/Board8.tscn")
	if board_scene:
		board_inst = board_scene.instantiate()
		board_inst.setup_board_materials()
		add_child(board_inst)


## Returns all 208 square IDs of 8-player board (1..136 outer, 137..200 ramps/goals, 201..208 homes).
func get_square_ids() -> Array[int]:
	var square_ids: Array[int] = []
	for i in range(1, 209):
		square_ids.append(i)
	return square_ids


## Returns route square IDs for player on 8-player board.
func get_player_route_square_ids(player_id: int) -> Array:
	var route_inst = Route8.new(8, player_id, {})
	return route_inst._get_route_square_ids()
