extends GameBase
class_name Game3


## Returns the Board3 child node instance.
## @return BoardBase node.
func board() -> BoardBase:
	return $Board3 if has_node("Board3") else super.board()



## Process preset camera view angles for 3 players (Yellow, Blue, Red).
## @param _delta Frame time delta.
func process_camera_inputs(_delta: float) -> void:
	if Input.is_action_just_pressed("top_view"):
		OrCamera.look_at_from_position(Vector3(0, 50, 0), Vector3(0, 0, 0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
	if Input.is_action_just_pressed("bottom_view"):
		OrCamera.look_at_from_position(Vector3(0, -50, 0), Vector3(0, 0, -0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
	if Input.is_action_just_pressed("yellow_view"):
		OrCamera.look_at_from_position(Vector3(0, 48, -25), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("blue_view"):
		OrCamera.look_at_from_position(Vector3(-22, 48, 13), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("red_view"):
		OrCamera.look_at_from_position(Vector3(22, 48, 13), Vector3(0, -11.0, 0), Vector3.UP)
