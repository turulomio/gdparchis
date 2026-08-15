extends BoardBase
class_name Board6

@onready var BoardNode = $Board if has_node("Board") else null
@onready var Player0 = $Player0 if has_node("Player0") else null
@onready var Player1 = $Player1 if has_node("Player1") else null
@onready var Player2 = $Player2 if has_node("Player2") else null
@onready var Player3 = $Player3 if has_node("Player3") else null
@onready var Player4 = $Player4 if has_node("Player4") else null
@onready var Player5 = $Player5 if has_node("Player5") else null


func _init():
	self.max_players = 6


var user_calib_data: Dictionary = {}
var user_calib_loaded: bool = false


## Constructs a 6-sided 3D regular hexagon board plate and miter-closed frame matching the 6-player board texture (parchis6.png).
func setup_wooden_frame() -> void:
	# Hide default 4-player square Blender box if present
	var blend = get_node_or_null("Board/BoardBlend")
	if blend:
		blend.visible = false
		
	var board_node = self
	if not board_node.has_node("WoodenFrame"):
		var wf = Node3D.new()
		wf.name = "WoodenFrame"
		board_node.add_child(wf)
		
	var frame_root = board_node.get_node("WoodenFrame")
	for child in frame_root.get_children():
		child.queue_free()
		
	var wood_tex = load("res://images/wood.png")
	var board_tex = load("res://images/parchis6.png")
	if not board_tex:
		board_tex = load("res://images/parchis6.svg")
		
	var wood_mat = StandardMaterial3D.new()
	wood_mat.albedo_color = Color(0.8, 0.8, 0.8, 1.0)
	wood_mat.albedo_texture = wood_tex
	wood_mat.roughness = 0.45
	wood_mat.uv1_scale = Vector3(4, 4, 4)
	wood_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	wood_mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	
	var board_mat = StandardMaterial3D.new()
	board_mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	board_mat.albedo_texture = board_tex
	board_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	board_mat.roughness = 1.0
	board_mat.metallic = 0.0
	board_mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	board_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	board_mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	
	var rail_height: float = 0.625
	var base_thickness: float = 0.625
	var wall_thickness: float = 2.45
	
	var board_width: float = 72.0
	var R: float = board_width / 2.0
	var H: float = sqrt(3.0) * R
	var hH: float = H / 2.0

	# 6 outer vertices of regular flat-topped hexagon (in world XZ coordinates)
	var v_poly: Array[Vector2] = [
		Vector2(-R / 2.0, -hH), # V0: Top-Left
		Vector2(R / 2.0, -hH),  # V1: Top-Right
		Vector2(R, 0.0),        # V2: Right Corner
		Vector2(R / 2.0, hH),   # V3: Bottom-Right
		Vector2(-R / 2.0, hH),  # V4: Bottom-Left
		Vector2(-R, 0.0)        # V5: Left Corner
	]
	var n_verts = v_poly.size()
	
	# ----------------------------------------------------
	# 1. CREATE THE 6-SIDED 3D HEXAGON BOARD PLATE (TOP FACE = PARCHIS6, SIDES/BOTTOM = WOOD)
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
		
		# CCW order viewed from top (+Y)
		t_verts.append(center_top)
		t_verts.append(Vector3(p2.x, y_top, p2.y))
		t_verts.append(Vector3(p1.x, y_top, p1.y))
		
		t_uvs.append(center_uv)
		t_uvs.append(Vector2(p2.x / board_width + 0.5, p2.y / H + 0.5))
		t_uvs.append(Vector2(p1.x / board_width + 0.5, p1.y / H + 0.5))
		
		for k in range(3): t_normals.append(Vector3.UP)
		
		t_indices.append(idx_c)
		t_indices.append(idx_c + 1)
		t_indices.append(idx_c + 2)
		
	top_arr[Mesh.ARRAY_VERTEX] = t_verts
	top_arr[Mesh.ARRAY_TEX_UV] = t_uvs
	top_arr[Mesh.ARRAY_NORMAL] = t_normals
	top_arr[Mesh.ARRAY_INDEX] = t_indices
	
	# Surface 1: Bottom and side wood faces of 6-sided plate
	var bot_arr = []
	bot_arr.resize(Mesh.ARRAY_MAX)
	var b_verts = PackedVector3Array()
	var b_uvs = PackedVector2Array()
	var b_normals = PackedVector3Array()
	var b_indices = PackedInt32Array()
	
	var center_bottom = Vector3(0, y_bottom, 0)
	
	# Bottom face (CCW viewed from bottom -Y)
	for i in range(n_verts):
		var p1 = v_poly[i]
		var p2 = v_poly[(i + 1) % n_verts]
		var idx_c = b_verts.size()
		
		b_verts.append(center_bottom)
		b_verts.append(Vector3(p1.x, y_bottom, p1.y))
		b_verts.append(Vector3(p2.x, y_bottom, p2.y))
		
		b_uvs.append(Vector2(0.5, 0.5))
		b_uvs.append(Vector2(p1.x / board_width + 0.5, p1.y / H + 0.5))
		b_uvs.append(Vector2(p2.x / board_width + 0.5, p2.y / H + 0.5))
		
		for k in range(3): b_normals.append(Vector3.DOWN)
		
		b_indices.append(idx_c)
		b_indices.append(idx_c + 1)
		b_indices.append(idx_c + 2)
		
	# Side quad faces connecting top & bottom edges
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
	# 2. CREATE 6 MITER-CLOSED OUTER WOODEN FRAME WALLS (CLOSED CORNERS)
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
		
		# Top rail face (CCW)
		var c_idx = w_verts.size()
		w_verts.append(in_top_1); w_verts.append(out_top_1); w_verts.append(out_top_2); w_verts.append(in_top_2)
		for k in range(4): w_normals.append(Vector3.UP)
		w_uvs.append(Vector2(0,0)); w_uvs.append(Vector2(0,1)); w_uvs.append(Vector2(1,1)); w_uvs.append(Vector2(1,0))
		w_indices.append(c_idx); w_indices.append(c_idx+1); w_indices.append(c_idx+2)
		w_indices.append(c_idx); w_indices.append(c_idx+2); w_indices.append(c_idx+3)
		
		# Outer face (CCW)
		var edge_out = (p2_out - p1_out).normalized()
		var out_norm = Vector3(edge_out.y, 0, -edge_out.x).normalized()
		c_idx = w_verts.size()
		w_verts.append(out_top_1); w_verts.append(out_bot_1); w_verts.append(out_bot_2); w_verts.append(out_top_2)
		for k in range(4): w_normals.append(out_norm)
		w_uvs.append(Vector2(0,0)); w_uvs.append(Vector2(0,1)); w_uvs.append(Vector2(1,1)); w_uvs.append(Vector2(1,0))
		w_indices.append(c_idx); w_indices.append(c_idx+1); w_indices.append(c_idx+2)
		w_indices.append(c_idx); w_indices.append(c_idx+2); w_indices.append(c_idx+3)
		
		# Inner face (CCW)
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


