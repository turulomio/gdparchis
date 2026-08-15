extends GameDiceStartBase
class_name GameDiceStart6


## Returns the Board6 child node instance.
## @return BoardBase node.
func board() -> BoardBase:
	return $Board6 if has_node("Board6") else super.board()


## Returns target gameplay scene path for 6-player game.
## @return String path.
func get_target_game_scene_path() -> String:
	return "res://scenes/Game6.tscn"
