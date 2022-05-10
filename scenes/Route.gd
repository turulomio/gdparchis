class_name Route
extends ListManager

var max_players: int
var e_color
func _init (p_max_players, e_color,squares):
	self.max_players=p_max_players
	self.e_color=e_color
	for i in self.get_route_square_ids(self.max_players,self.e_color):
		self.append(squares.get(i))

func _to_string():
	return "[Route: "+ str(self.e_color) + "]"

func get_route_square_ids(max_players, eColors):
	if max_players==4:
		if eColors==Globals.eColors.YELLOW:
			return ([101]+range(5, 76+1))
		elif eColors==Globals.eColors.BLUE:
			return [102]+ range(22, 68+1)+range(1, 17+1)+range(77, 84+1)
		elif eColors==Globals.eColors.RED:
			return [103]+ range(39, 68+1) + range(1, 34+1) + range(85, 92+1)
		elif eColors==Globals.eColors.GREEN:
			return [104]+ range(56, 68+1) + range(1, 51+1) + range(93, 100+1)
			
func square_at(route_position):
	return self.arr[route_position]
			
		
