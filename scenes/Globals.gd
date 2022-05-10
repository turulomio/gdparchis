extends Node 

enum eSquareTypes {START, FIRST, NORMAL, SECURE, RAMP, END}
enum eColors  {YELLOW, BLUE, RED, GREEN}

func e_colors(max_players):
	if max_players==4:
		return [eColors.YELLOW,eColors.BLUE,eColors.RED,eColors.GREEN]

# Lo calcule ayudandome de la función y con simetrías
#func get_object_under_mouse():
#	var mouse_pos=get_viewport().get_mouse_position()
#	var ray_from=$Camera.project_ray_origin(mouse_pos)
#	var ray_to= ray_from + $Camera.project_ray_normal(mouse_pos)*1000
#	var space_state=get_world().direct_space_state
#	var selection=space_state.intersect_ray(ray_from,ray_to)
#	print(selection)
#	return selection.collider
func position4(square_id, square_position):
	var h=40
	match square_id:
		1:
			return [Vector3(-4.9,h,-30.2), Vector3(-7.8,h,-30.2)][square_position]
		2:
			return [Vector3(-4.9,h,-27.0), Vector3(-7.8,h,-27.0)][square_position]
		3:
			return [Vector3(-4.9,h,-23.8), Vector3(-7.8,h,-23.8)][square_position]
		4:
			return [Vector3(-4.9,h,-20.6), Vector3(-7.8,h,-20.6)][square_position]
		5:
			return [Vector3(-4.9,h,-17.4), Vector3(-7.8,h,-17.4)][square_position]
		6:
			return [Vector3(-4.9,h,-14.2), Vector3(-7.8,h,-14.2)][square_position]
		7:
			return [Vector3(-4.9,h,-11.1), Vector3(-7.8,h,-11.1)][square_position]
		8:
			return [Vector3(-4.3,h,-7.9), Vector3(-6.9,h,-8.2)][square_position]
		101:
			return [Vector3(-21,h,-21+3.2), Vector3(-21+3,h,-21+3.2),Vector3(-21+6,h,-21+3.2),Vector3(-21+9,h,-21+3.2)][square_position]
		102:
			return [Vector3(-17.5,h,11.7), Vector3(-17.5,h,14.7),Vector3(-17.5,h,17.7),Vector3(-17.5,h,20.7)][square_position]
		103:
			return [Vector3(21,h,21-3.2), Vector3(21-3,h,21-3.2),Vector3(21-6,h,21-3.2),Vector3(21-9,h,21-3.2)][square_position]
		104:
			return [Vector3(17.5,h,-11.7), Vector3(17.5,h,-14.7),Vector3(17.5,h,-17.7),Vector3(17.5,h,-20.7)][square_position]
		_:
			return [Vector3(0,h+square_id*1,33),Vector3(5,h+square_id*1,33),Vector3(10,h+square_id*1,33),Vector3(15,h+square_id*1,33)][square_position]

