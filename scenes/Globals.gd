extends Node 
const VERSION="0.9.99"
const VERSION_DATE="2024-05-12"

enum eSquareTypes {START, FIRST, NORMAL, SECURE, RAMP, END}
enum ePlayer {YELLOW, BLUE, RED, GREEN}  # 0,1,2,3
enum eDifficulty {EASY,NORMAL,DIFFICULT}
enum eLanguages {ENGLISH,SPANISH,FRENCH}
const UUID_UTIL = preload('res://scenes/uuid.gd')
const IMAGE_WOOD = preload("res://images/wood.png")
const SCENE_PLAYER_OPTIONS=preload("res://scenes/PlayerOptions.tscn")

var game_data = null # Dictionary to load and init games
var settings
var from_dice_start: bool = false
var game_history: Array = []


## Singleton initialization callback. Loads saved configuration settings and game history.
func _init():
	print("Singleton load")
	if not DirAccess.dir_exists_absolute("user://saves/"):
		DirAccess.make_dir_absolute("user://saves/")
	load_settings()
	load_game_history()


## Loads match history records from user://game_history.json file.
func load_game_history() -> void:
	if not FileAccess.file_exists("user://game_history.json"):
		self.game_history = []
		return
		
	var file_load = FileAccess.open("user://game_history.json", FileAccess.READ)
	if file_load:
		var json_string = file_load.get_as_text()
		file_load.close()
		var parsed = JSON.parse_string(json_string)
		if parsed is Array:
			self.game_history = parsed
		else:
			self.game_history = []


## Saves match history records to user://game_history.json file.
func save_game_history() -> void:
	var file_save = FileAccess.open("user://game_history.json", FileAccess.WRITE)
	if file_save:
		file_save.store_line(JSON.stringify(self.game_history))
		file_save.close()


## Clears all match history records.
func clear_game_history() -> void:
	self.game_history.clear()
	self.save_game_history()


## Adds a new game record to history log and persists to disk.
## @param start_time Unix timestamp float when game began.
## @param winner Player object that won the game.
## @param board Board4 node instance.
func add_game_history_entry(start_time: float, winner, board) -> void:
	# Calculate elapsed game duration in seconds
	var current_time = Time.get_unix_time_from_system()
	var duration_sec = max(1, int(current_time - start_time))
	var mins = duration_sec / 60
	var secs = duration_sec % 60
	var duration_str = "%02d:%02d" % [mins, secs]
	
	# Format current date and time string
	var datetime_dict = Time.get_datetime_dict_from_system()
	var datetime_str = "%04d-%02d-%02d %02d:%02d" % [datetime_dict.year, datetime_dict.month, datetime_dict.day, datetime_dict.hour, datetime_dict.minute]
	
	# Build player composition snapshot
	var composition = []
	var max_players = 4
	if board != null:
		if "max_players" in board:
			max_players = board.max_players
		for p in board.players():
			composition.append({
				"id": p.id,
				"name": p.playername,
				"color_id": p.id,
				"ia": p.ia,
				"plays": p.plays
			})
			
	var entry = {
		"datetime": datetime_str,
		"duration_sec": duration_sec,
		"duration_str": duration_str,
		"max_players": max_players,
		"winner_name": winner.playername if winner else "Unknown",
		"winner_id": winner.id if winner else 0,
		"winner_ia": winner.ia if winner else false,
		"composition": composition
	}
	
	# Insert newest record at top index 0
	self.game_history.push_front(entry)
	self.save_game_history()


## Maps a numeric player ID (0-3) to its corresponding Godot Color.
## @param player_id Integer ID of the player (0: Yellow, 1: Blue, 2: Red, 3: Green).
## @return Color associated with the player.
func ePlayer2Color(player_id):
	match player_id:
		0:
			return Color.YELLOW
		1:
			return Color.BLUE
		2:
			return Color(0.75, 0, 0, 1) # Darkened RED by additional 10% (total 25%)
		3:
			return Color(0, 0.85, 0, 1) # Darkened GREEN by 15%
		_:
			return Color.WHITE


## Maps a Godot Color back to its numeric player ID (0-3).
## @param color Color object to convert.
## @return Player ID integer or null if unmatched.
func Color2ePlayer(color):
	match color:
		Color.YELLOW:
			return 0
		Color.BLUE:
			return 1
		Color.RED, Color(0.85, 0, 0, 1), Color(0.75, 0, 0, 1):
			return 2
		Color.GREEN, Color(0, 0.85, 0, 1):
			return 3
	return null


## Returns default name for a player according to its enum ID.
## @param player_id ePlayer enum integer.
## @return Default name string.
func ePlayerDefaultName(player_id):
	var r
	match player_id:
		ePlayer.YELLOW:
			r = "Yellowy"
		ePlayer.BLUE:
			r = "Bluey"
		ePlayer.RED:
			r = "Redy"
		ePlayer.GREEN:
			r = "Greeny"
	return r


