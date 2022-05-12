class_name Route
extends ListManager

var max_players: int
var e_color
func _init (_p_max_players, _e_color,_squares):
	self.max_players=_p_max_players
	self.e_color=_e_color
	for i in self.get_route_square_ids(self.max_players,self.e_color):
		self.append(_squares.get(i))

func _to_string():
	return "[Route: "+ str(self.e_color) + "]"

func get_route_square_ids(_max_players, _eColors):
	if _max_players==4:
		if _eColors==Globals.eColors.YELLOW:
			return ([101]+range(5, 76+1))
		elif _eColors==Globals.eColors.BLUE:
			return [102]+ range(22, 68+1)+range(1, 17+1)+range(77, 84+1)
		elif _eColors==Globals.eColors.RED:
			return [103]+ range(39, 68+1) + range(1, 34+1) + range(85, 92+1)
		elif _eColors==Globals.eColors.GREEN:
			return [104]+ range(56, 68+1) + range(1, 51+1) + range(93, 100+1)

## -1 is used for debug
func square_at(_route_position):
	if _route_position <0 or _route_position>=self.size():
		return null
	return self.arr[_route_position]
