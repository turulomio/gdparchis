extends GameBase
class_name Game8


## Returns the Board8 child node instance.
## @return Board8 node.
func board() -> BoardBase:
	return $Board8 if has_node("Board8") else super.board()


## Process preset camera view angles for 8 players.
## @param _delta Frame time delta.
func process_camera_inputs(_delta: float) -> void:
	if Input.is_action_just_pressed("top_view"):
		if self.board():
			self.board().setup_camera_top(OrCamera)
