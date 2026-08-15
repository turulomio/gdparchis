extends Route
class_name Route3


## Returns the ordered list of square IDs for a 3-player board route.
## @return Array of square ID integers.
func _get_route_square_ids():
	if self.player_id == Globals.ePlayer.YELLOW:
		return [101] + Array(range(5, 51))  + Array(range(51, 59 + 1))
	elif self.player_id == Globals.ePlayer.BLUE:
		return [102] + Array(range(22, 51)) + Array(range(1, 18)) + Array(range(60, 67 + 1))
	elif self.player_id == Globals.ePlayer.RED:
		return [103] + Array(range(39, 51)) + Array(range(1, 35)) + Array(range(68, 75 + 1))
	return []
