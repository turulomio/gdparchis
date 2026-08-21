extends BoardBase
class_name Board8

@onready var BoardNode = $Board if has_node("Board") else null
@onready var Player0 = $Player0 if has_node("Player0") else null
@onready var Player1 = $Player1 if has_node("Player1") else null
@onready var Player2 = $Player2 if has_node("Player2") else null
@onready var Player3 = $Player3 if has_node("Player3") else null
@onready var Player4 = $Player4 if has_node("Player4") else null
@onready var Player5 = $Player5 if has_node("Player5") else null
@onready var Player6 = $Player6 if has_node("Player6") else null
@onready var Player7 = $Player7 if has_node("Player7") else null


func _init():
	self.max_players = 8
	self.camera_top_position = Vector3(0.0, 85.0, 0.0)
	self.camera_top_target = Vector3(0.0, 0.0, 0.001)


var user_calib_data: Dictionary = {}
var user_calib_loaded: bool = false


## Constructs an 8-sided 3D regular octagon board plate and miter-closed frame matching 8-player board texture (parchis8.png / parchis8.svg).
func setup_wooden_frame() -> void:
	# Hide default 4-player square Blender box if present
	var blend = get_node_or_null("Board/BoardBlend")
	if blend:
		blend.visible = false
		
	var board_node = get_node_or_null("Board")
	if not board_node:
		board_node = self
	if not board_node.has_node("WoodenFrame"):
		var wf = Node3D.new()
		wf.name = "WoodenFrame"
		board_node.add_child(wf)
		
	var frame_root = board_node.get_node("WoodenFrame")
	for child in frame_root.get_children():
		child.queue_free()
		
	var board_tex = load("res://images/parchis8.png")
	if not board_tex:
		board_tex = load("res://images/parchis8.svg")
		
	var wood_mat = self.create_wood_material()
	var board_mat = self.create_board_face_material(board_tex)
	
	var rail_height: float = 0.625
	var base_thickness: float = 0.625
	var wall_thickness: float = 2.45
	
	var board_width: float = 80.0
	# Apothem is board_width/2, so circumscribed radius R is apothem / cos(22.5)
	var R: float = board_width / (2.0 * cos(deg_to_rad(22.5)))
	
	# 8 outer vertices of regular octagon plate (in world XZ coordinates)
	var v_poly: Array[Vector2] = []
	for i in range(8):
		var angle_rad = deg_to_rad(i * 45.0 - 22.5)
		v_poly.append(Vector2(cos(angle_rad) * R, sin(angle_rad) * R))
		
	var n_verts = v_poly.size()
	
	# ----------------------------------------------------
	# 1. CREATE THE 8-SIDED 3D OCTAGON BOARD PLATE
	# ----------------------------------------------------
	var y_top: float = 0.0
	var y_bottom: float = -base_thickness
	
	# Surface 0: Top Parchis face (CCW winding order)
	var top_arr = []
	top_arr.resize(Mesh.ARRAY_MAX)
	var t_verts = PackedVector3Array()
	var t_uvs = PackedVector2Array()
	var t_normals = PackedVector3Array()
	var t_indices = PackedInt32Array()
	
	var center_top = Vector3(0, y_top, 0)
	var center_uv = Vector2(0.5, 0.5)
	
	for i in range(n_verts):
		var p1 = v_poly[i]
		var p2 = v_poly[(i + 1) % n_verts]
		var idx_c = t_verts.size()
		
		# Clockwise order viewed from top (+Y) so frontface points UP
		t_verts.append(center_top)
		t_verts.append(Vector3(p1.x, y_top, p1.y))
		t_verts.append(Vector3(p2.x, y_top, p2.y))
		
		t_uvs.append(center_uv)
		t_uvs.append(Vector2(p1.x / board_width + 0.5, p1.y / board_width + 0.5))
		t_uvs.append(Vector2(p2.x / board_width + 0.5, p2.y / board_width + 0.5))
		
		for k in range(3): t_normals.append(Vector3.UP)
		
		t_indices.append(idx_c)
		t_indices.append(idx_c + 1)
		t_indices.append(idx_c + 2)
		
	top_arr[Mesh.ARRAY_VERTEX] = t_verts
	top_arr[Mesh.ARRAY_TEX_UV] = t_uvs
	top_arr[Mesh.ARRAY_NORMAL] = t_normals
	top_arr[Mesh.ARRAY_INDEX] = t_indices
	
	# Surface 1: Bottom and side wood faces of 8-sided plate
	var bot_arr = []
	bot_arr.resize(Mesh.ARRAY_MAX)
	var b_verts = PackedVector3Array()
	var b_uvs = PackedVector2Array()
	var b_normals = PackedVector3Array()
	var b_indices = PackedInt32Array()
	
	var center_bottom = Vector3(0, y_bottom, 0)
	
	for i in range(n_verts):
		var p1 = v_poly[i]
		var p2 = v_poly[(i + 1) % n_verts]
		var idx_c = b_verts.size()
		
		b_verts.append(center_bottom)
		b_verts.append(Vector3(p1.x, y_bottom, p1.y))
		b_verts.append(Vector3(p2.x, y_bottom, p2.y))
		
		b_uvs.append(Vector2(0.5, 0.5))
		b_uvs.append(Vector2(p1.x / board_width + 0.5, p1.y / board_width + 0.5))
		b_uvs.append(Vector2(p2.x / board_width + 0.5, p2.y / board_width + 0.5))
		
		for k in range(3): b_normals.append(Vector3.DOWN)
		
		b_indices.append(idx_c)
		b_indices.append(idx_c + 1)
		b_indices.append(idx_c + 2)
		
	for i in range(n_verts):
		var p1 = v_poly[i]
		var p2 = v_poly[(i + 1) % n_verts]
		var edge = (p2 - p1).normalized()
		var side_norm = Vector3(edge.y, 0, -edge.x).normalized()
		
		var t1 = Vector3(p1.x, y_top, p1.y)
		var t2 = Vector3(p2.x, y_top, p2.y)
		var b1 = Vector3(p1.x, y_bottom, p1.y)
		var b2 = Vector3(p2.x, y_bottom, p2.y)
		
		var idx_c = b_verts.size()
		b_verts.append(t1); b_verts.append(b1); b_verts.append(b2); b_verts.append(t2)
		b_uvs.append(Vector2(0, 0)); b_uvs.append(Vector2(0, 1)); b_uvs.append(Vector2(1, 1)); b_uvs.append(Vector2(1, 0))
		for k in range(4): b_normals.append(side_norm)
		
		b_indices.append(idx_c); b_indices.append(idx_c + 1); b_indices.append(idx_c + 2)
		b_indices.append(idx_c); b_indices.append(idx_c + 2); b_indices.append(idx_c + 3)
		
	bot_arr[Mesh.ARRAY_VERTEX] = b_verts
	bot_arr[Mesh.ARRAY_TEX_UV] = b_uvs
	bot_arr[Mesh.ARRAY_NORMAL] = b_normals
	bot_arr[Mesh.ARRAY_INDEX] = b_indices
	
	var base_mesh = ArrayMesh.new()
	base_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, top_arr)
	base_mesh.surface_set_material(0, board_mat)
	
	base_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, bot_arr)
	base_mesh.surface_set_material(1, wood_mat)
	
	var plate_inst = MeshInstance3D.new()
	plate_inst.name = "BoardPlate"
	plate_inst.mesh = base_mesh
	frame_root.add_child(plate_inst)
	
	# ----------------------------------------------------
	# 2. CREATE 8 MITER-CLOSED OUTER WOODEN FRAME WALLS
	# ----------------------------------------------------
	var v_outer: Array[Vector2] = []
	v_outer.resize(n_verts)
	
	for i in range(n_verts):
		var prev_p = v_poly[(i - 1 + n_verts) % n_verts]
		var curr_p = v_poly[i]
		var next_p = v_poly[(i + 1) % n_verts]
		
		var e_prev = (curr_p - prev_p).normalized()
		var e_next = (next_p - curr_p).normalized()
		
		var n_prev = Vector2(e_prev.y, -e_prev.x).normalized()
		var n_next = Vector2(e_next.y, -e_next.x).normalized()
		
		var bisector = (n_prev + n_next).normalized()
		var dot = bisector.dot(n_next)
		var miter_len = wall_thickness / max(dot, 0.2)
		
		v_outer[i] = curr_p + bisector * miter_len
		
	var rail_y_top = rail_height
	var rail_y_bot = 0.0
	
	for i in range(n_verts):
		var p1_in = v_poly[i]
		var p2_in = v_poly[(i + 1) % n_verts]
		var p1_out = v_outer[i]
		var p2_out = v_outer[(i + 1) % n_verts]
		
		var wall_arr = []
		wall_arr.resize(Mesh.ARRAY_MAX)
		
		var w_verts = PackedVector3Array()
		var w_uvs = PackedVector2Array()
		var w_normals = PackedVector3Array()
		var w_indices = PackedInt32Array()
		
		var in_bot_1 = Vector3(p1_in.x, rail_y_bot, p1_in.y)
		var in_bot_2 = Vector3(p2_in.x, rail_y_bot, p2_in.y)
		var in_top_1 = Vector3(p1_in.x, rail_y_top, p1_in.y)
		var in_top_2 = Vector3(p2_in.x, rail_y_top, p2_in.y)
		
		var out_bot_1 = Vector3(p1_out.x, rail_y_bot, p1_out.y)
		var out_bot_2 = Vector3(p2_out.x, rail_y_bot, p2_out.y)
		var out_top_1 = Vector3(p1_out.x, rail_y_top, p1_out.y)
		var out_top_2 = Vector3(p2_out.x, rail_y_top, p2_out.y)
		
		var c_idx = w_verts.size()
		w_verts.append(in_top_1); w_verts.append(out_top_1); w_verts.append(out_top_2); w_verts.append(in_top_2)
		for k in range(4): w_normals.append(Vector3.UP)
		w_uvs.append(Vector2(0,0)); w_uvs.append(Vector2(0,1)); w_uvs.append(Vector2(1,1)); w_uvs.append(Vector2(1,0))
		w_indices.append(c_idx); w_indices.append(c_idx+1); w_indices.append(c_idx+2)
		w_indices.append(c_idx); w_indices.append(c_idx+2); w_indices.append(c_idx+3)
		
		var edge_out = (p2_out - p1_out).normalized()
		var out_norm = Vector3(edge_out.y, 0, -edge_out.x).normalized()
		c_idx = w_verts.size()
		w_verts.append(out_top_1); w_verts.append(out_bot_1); w_verts.append(out_bot_2); w_verts.append(out_top_2)
		for k in range(4): w_normals.append(out_norm)
		w_uvs.append(Vector2(0,0)); w_uvs.append(Vector2(0,1)); w_uvs.append(Vector2(1,1)); w_uvs.append(Vector2(1,0))
		w_indices.append(c_idx); w_indices.append(c_idx+1); w_indices.append(c_idx+2)
		w_indices.append(c_idx); w_indices.append(c_idx+2); w_indices.append(c_idx+3)
		
		var in_norm = -out_norm
		c_idx = w_verts.size()
		w_verts.append(in_top_2); w_verts.append(in_bot_2); w_verts.append(in_bot_1); w_verts.append(in_top_1)
		for k in range(4): w_normals.append(in_norm)
		w_uvs.append(Vector2(0,0)); w_uvs.append(Vector2(0,1)); w_uvs.append(Vector2(1,1)); w_uvs.append(Vector2(1,0))
		w_indices.append(c_idx); w_indices.append(c_idx+1); w_indices.append(c_idx+2)
		w_indices.append(c_idx); w_indices.append(c_idx+2); w_indices.append(c_idx+3)

		wall_arr[Mesh.ARRAY_VERTEX] = w_verts
		wall_arr[Mesh.ARRAY_TEX_UV] = w_uvs
		wall_arr[Mesh.ARRAY_NORMAL] = w_normals
		wall_arr[Mesh.ARRAY_INDEX] = w_indices
		
		var w_mesh = ArrayMesh.new()
		w_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, wall_arr)
		w_mesh.surface_set_material(0, wood_mat)
		
		var wall_inst = MeshInstance3D.new()
		wall_inst.name = "FrameWall_" + str(i)
		wall_inst.mesh = w_mesh
		frame_root.add_child(wall_inst)


