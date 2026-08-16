extends GameBase
class_name Game6


## Returns the Board6 child node instance.
## @return Board6 node.
func board() -> BoardBase:
	return $Board6 if has_node("Board6") else super.board()



## Process preset camera view angles for 6 players.
## @param _delta Frame time delta.
func process_camera_inputs(_delta: float) -> void:
	var cam_h = self.board().camera_top_height if self.board() else 75.0
	if Input.is_action_just_pressed("top_view"):
		OrCamera.look_at_from_position(Vector3(0, cam_h, 0), Vector3(0, 0, 0.001), Vector3.UP)
		OrCamera.global_rotate(Vector3(0, 1, 0), PI)
