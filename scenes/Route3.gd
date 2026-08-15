extends Route
class_name Route3


## Returns the ordered list of square IDs for a 3-player board route.
## @return Array of square ID integers.
func _get_route_square_ids():
	if self.player_id == Globals.ePlayer.YELLOW:
		return [76] + Array(range(5, 51)) + Array(range(1, 5)) + Array(range(51, 59 + 1))
	elif self.player_id == Globals.ePlayer.BLUE:
		return [77] + Array(range(22, 51)) + Array(range(1, 22)) + Array(range(60, 67 + 1))
	elif self.player_id == Globals.ePlayer.RED:
		return [78] + Array(range(39, 51)) + Array(range(1, 39)) + Array(range(68, 75 + 1))
	return []