## Configures materials and texture for 8-player board.
func setup_board_materials() -> void:
	self.setup_wooden_frame()
	super.setup_board_materials()


## Returns custom piece scale (0.1 to 1.0) for square and slot.
func get_piece_scale(square_id: int, square_position: int) -> float:
	if not user_calib_loaded:
		load_user_calibration()
	var key_str = "%d_%d" % [square_id, square_position]
	if user_calib_data.has(key_str):
		var d = user_calib_data[key_str]
		if d is Dictionary and d.has("scale"):
			return float(d["scale"])
	return 0.75


## Loads calibrated position overrides from res://scenes/board8_calibrated_positions.json if present.
func load_user_calibration() -> void:
	var path = "res://scenes/board8_calibrated_positions.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json_data = JSON.parse_string(file.get_as_text())
			if json_data is Dictionary:
				user_calib_data = json_data
			file.close()
	user_calib_loaded = true


## Specialized 3D position calculator for 8-player board geometry.
func get_position3d(square_id: int, square_position: int, h: float = 0.2) -> Vector3:
	if not user_calib_loaded:
		load_user_calibration()
		
	var key_str = "%d_%d" % [square_id, square_position]
	if user_calib_data.has(key_str):
		var d = user_calib_data[key_str]
		if d is Dictionary and d.has("x") and d.has("z"):
			return Vector3(float(d["x"]), h, float(d["z"]))

	return Vector3(0, h, 0)


