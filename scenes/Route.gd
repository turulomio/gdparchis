class_name Route

var max_players: int
var player_id
var arr = []


## Factory method instantiating specialized Route subclasses based on player count.
static func create(_p_max_players: int, _player_id: int, _squares: Dictionary) -> Route:
	match _p_max_players:
		3:
			return Route3.new(_p_max_players, _player_id, _squares)
		4:
			return Route4.new(_p_max_players, _player_id, _squares)
		6:
			return Route6.new(_p_max_players, _player_id, _squares)
		8:
			return Route8.new(_p_max_players, _player_id, _squares)
		_:
			return Route.new(_p_max_players, _player_id, _squares)


## Constructor building player route array from global squares mapping.
## @param _p_max_players Total players in game.
## @param _player_id Owner player ID.
## @param _squares Global dictionary of squares.
func _init(_p_max_players, _player_id, _squares = {}):
	self.max_players = _p_max_players
	self.player_id = _player_id
	
	# Populate route array with Square objects in order if _squares is provided
	if _squares is Dictionary and not _squares.is_empty():
		for i in self._get_route_square_ids():
			if _squares.has(i):
				arr.append(_squares[i])


## String representation helper.
## @return String representation.
func _to_string():
	return "[Route: " + str(self.player_id) + "]"


## Internal helper returning the ordered list of square IDs for this player's route. Virtual.
## @return Array of square ID integers.
func _get_route_square_ids():
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
