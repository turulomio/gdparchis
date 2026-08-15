extends BoardCalibrationBase
class_name Board6Calibration

## Specialized 6-player board calibration tool inheriting from BoardCalibrationBase.

func _init() -> void:
	save_path = "res://scenes/board6_calibrated_positions.json"


func _ready() -> void:
	super._ready()
	reset_camera_view()


## Resets camera height and horizontal pan position back to center for Board 6.
func reset_camera_view() -> void:
	if camera:
		camera.position = Vector3(0.0, 65.0, 0.0)
		camera.rotation_degrees = Vector3(-90, 0, 0)


## Instantiates 6-player board geometry with board materials.
func load_board_instance() -> void:
	var board_scene = load("res://scenes/Board6.tscn")
	if board_scene:
		board_inst = board_scene.instantiate()
		board_inst.setup_board_materials()
		add_child(board_inst)


## Returns all 156 square IDs of 6-player board (1..102 outer, 103..150 ramps/goals, 151..156 homes).
func get_square_ids() -> Array[int]:
	var square_ids: Array[int] = []
	for i in range(1, 157):
		square_ids.append(i)
	return square_ids



## Returns route square IDs for player on 6-player board.
func get_player_route_square_ids(player_id: int) -> Array:
	var route_inst = Route6.new(6, player_id, {})
	return route_inst._get_route_square_ids()
