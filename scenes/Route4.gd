extends Route
class_name Route4


## Returns the ordered list of square IDs for a 4-player board route.
## @return Array of square ID integers.
func _get_route_square_ids():
	if self.player_id == Globals.ePlayer.YELLOW:
		return ([101] + range(5, 76 + 1))
	elif self.player_id == Globals.ePlayer.BLUE:
		return [102] + range(22, 68 + 1) + range(1, 17 + 1) + range(77, 84 + 1)
	elif self.player_id == Globals.ePlayer.RED:
		return [103] + range(39, 68 + 1) + range(1, 34 + 1) + range(85, 92 + 1)
	elif self.player_id == Globals.ePlayer.GREEN:
		return [104] + range(56, 68 + 1) + range(1, 51 + 1) + range(93, 100 + 1)
	return []
