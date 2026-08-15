const GameDiceStartBase = preload("res://scenes/GameDiceStartBase.gd")
extends GameDiceStartBase
class_name GameDiceStart4


## Returns the Board4 child node instance.
## @return BoardBase node.
func board() -> BoardBase:
	return $Board4 if has_node("Board4") else super.board()


## Returns target gameplay scene path for 4-player game.
## @return String path.
func get_target_game_scene_path() -> String:
	return "res://scenes/Game4.tscn"
