extends GameDiceStartBase
class_name GameDiceStart8


## Returns the Board8 child node instance.
## @return BoardBase node.
func board() -> BoardBase:
	return $Board8 if has_node("Board8") else super.board()


## Returns target gameplay scene path for 8-player game.
## @return String path.
func get_target_game_scene_path() -> String:
	return "res://scenes/Game8.tscn"
