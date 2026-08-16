extends GameBase
class_name Game6


## Returns the Board6 child node instance.
## @return Board6 node.
func board() -> BoardBase:
	return $Board6 if has_node("Board6") else super.board()



## Process preset camera view angles for 6 players.
## @param _delta Frame time delta.
func process_camera_inputs(_delta: float) -> void:
	if Input.is_action_just_pressed("top_view"):
		if self.board():
			self.board().setup_camera_top(OrCamera)
