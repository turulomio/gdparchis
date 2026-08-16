extends GameBase
class_name Game4


## Returns the Board4 child node instance.
## @return Board4 node.
func board() -> BoardBase:
	return $Board4 if has_node("Board4") else super.board()



## Process preset camera view angles for 4 players (Yellow, Blue, Red, Green).
## @param _delta Frame time delta.
func process_camera_inputs(_delta: float) -> void:
	if Input.is_action_just_pressed("top_view"):
		if self.board():
			self.board().setup_camera_top(OrCamera)
	if Input.is_action_just_pressed("bottom_view"):
		if self.board():
			OrCamera.position = Vector3(self.board().camera_top_position.x, -self.board().camera_top_position.y, self.board().camera_top_position.z)
			OrCamera.rotation_degrees = Vector3(90, 0, 0)
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
