class_name Route
extends ListManager

var max_players: int
var e_color
var id
func _init (_p_max_players, _e_color,_squares):
	self.max_players=_p_max_players
	self.e_color=_e_color
	for i in self.get_route_square_ids(self.max_players,self.e_color):
		self.append(_squares.my_get(i))

func _to_string():
	return "[Route: "+ str(self.e_color) + "]"

func get_route_square_ids(_max_players, _eColors):
	if _max_players==4:
		if _eColors==Globals.eColors.YELLOW:
			self.id=0
			return ([101]+range(5, 76+1))
		elif _eColors==Globals.eColors.BLUE:
			self.id=1
			return [102]+ range(22, 68+1)+range(1, 17+1)+range(77, 84+1)
		elif _eColors==Globals.eColors.RED:
			self.id=2
			return [103]+ range(39, 68+1) + range(1, 34+1) + range(85, 92+1)
		elif _eColors==Globals.eColors.GREEN:
			self.id=3

			return [104]+ range(56, 68+1) + range(1, 51+1) + range(93, 100+1)
## -1 is used for debug
func square_at(_route_position):
	if _route_position <0 or _route_position>=self.size():
		return null
	return self.arr[_route_position]
	
func end_position():
	return self.arr.size()-1
	
func is_there_barrier(from_position,to_position):
	for square_position in range(from_position+1,to_position+1):#First doesn't count
		var square = self.square_at(square_position)
		if square.has_barrier()==true:
			return true
	return false
	
func size():
	return self.arr.size()
	
## Returns if is ramp valid for all max_players
func is_ramp(_position_route):
	if self.size()-1-8<_position_route and _position_route<self.size()-1:
		return true
	return false

## Si no está en la ruta devuelve -1
func position_in_route(square):
	return self.arr.find(square)
	
	
	
## Calcula la distancia de mi posición en la ruta y la de la casilla pieza en mi ruta
## Puedo ser positiva (delante), negativa(detras), 0 (en mi casilla) y none (no esta en mi ruta)
func distance_between_squares(from, to):
	var from_in_route=self.position_in_route(from)
	var to_in_route=self.position_in_route(to)
	if from_in_route==-1 or to_in_route==-1:
		return null
	return to_in_route-from_in_route
	