## Returns max slots per square (4 for goal triangles & home houses, 2 for arm squares).
func get_max_slots(sq_id: int) -> int:
	var goal_and_home_sqs = [144, 152, 160, 168, 176, 184, 192, 200, 201, 202, 203, 204, 205, 206, 207, 208]
	return 4 if sq_id in goal_and_home_sqs else 2


## Populates and configures squares dictionary for 8-player board geometry.
func setup_squares() -> void:
	self.squares = {}
	for i in range(1, 201):
		self.squares[i] = Square.new(i, Globals.eSquareTypes.NORMAL)
	for i in range(201, 209):
		self.squares[i] = Square.new(i, Globals.eSquareTypes.START)

	# Salidas (FIRST)
	self.squares[5].type = Globals.eSquareTypes.FIRST
	self.squares[5].color = Color.YELLOW
	self.squares[22].type = Globals.eSquareTypes.FIRST
	self.squares[22].color = Color.BLUE
	self.squares[39].type = Globals.eSquareTypes.FIRST
	self.squares[39].color = Globals.ePlayer2Color(2)
	self.squares[56].type = Globals.eSquareTypes.FIRST
	self.squares[56].color = Globals.ePlayer2Color(3)
	self.squares[73].type = Globals.eSquareTypes.FIRST
	self.squares[73].color = Globals.ePlayer2Color(4)
	self.squares[90].type = Globals.eSquareTypes.FIRST
	self.squares[90].color = Globals.ePlayer2Color(5)
	self.squares[107].type = Globals.eSquareTypes.FIRST
	self.squares[107].color = Globals.ePlayer2Color(6)
	self.squares[124].type = Globals.eSquareTypes.FIRST
	self.squares[124].color = Globals.ePlayer2Color(7)

	# Corner Safe Squares (SECURE)
	for sq_id in [12, 29, 46, 63, 80, 97, 114, 131]:
		self.squares[sq_id].type = Globals.eSquareTypes.SECURE

	# Goals (END)
	self.squares[144].type = Globals.eSquareTypes.END
	self.squares[144].color = Color.YELLOW
	self.squares[152].type = Globals.eSquareTypes.END
	self.squares[152].color = Color.BLUE
	self.squares[160].type = Globals.eSquareTypes.END
	self.squares[160].color = Globals.ePlayer2Color(2)
	self.squares[168].type = Globals.eSquareTypes.END
	self.squares[168].color = Globals.ePlayer2Color(3)
	self.squares[176].type = Globals.eSquareTypes.END
	self.squares[176].color = Globals.ePlayer2Color(4)
	self.squares[184].type = Globals.eSquareTypes.END
	self.squares[184].color = Globals.ePlayer2Color(5)
	self.squares[192].type = Globals.eSquareTypes.END
	self.squares[192].color = Globals.ePlayer2Color(6)
	self.squares[200].type = Globals.eSquareTypes.END
	self.squares[200].color = Globals.ePlayer2Color(7)

	# Homes (START)
	self.squares[201].color = Color.YELLOW
	self.squares[202].color = Color.BLUE
	self.squares[203].color = Globals.ePlayer2Color(2)
	self.squares[204].color = Globals.ePlayer2Color(3)
	self.squares[205].color = Globals.ePlayer2Color(4)
	self.squares[206].color = Globals.ePlayer2Color(5)
	self.squares[207].color = Globals.ePlayer2Color(6)
	self.squares[208].color = Globals.ePlayer2Color(7)