## Checks whether a 3D vector is within precision threshold of zero.
## @param v Vector3 to test.
## @param precision Maximum allowable deviation magnitude.
## @return True if all components are nearly zero.
func vector_is_almost_zero(v, precision = 0.001):
	if self.value_almost_zero(v.x, precision) and self.value_almost_zero(v.y, precision) and self.value_almost_zero(v.z, precision):
		return true
	return false


## Checks whether a float value is within precision threshold of zero.
## @param _value Float value to test.
## @param precision Maximum allowable deviation magnitude.
## @return True if value is nearly zero.
func value_almost_zero(_value, precision = 0.001):
	if abs(_value) <= precision:
		return true
	return false
	
func save_game(game):
	if not DirAccess.dir_exists_absolute("user://saves/"):
		DirAccess.make_dir_absolute("user://saves/")
				
	# Removes unnecessary autosaves
	var files=[]
	var dir=DirAccess.open("user://saves/")
	if dir:
		dir.list_dir_begin()
		while true:
			var file=dir.get_next()
			if file=="":
				break
			elif "autosave" in file:
				files.append(file)
		dir.list_dir_end()
		files.sort()
		if files.size() >= self.settings.get("autosaves", 10):
			var to_remove=files.slice(0, files.size() - self.settings.get("autosaves", 10) + 1)
			for f in to_remove:
				dir.remove("user://saves/"+f)
		
	# Create new autosave
	var d=Time.get_datetime_dict_from_system()
	var filename="%d%s%s %s%s%s autosave %d.save" % [d.year,"%02d" % d.month,"%02d" %d.day,"%02d" %d.hour,"%02d" %d.minute, "%02d" %d.second, game.board().max_players]
	var file_new=FileAccess.open("user://saves/" + filename, FileAccess.WRITE)
	if file_new:
		var dict={}	
		dict["max_players"]=game.board().max_players
		dict["current"]=game.current_player.id
		dict["fake_dice"]=[]
		dict["players"]=[]
		dict["game_uuid"]=self.game_data.game_uuid
		for p in game.board().players():
			var dict_p={}
			dict_p["id"]=p.id
			dict_p["playername"]=p.playername
			dict_p["plays"]=p.plays
			dict_p["ia"]=p.ia
			dict["players"].append(dict_p)
			dict_p["pieces"]=[]
			for piece in p.pieces():
				var dict_piece={}
				dict_piece["id"]=piece.id
				dict_piece["route_position"]=piece.route_position
				dict_piece["square_position"]=piece.square_position
				dict_p["pieces"].append(dict_piece)
		file_new.store_line(JSON.stringify(dict))
		file_new.close()
		print("Autosave created: ", filename)
	
func new_game(max_players):
	var dict={}
	dict["max_players"]=max_players
	dict["current"]=0
	dict["fake_dice"]=[]
	dict["players"]=[]
	dict["game_uuid"]=generate_uuid()
	for player_id in range(max_players):
		var dict_p={}
		dict_p["id"]=player_id
		dict_p["playername"]=ePlayerDefaultName(player_id)
		dict_p["plays"]=true
		if player_id==0:
			dict_p["ia"]=false
		else:
			dict_p["ia"]=true
		dict["players"].append(dict_p)
		dict_p["pieces"]=[]
		for i in range(4):
			var dict_piece={}
			dict_piece["id"]=i
			dict_piece["route_position"]=0
			dict_piece["square_position"]=i
			dict_p["pieces"].append(dict_piece)
	return dict
	
func load_game(filename):
	
	var file=FileAccess.open(filename, FileAccess.READ)
	var data=JSON.parse_string(file.get_line())
	file.close()
	return data
	
	
func save_settings():
	var file= FileAccess.open("user://gdparchis.cfg", FileAccess.WRITE)
	file.store_line(JSON.stringify(settings))
	file.close()
	print("Settings saved: ", settings)
	
func load_settings():
	if FileAccess.file_exists("user://gdparchis.cfg")==false:
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
		var file_load=FileAccess.open("user://gdparchis.cfg", FileAccess.READ)
		settings=JSON.parse_string(file_load.get_line())
		file_load.close()
		if settings != null and settings is Dictionary:
			if settings.has("autosaves"):
				settings["autosaves"] = int(settings["autosaves"])
			if settings.has("difficulty"):
				settings["difficulty"] = int(settings["difficulty"])
			if settings.has("language"):
				settings["language"] = int(settings["language"])
	
	print("Settings loaded: ", settings)
	set_window_mode_fullscreen(settings["full_screen"])		
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not settings["sound"])
	change_language(settings["language"])


## Toggles master audio sound mute setting, updates settings dictionary, and saves configuration.
## @return New boolean sound state (true if sound is enabled).
func toggle_sound() -> bool:
	# 1. Read current sound setting (default to true if missing)
	var current_sound = settings.get("sound", true)
	var new_sound = not current_sound
	
	# 2. Update settings dictionary and master audio bus mute state
	settings["sound"] = new_sound
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not new_sound)
	
	# 3. Persist updated settings to user disk file
	save_settings()
	return new_sound

