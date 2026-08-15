extends GameDiceStartBase
class_name GameDiceStart3


## Returns the Board3 child node instance.
## @return BoardBase node.
func board() -> BoardBase:
	return $Board3 if has_node("Board3") else super.board()


## Returns target gameplay scene path for 3-player game.
## @return String path.
func get_target_game_scene_path() -> String:
	return "res://scenes/Game3.tscn"
