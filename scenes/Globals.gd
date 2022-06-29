extends Node 
const VERSION="0.0.1"
const VERSION_DATE="2022-06-29"

enum eSquareTypes {START, FIRST, NORMAL, SECURE, RAMP, END}
enum eColors  {YELLOW, BLUE, RED, GREEN}
enum eDifficulty {EASY,NORMAL,DIFFICULT}
enum eLanguages {ENGLISH,SPANISH,FRENCH}
const UUID_UTIL = preload('res://scenes/uuid.gd')

const IMAGE_WOOD = preload("res://images/wood.png")

const SCENE_PIECE=preload("res://scenes/Piece.tscn")
const SCENE_PLAYER_OPTIONS=preload("res://scenes/PlayerOptions.tscn")
const SCENE_DICE=preload("res://scenes/Dice.tscn")

var game_data=null #Dictionary to load and init games
var settings
var	window_width=OS.get_screen_size().x
var window_height=OS.get_screen_size().y
var vector2_center=Vector2(window_width/2,window_height/2)

func _init():
	print("Singleton load")
	load_settings()

func e_colors(max_players):
	if max_players==4:
		return [eColors.YELLOW,eColors.BLUE,eColors.RED,eColors.GREEN]
		
func colorn(e_color):
	return ColorN(color_name(e_color),1)
	
func color_name(e_color):
	var r
	match int(e_color):
		eColors.YELLOW:
			r= "yellow"
		eColors.BLUE:
			r= "blue"
		eColors.RED:
			r= "red"
		eColors.GREEN:
			r= "green"
		_:
			r= "white"
	return r


	
func vector_is_almost_zero(v,precision=0.001):
	if self.value_almost_zero(v.x,precision) and self.value_almost_zero(v.y,precision) and self.value_almost_zero(v.z,precision):
		return true
	return false
	
func value_almost_zero(_value,precision=0.001):
	if abs(_value)<=precision:
		return true
	return false
	
func save_game(game):
	var dir= Directory.new()
	if dir.dir_exists("user://saves/")==false:
		dir.make_dir("user://saves/")
		
	#Removes innecesary autosaves
	var files=[]
	dir.open("user://saves/")
	dir.list_dir_begin()
	while true:
		var file=dir.get_next()
		if file=="":
			break
		else:
			if "autosave" in file:
				files.append(file)

	dir.list_dir_end()
	files.sort()
	var to_remove=files.slice(0,files.size()-Globals.settings.autosaves)
	for f in to_remove:
		dir.remove("user://saves/"+f)
		
	#Create new autosave
	var d=OS.get_datetime()
	filename="%d%s%s %s%s%s autosave %d.save" % [d.year,"%02d" % d.month,"%02d" %d.day,"%02d" %d.hour,"%02d" %d.minute, "%02d" %d.second, game.max_players]
	var file=File.new()
	file.open("user://saves/" + filename, File.WRITE)
	var dict={}	
	dict["max_players"]=game.players.max_players
	dict["current"]=game.players.current.id
	dict["fake_dice"]=[]
	dict["players"]=[]
	for p in game.players.values():
		var dict_p={}
		dict_p["id"]=p.id
		dict_p["name"]=p.name
		dict_p["plays"]=p.plays
		dict_p["ia"]=p.ia
		dict["players"].append(dict_p)
		dict_p["pieces"]=[]
		for piece in p.pieces:
			var dict_piece={}
			dict_piece["id"]=piece.id
			dict_piece["route_position"]=piece.route_position
			dict_piece["square_position"]=piece.square_position
			dict_p["pieces"].append(dict_piece)
	file.store_line(to_json(dict))
	file.close()
	
func new_game(max_players):
	var dict={}	
	dict["max_players"]=max_players
	dict["current"]=0
	dict["fake_dice"]=[]
	dict["players"]=[]
	for player_id in range(max_players):
		var dict_p={}
		dict_p["id"]=player_id
		dict_p["name"]=color_name(player_id)
		dict_p["plays"]=true
		if player_id==0:
			dict_p["ia"]=false
		else:
			dict_p["ia"]=true
		dict["players"].append(dict_p)
		dict_p["pieces"]=[]
		for i in range(4):
			var dict_piece={}
			dict_piece["id"]=(4*player_id)+i
			dict_piece["route_position"]=0
			dict_piece["square_position"]=i
			dict_p["pieces"].append(dict_piece)
	return dict
	
func load_game(filename):
	var file=File.new()
	file.open(filename, File.READ)
	var data=parse_json(file.get_line())
	file.close()
	return data
	
	
