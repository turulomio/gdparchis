class_name Route

var max_players: int
var player_id
var arr = []


## Constructor building player route array from global squares mapping.
## @param _p_max_players Total players in game.
## @param _player_id Owner player ID.
## @param _squares Global dictionary of squares.
func _init(_p_max_players, _player_id, _squares):
	self.max_players = _p_max_players
	self.player_id = _player_id
	
	# Populate route array with Square objects in order
	for i in self._get_route_square_ids():
		arr.append(_squares[i])


## String representation helper.
## @return String representation.
func _to_string():
	return "[Route: " + str(self.player_id) + "]"


## Internal helper returning the ordered list of square IDs for this player's route.
## @return Array of square ID integers.
func _get_route_square_ids():
	if self.max_players == 3 or self.max_players == 4:
		if self.player_id == Globals.ePlayer.YELLOW:
			return ([101] + range(5, 76 + 1))
		elif self.player_id == Globals.ePlayer.BLUE:
			return [102] + range(22, 68 + 1) + range(1, 17 + 1) + range(77, 84 + 1)
		elif self.player_id == Globals.ePlayer.RED:
			return [103] + range(39, 68 + 1) + range(1, 34 + 1) + range(85, 92 + 1)
		elif self.player_id == Globals.ePlayer.GREEN:
			return [104] + range(56, 68 + 1) + range(1, 51 + 1) + range(93, 100 + 1)
	elif self.max_players == 6:
		var start_sq = 5 + self.player_id * 17
		var home_ramp_base = 108 + self.player_id * 8
		var home_sq = 151 + self.player_id
		var main_route: Array = []
		for i in range(102):
			main_route.append(((start_sq - 1 + i) % 102) + 1)
		var track_segment = main_route.slice(0, 102 - 17)
		var ramp_segment: Array = []
		for r_idx in range(8):
			ramp_segment.append(home_ramp_base + r_idx)
		return [home_sq] + track_segment + ramp_segment
	elif self.max_players == 8:
		var start_sq = 5 + self.player_id * 17
		var home_ramp_base = 144 + self.player_id * 8
		var home_sq = 201 + self.player_id
		var main_route: Array = []
		for i in range(136):
			main_route.append(((start_sq - 1 + i) % 136) + 1)
		var track_segment = main_route.slice(0, 136 - 17)
		var ramp_segment: Array = []
		for r_idx in range(8):
			ramp_segment.append(home_ramp_base + r_idx)
		return [home_sq] + track_segment + ramp_segment
	return []


## Returns Square object at the specified index in the route.
## @param _route_position Index in route array.
## @return Square object or null if out of bounds.
func square_at(_route_position):
	if _route_position < 0 or _route_position >= self.size():
		return null
	return self.arr[_route_position]


## Returns the final goal route index.
## @return Integer index of last square.
func end_position():
	return self.arr.size() - 1


## Evaluates whether any barrier exists in the route segment between two positions.
## @param from_position Starting route index (exclusive).
## @param to_position Target route index (inclusive).
## @return True if a barrier blocks the path.
func is_there_barrier(from_position, to_position):
	for square_position in range(from_position + 1, to_position + 1):
		var square = self.square_at(square_position)
		if square and square.has_barrier() == true:
			return true
	return false


## Returns total number of squares in this route.
## @return Integer count.
func size():
	return self.arr.size()


## Checks if the specified route position lies within the final home ramp.
## @param _position_route Index in route array.
## @return True if position is inside home ramp corridor.
func is_ramp(_position_route):
	if self.size() - 1 - 8 < _position_route and _position_route < self.size() - 1:
		return true
	return false


## Finds the route index corresponding to a given Square object.
## @param square Square instance.
## @return Route index integer or -1 if square is not in this route.
func position_in_route(square):
	return self.arr.find(square)


## Calculates the route distance between two Square objects in this route.
## @param from Starting Square.
## @param to Target Square.
## @return Signed integer distance or null if either square is not in route.
func distance_between_squares(from, to):
	var from_in_route = self.position_in_route(from)
	var to_in_route = self.position_in_route(to)
	if from_in_route == -1 or to_in_route == -1:
		return null
	return to_in_route - from_in_route
