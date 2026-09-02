extends Route
class_name Route8


## Returns the ordered list of square IDs for an 8-player board route.
## @return Array of square ID integers.
func _get_route_square_ids():
	var start_sq = 5 + self.player_id * 17
	var home_ramp_base = 137 + self.player_id * 8
	var home_sq = 201 + self.player_id
	var main_route: Array = []
	for i in range(136):
		main_route.append(((start_sq - 1 + i) % 136) + 1)
	var track_segment = main_route.slice(0, 132)
	var ramp_segment: Array = []
	for r_idx in range(8):
		ramp_segment.append(home_ramp_base + r_idx)
	return [home_sq] + track_segment + ramp_segment