func save_settings():
	var file= File.new()
	file.open("user://gdparchis.cfg" + filename, File.WRITE)
	file.store_line(to_json(settings))
	file.close()
	print("Settings saved: ", settings)
	
func load_settings():
	var file_save=File.new()
	var file_load=File.new()
	if file_save.file_exists("user://gdparchis.cfg")==false:
		settings={}
		settings["full_screen"]=false
		settings["installation_uuid"]=generate_uuid()
		settings["automatic"]=false
		settings["last_internet_update"]=null
		settings["autosaves"]=10
		settings["difficulty"]=eDifficulty.NORMAL
		settings["language"]=eLanguages.ENGLISH
		settings["sound"]=true
		settings["statistics"]=true
		save_settings()
	else:
		file_load.open("user://gdparchis.cfg", File.READ)
		settings=parse_json(file_load.get_line())
	file_load.close()
	file_save.close()
	
	print("Settings loaded: ", settings)
	OS.window_fullscreen = settings["full_screen"]
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"),not settings["sound"])
	change_language(settings["language"])

func change_language(e_language):
	if e_language==eLanguages.SPANISH:
		TranslationServer.set_locale("es")
	elif e_language==eLanguages.FRENCH:
		TranslationServer.set_locale("fr")
	elif e_language==eLanguages.ENGLISH:
		TranslationServer.set_locale("en")


func generate_uuid():
	return UUID_UTIL.v4()

## Returns decision probabilty according is difficulty
func difficulty_probability():
	if self.settings["difficulty"]==eDifficulty.EASY:
		return 0.55
	elif self.settings["difficulty"]==eDifficulty.NORMAL:
		return 0.75
	else:
		return 0.95
	

