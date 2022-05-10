extends Node 

enum eSquareTypes {START, FIRST, NORMAL, SECURE, RAMP, END}
enum eColors  {YELLOW, BLUE, RED, GREEN}

func e_colors(max_players):
	if max_players==4:
		return [eColors.YELLOW,eColors.BLUE,eColors.RED,eColors.GREEN]

func rotate(center, angle, point):
	return point

func position_4_start(center, angle, square_position):
	var r
	if square_position == 0: 
		 r= Vector3(center.x-6,center.y,center.z)
	if square_position == 1: 
		r= Vector3(center.x-3,center.y,center.z)
	if square_position == 2: 
		r= Vector3(center.x,center.y,center.z)
	if square_position == 3: 
		r= Vector3(center.x+3,center.y,center.z)
	
	return rotate(center,angle, r)
	
func position4(square_id, square_position):
		var h=40
		return position_4_start(Vector3(-15,h,-15),0,square_position)

