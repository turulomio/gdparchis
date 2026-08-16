extends GameBase
class_name Game4


## Returns the Board4 child node instance.
## @return Board4 node.
func board() -> BoardBase:
	return $Board4 if has_node("Board4") else super.board()



## Process preset camera view angles for 4 players (Yellow, Blue, Red, Green).
## @param _delta Frame time delta.
func process_camera_inputs(_delta: float) -> void:
	var cam_h = self.board().camera_top_height if self.board() else 50.0
	if Input.is_action_just_pressed("top_view"):
		OrCamera.look_at_from_position(Vector3(0, cam_h, 0), Vector3(0, 0, 0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
	if Input.is_action_just_pressed("bottom_view"):
		OrCamera.look_at_from_position(Vector3(0, -cam_h, 0), Vector3(0, 0, -0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
	if Input.is_action_just_pressed("yellow_view"):
		OrCamera.look_at_from_position(Vector3(-18, 48, -18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("blue_view"):
		OrCamera.look_at_from_position(Vector3(-18, 48, 18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("red_view"):
		OrCamera.look_at_from_position(Vector3(18, 48, 18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("green_view"):
		OrCamera.look_at_from_position(Vector3(18, 48, -18), Vector3(0, -11.0, 0), Vector3.UP)
	if Input.is_action_just_pressed("yellow_view_floor"):
		OrCamera.look_at_from_position(Vector3(-30, 1, -30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("blue_view_floor"):
		OrCamera.look_at_from_position(Vector3(-30, 1, 30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("red_view_floor"):
		OrCamera.look_at_from_position(Vector3(30, 1, 30), Vector3(0, 1, 0), Vector3.UP)
	if Input.is_action_just_pressed("green_view_floor"):
		OrCamera.look_at_from_position(Vector3(30, 1, -30), Vector3(0, 1, 0), Vector3.UP)