# Lo calcule ayudandome de la función y con simetrías
#func get_object_under_mouse():
#	var mouse_pos=get_viewport().get_mouse_position()
#	var ray_from=$Camera.project_ray_origin(mouse_pos)
#	var ray_to= ray_from + $Camera.project_ray_normal(mouse_pos)*1000
#	var space_state=get_world().direct_space_state
#	var selection=space_state.intersect_ray(ray_from,ray_to)
#	return selection.collider
func position4(square_id, square_position):
	var h=1.1105
	match square_id:
		1:
			return [Vector3(-4.9,h,-30.7), Vector3(-7.8,h,-30.7)][square_position]
		2:
			return [Vector3(-4.9,h,-27.5), Vector3(-7.8,h,-27.5)][square_position]
		3:
			return [Vector3(-4.9,h,-24.2), Vector3(-7.8,h,-24.2)][square_position]
		4:
			return [Vector3(-4.9,h,-21.0), Vector3(-7.8,h,-21.0)][square_position]
		5:
			return [Vector3(-4.9,h,-17.7), Vector3(-7.8,h,-17.7)][square_position]
		6:
			return [Vector3(-4.9,h,-14.5), Vector3(-7.8,h,-14.5)][square_position]
		7:
			return [Vector3(-4.9,h,-11.3), Vector3(-7.8,h,-11.3)][square_position]
		8:
			return [Vector3(-4.4,h,-8.1), Vector3(-6.5,h,-8.1)][square_position]
			
			
		9:
			return [Vector3(-8.1,h,-4.4), Vector3(-8.1,h,-6.5)][square_position]
		10:
			return [Vector3(-11.3,h,-4.9), Vector3(-11.3,h,-7.8)][square_position]
		11:
			return [Vector3(-14.5,h,-4.9), Vector3(-14.5,h,-7.8)][square_position]
		12:
			return [Vector3(-17.7,h,-4.9), Vector3(-17.7,h,-7.8)][square_position]
		13:
			return [Vector3(-21.0,h,-4.9), Vector3(-21.0,h,-7.8)][square_position]
		14:
			return [Vector3(-24.2,h,-4.9), Vector3(-24.2,h,-7.8)][square_position]
		15:
			return [Vector3(-27.5,h,-4.9), Vector3(-27.5,h,-7.8)][square_position]
		16:
			return [Vector3(-30.7,h,-4.9), Vector3(-30.7,h,-7.8)][square_position]
		17:
			return [Vector3(-30.7,h,1.5), Vector3(-30.7,h,-1.4)][square_position]
		18:
			return [Vector3(-30.7,h,4.9), Vector3(-30.7,h,7.8)][square_position]
		19:
			return [Vector3(-27.5,h,4.9), Vector3(-27.5,h,7.8)][square_position]
		20:
			return [Vector3(-24.2,h,4.9), Vector3(-24.2,h,7.8)][square_position]
		21:
			return [Vector3(-21.0,h,4.9), Vector3(-21.0,h,7.8)][square_position]
		22:
			return [Vector3(-17.7,h,4.9), Vector3(-17.7,h,7.8)][square_position]
		23:
			return [Vector3(-14.5,h,4.9), Vector3(-14.5,h,7.8)][square_position]
		24:
			return [Vector3(-11.3,h,4.9), Vector3(-11.3,h,7.8)][square_position]
			
		25:
			return [Vector3(-8.1,h,4.4), Vector3(-8.1,h,6.5)][square_position]
			
		26:
			return [Vector3(-4.4,h,8.1), Vector3(-6.5,h,8.1)][square_position]
		27:
			return [Vector3(-4.9,h,11.3), Vector3(-7.8,h,11.3)][square_position]
		28:
			return [Vector3(-4.9,h,14.5), Vector3(-7.8,h,14.5)][square_position]
		29:
			return [Vector3(-4.9,h,17.7), Vector3(-7.8,h,17.7)][square_position]
		30:
			return [Vector3(-4.9,h,21.0), Vector3(-7.8,h,21.0)][square_position]
		31:
			return [Vector3(-4.9,h,24.2), Vector3(-7.8,h,24.2)][square_position]
		32:
			return [Vector3(-4.9,h,27.5), Vector3(-7.8,h,27.5)][square_position]
		33:
			return [Vector3(-4.9,h,30.7), Vector3(-7.8,h,30.7)][square_position]
		34:
			return [Vector3(1.5,h,30.7), Vector3(-1.4,h,30.7)][square_position]
			
			
		35:
			return [Vector3(4.9,h,30.7), Vector3(7.8,h,30.7)][square_position]
		36:
			return [Vector3(4.9,h,27.5), Vector3(7.8,h,27.5)][square_position]
		37:
			return [Vector3(4.9,h,24.2), Vector3(7.8,h,24.2)][square_position]
		38:
			return [Vector3(4.9,h,21.0), Vector3(7.8,h,21.0)][square_position]
		39:
			return [Vector3(4.9,h,17.7), Vector3(7.8,h,17.7)][square_position]
		40:
			return [Vector3(4.9,h,14.5), Vector3(7.8,h,14.5)][square_position]
		41:
			return [Vector3(4.9,h,11.3), Vector3(7.8,h,11.3)][square_position]
		42:
			return [Vector3(4.4,h,8.1), Vector3(6.5,h,8.1)][square_position]
			
		59:
			return [Vector3(8.1,h,-4.4), Vector3(8.1,h,-6.5)][square_position]
		58:
			return [Vector3(11.3,h,-4.9), Vector3(11.3,h,-7.8)][square_position]
		57:
			return [Vector3(14.5,h,-4.9), Vector3(14.5,h,-7.8)][square_position]
		56:
			return [Vector3(17.7,h,-4.9), Vector3(17.7,h,-7.8)][square_position]
		55:
			return [Vector3(21.0,h,-4.9), Vector3(21.0,h,-7.8)][square_position]
		54:
			return [Vector3(24.2,h,-4.9), Vector3(24.2,h,-7.8)][square_position]
		53:
			return [Vector3(27.5,h,-4.9), Vector3(27.5,h,-7.8)][square_position]
		52:
			return [Vector3(30.7,h,-4.9), Vector3(30.7,h,-7.8)][square_position]
		51:
			return [Vector3(30.7,h,1.5), Vector3(30.7,h,-1.4)][square_position]
		50:
			return [Vector3(30.7,h,4.9), Vector3(30.7,h,7.8)][square_position]
		49:
			return [Vector3(27.5,h,4.9), Vector3(27.5,h,7.8)][square_position]
		48:
			return [Vector3(24.2,h,4.9), Vector3(24.2,h,7.8)][square_position]
		47:
			return [Vector3(21.0,h,4.9), Vector3(21.0,h,7.8)][square_position]
		46:
			return [Vector3(17.7,h,4.9), Vector3(17.7,h,7.8)][square_position]
		45:
			return [Vector3(14.5,h,4.9), Vector3(14.5,h,7.8)][square_position]
		44:
			return [Vector3(11.3,h,4.9), Vector3(11.3,h,7.8)][square_position]
			
		43:
			return [Vector3(8.1,h,4.4), Vector3(8.1,h,6.5)][square_position]
			
			
			
		60:
			return [Vector3(4.4,h,-8.1), Vector3(6.5,h,-8.1)][square_position]
		61:
			return [Vector3(4.9,h,-11.3), Vector3(7.8,h,-11.3)][square_position]
		62:
			return [Vector3(4.9,h,-14.5), Vector3(7.8,h,-14.5)][square_position]
		63:
			return [Vector3(4.9,h,-17.7), Vector3(7.8,h,-17.7)][square_position]
		64:
			return [Vector3(4.9,h,-21.0), Vector3(7.8,h,-21.0)][square_position]
		65:
			return [Vector3(4.9,h,-24.2), Vector3(7.8,h,-24.2)][square_position]
		66:
			return [Vector3(4.9,h,-27.5), Vector3(7.8,h,-27.5)][square_position]
		67:
			return [Vector3(4.9,h,-30.7), Vector3(7.8,h,-30.7)][square_position]
		68:
			return [Vector3(1.5,h,-30.7), Vector3(-1.4,h,-30.7)][square_position]
		69:
			return [Vector3(1.5,h,-27.5), Vector3(-1.4,h,-27.5)][square_position]
		70:
			return [Vector3(1.5,h,-24.2), Vector3(-1.4,h,-24.2)][square_position]
		71:
			return [Vector3(1.5,h,-21.0), Vector3(-1.4,h,-21.0)][square_position]
		72:
			return [Vector3(1.5,h,-17.7), Vector3(-1.4,h,-17.7)][square_position]
		73:
			return [Vector3(1.5,h,-14.5), Vector3(-1.4,h,-14.5)][square_position]
		74:
			return [Vector3(1.5,h,-11.3), Vector3(-1.4,h,-11.3)][square_position]
		75:
			return [Vector3(1.5,h,-8.0), Vector3(-1.4,h,-8.0)][square_position]		
		76:
			return [Vector3(3,h,-5), Vector3(0,h, -5), Vector3(-3,h,-5), Vector3(0,h,-2.2)][square_position]			
		
		
		77: # Blue ramp
			return [Vector3(-27.5,h,1.5), Vector3(-27.5,h,-1.4)][square_position]
		78:
			return [Vector3(-24.2,h,1.5), Vector3(-24.2,h,-1.4)][square_position]
		79:
			return [Vector3(-21.0,h,1.5), Vector3(-21.0,h,-1.4)][square_position]
		80:
			return [Vector3(-17.7,h,1.5), Vector3(-17.7,h,-1.4)][square_position]
		81:
			return [Vector3(-14.5,h,1.5), Vector3(-14.5,h,-1.4)][square_position]
		82:
			return [Vector3(-11.3,h,1.5), Vector3(-11.3,h,-1.4)][square_position]
		83:
			return [Vector3(-8.0,h,1.5), Vector3(-8.0,h,-1.4)][square_position]
		84:
			return [Vector3(-5,h,-3), Vector3(-5,h, 0), Vector3(-5,h,3), Vector3(-2.2,h,0)][square_position]			
		
		
		
		
		85: # Red ramp
			return [Vector3(1.5,h,27.5), Vector3(-1.4,h,27.5)][square_position]
		86:
			return [Vector3(1.5,h,24.2), Vector3(-1.4,h,24.2)][square_position]
		87:
			return [Vector3(1.5,h,21.0), Vector3(-1.4,h,21.0)][square_position]
		88:
			return [Vector3(1.5,h,17.7), Vector3(-1.4,h,17.7)][square_position]
		89:
			return [Vector3(1.5,h,14.5), Vector3(-1.4,h,14.5)][square_position]
		90:
			return [Vector3(1.5,h,11.3), Vector3(-1.4,h,11.3)][square_position]
		91:
			return [Vector3(1.5,h,8.0), Vector3(-1.4,h,8.0)][square_position]
		92:
			return [Vector3(-3,h,5), Vector3(0,h, 5), Vector3(3,h,5), Vector3(0,h,2.2)][square_position]			
			
			
		93: # Green ramp
			return [Vector3(27.5,h,1.5), Vector3(27.5,h,-1.4)][square_position]
		94:
			return [Vector3(24.2,h,1.5), Vector3(24.2,h,-1.4)][square_position]
		95:
			return [Vector3(21.0,h,1.5), Vector3(21.0,h,-1.4)][square_position]
		96:
			return [Vector3(17.7,h,1.5), Vector3(17.7,h,-1.4)][square_position]
		97:
			return [Vector3(14.5,h,1.5), Vector3(14.5,h,-1.4)][square_position]
		98:
			return [Vector3(11.3,h,1.5), Vector3(11.3,h,-1.4)][square_position]
		99:
			return [Vector3(8.0,h,1.5), Vector3(8.0,h,-1.4)][square_position]
		100:
			return [Vector3(5,h,3), Vector3(5,h, 0), Vector3(5,h,-3), Vector3(2.2,h,0)][square_position]
			
		#Initials
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