## Configures materials and texture for 6-player board.
func setup_board_materials() -> void:
	setup_wooden_frame()
	var blend = get_node_or_null("Board/BoardBlend")
	if blend:
		blend.visible = false



## Returns the custom calibrated piece scale (0.1 to 1.0) for a target square and slot.
func get_piece_scale(square_id: int, square_position: int) -> float:
	if not user_calib_loaded:
		load_user_calibration()
	var key_str = "%d_%d" % [square_id, square_position]
	if user_calib_data.has(key_str):
		var d = user_calib_data[key_str]
		if d is Dictionary and d.has("scale"):
			return float(d["scale"])
	return 0.75


## Loads calibrated position overrides from res://scenes/board6_calibrated_positions.json if present in the project.
func load_user_calibration() -> void:
	var path = "res://scenes/board6_calibrated_positions.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json_data = JSON.parse_string(file.get_as_text())
			if json_data is Dictionary:
				user_calib_data = json_data
			file.close()
	user_calib_loaded = true


## Specialized 3D position calculator for 6-player board geometry loaded directly from JSON calibration file.
func get_position3d(square_id: int, square_position: int, h: float = 0.2) -> Vector3:
	if not user_calib_loaded:
		load_user_calibration()
		
	var key_str = "%d_%d" % [square_id, square_position]
	if user_calib_data.has(key_str):
		var d = user_calib_data[key_str]
		if d is Dictionary and d.has("x") and d.has("z"):
			return Vector3(float(d["x"]), h, float(d["z"]))

	return Vector3(0, h, 0)