func change_language(e_language):
	if e_language==eLanguages.SPANISH:
		TranslationServer.set_locale("es")
	elif e_language==eLanguages.FRENCH:
		TranslationServer.set_locale("fr")
	elif e_language==eLanguages.ENGLISH:
		TranslationServer.set_locale("en")


## Compares two semver-like version strings (e.g. "v1.0.0" and "0.9.99").
## @param latest Target version string from GitHub release API.
## @param current Installed local version string.
## @return True if latest version is strictly newer than current version.
func is_newer_version(latest: String, current: String) -> bool:
	# 1. Clean leading version tags (e.g., 'v', 'gdparchis-') and whitespace
	var clean_latest = latest.strip_edges().lstrip("v").lstrip("gdparchis-")
	var clean_current = current.strip_edges().lstrip("v").lstrip("gdparchis-")
	
	# 2. Split version parts by '.' dot separator
	var parts_latest = clean_latest.split(".")
	var parts_current = clean_current.split(".")
	
	# 3. Compare numeric version components sequentially
	var max_len = max(parts_latest.size(), parts_current.size())
	for i in range(max_len):
		var num_latest = int(parts_latest[i]) if i < parts_latest.size() else 0
		var num_current = int(parts_current[i]) if i < parts_current.size() else 0
		if num_latest > num_current:
			return true
		elif num_latest < num_current:
			return false
			
	return false


func generate_uuid():
	return UUID_UTIL.v4()

## Returns decision probability according to configured difficulty level.
## @return Float probability threshold (0.65 for Easy, 0.80 for Normal, 0.95 for Difficult).
func difficulty_probability():
	if self.settings["difficulty"] == eDifficulty.EASY:
		return 0.65
	elif self.settings["difficulty"] == eDifficulty.NORMAL:
		return 0.80
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
func position4(square_id, square_position, h=0.2):
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

## Loads global game state data into board, players, and piece positions.
## @param gameobject Scene object instance containing a board() method.
## @param show_pieces Boolean flag indicating whether piece visual models should be visible.
## @param animate Optional boolean flag controlling whether piece placement is animated step-by-step.
func game_load_glogals_game_data(gameobject, show_pieces, animate: bool = true):
	# 1. Initialize board squares, players, and default piece properties
	gameobject.board().initialize(show_pieces)
	
	# 2. Loop through each player dictionary stored in global game_data
	for d_player in Globals.game_data.players:
		var player = gameobject.board().get_player_by_id(d_player["id"])
		player.plays = d_player["plays"]
		player.ia = d_player["ia"]		
		player.playername = d_player["playername"]		
		
		# 3. Loop through each piece configuration for active players
		for d_piece in d_player["pieces"]:
			var piece = gameobject.board().get_piece_by_player_id_and_id(player.id, d_piece["id"])
			if show_pieces and player.plays:
				piece.visible = true
				if animate:
					# Animate piece movement along route to target position at 4x speed (0.1s duration vs normal 0.4s)
					piece.move_to_route_position(d_piece["route_position"], 0.1)
					await piece.piece_moved
				else:
					# Directly place piece at target route position without playing hop animations
					var square_final = player.route().square_at(d_piece["route_position"])
					var square_position_final = square_final.empty_position()
					square_final.set_piece_at_square_position(square_position_final, piece)
					piece.set_final_position(d_piece["route_position"], square_position_final, square_final.id)
					piece.change_scale_on_specials_squares()
			else:
				# Hide pieces for non-participating players
				piece.visible = false

		
	## Registering game
	print("Registering game:")	
	var fields = {
		"max_players":Globals.game_data.max_players,
		"num_players": gameobject.board().players_than_plays().size(),
		"installation_uuid": Globals.settings.get("installation_uuid"),
		"game_uuid": Globals.game_data.game_uuid,
		"version": Globals.VERSION,
	}


	print(Globals.game_data)


## Checks if current window display mode is fullscreen.
## @param screen Integer screen monitor index (default 0).
## @return True if window is fullscreen.
func is_window_mode_fullscreen(screen=0):
	if DisplayServer.window_get_mode(screen) == DisplayServer.WINDOW_MODE_FULLSCREEN:
		return true
	return false
	

## Sets window display mode to fullscreen or windowed.
## @param boolean Boolean flag for fullscreen mode.
## @param screen Integer screen monitor index (default 0).
func set_window_mode_fullscreen(boolean, screen=0):
	if boolean:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN, screen)
		settings["full_screen"] = true
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED, screen)
		settings["full_screen"] = false
	save_settings()


## Toggles between fullscreen and windowed display mode.
## @param screen Integer screen monitor index (default 0).
func toggle_window_mode(screen=0):
	if is_window_mode_fullscreen(screen):
		set_window_mode_fullscreen(false, screen)
	else:
		set_window_mode_fullscreen(true, screen)


## Global input event handler capturing shortcut keys across all scenes (e.g. F11 fullscreen).
## @param event InputEvent object.
func _unhandled_input(event: InputEvent) -> void:
	# Toggle window display mode when full_screen action (F11 / F key) is pressed
	if event.is_action_pressed("full_screen"):
		get_viewport().set_input_as_handled()
		self.toggle_window_mode()
