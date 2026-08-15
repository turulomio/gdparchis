extends Route
class_name Route6

## Returns the ordered list of square IDs for a 6-player board route.
## @return Array of square ID integers.
func _get_route_square_ids():
	if self.player_id == Globals.ePlayer.YELLOW:
		return [151] + range(5, 102 + 1) + range(103, 110 + 1)
	elif self.player_id == Globals.ePlayer.BLUE:
		return [152] + range(22, 102 + 1) + range(1, 16 + 1) + range(111, 118 + 1)
	elif self.player_id == Globals.ePlayer.RED:
		return [153] + range(39, 102 + 1) + range(1, 34 + 1) + range(119, 126 + 1)
	elif self.player_id == Globals.ePlayer.GREEN:
		return [154] + range(56, 102 + 1) + range(1, 51 + 1) + range(127, 134 + 1)
	elif self.player_id == Globals.ePlayer.GREY:
		return [155] + range(73, 102 + 1) + range(1, 68 + 1) + range(135, 142 + 1)
	elif self.player_id == Globals.ePlayer.PINK:
		return [156] + range(90, 102 + 1) + range(1, 85 + 1) + range(143, 150 + 1)
	return []
