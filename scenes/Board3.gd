extends BoardBase
class_name Board3

@onready var BoardNode = $Board if has_node("Board") else null
@onready var Player0 = $Player0 if has_node("Player0") else null
@onready var Player1 = $Player1 if has_node("Player1") else null
@onready var Player2 = $Player2 if has_node("Player2") else null


func _init():
	self.max_players = 3


## Constructs a 6-sided wooden frame adapted to the 3-player board geometry.
func setup_wooden_frame() -> void:
	var board_node = get_node_or_null("Board")
	if not board_node:
		return
		
	if not board_node.has_node("WoodenFrame"):
		var wf = Node3D.new()
		wf.name = "WoodenFrame"
		board_node.add_child(wf)
		
	var frame_root = board_node.get_node("WoodenFrame")
	for child in frame_root.get_children():
		child.queue_free()
		
	var wood_tex = load("res://images/wood.png")
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.8, 0.8, 1.0)
	mat.albedo_texture = wood_tex
	mat.roughness = 0.45
	mat.uv1_scale = Vector3(4, 4, 4)
	
	var rail_height: float = 0.625
	var base_thickness: float = 0.625
	
	# 6-sided hexagonal base platform
	var bottom_mesh = CylinderMesh.new()
	bottom_mesh.material = mat
	bottom_mesh.top_radius = 35.0
	bottom_mesh.bottom_radius = 35.0
	bottom_mesh.height = base_thickness
	bottom_mesh.radial_segments = 6
	
	var frame_bottom = MeshInstance3D.new()
	frame_bottom.name = "FrameBottom"
	frame_bottom.mesh = bottom_mesh
	frame_bottom.position = Vector3(0.0, -base_thickness / 2.0 - 0.1, 0.0)
	frame_bottom.rotation_degrees = Vector3(0, 30, 0)
	frame_root.add_child(frame_bottom)
	
	# The 6 outer walls of the 3-player hexagonal board (rotated at 60-degree intervals)
	var radius: float = 34.25
	var wall_length: float = 37.5
	var wall_thickness: float = 3.5
	
	for i in range(6):
		var angle_deg = i * 60.0
		var angle_rad = deg_to_rad(angle_deg)
		
		var wall_mesh = BoxMesh.new()
		wall_mesh.material = mat
		wall_mesh.size = Vector3(wall_length, rail_height, wall_thickness)
		
		var wall_inst = MeshInstance3D.new()
		wall_inst.name = "FrameWall_" + str(i)
		wall_inst.mesh = wall_mesh
		
		var pos_x = radius * sin(angle_rad)
		var pos_z = -radius * cos(angle_rad)
		wall_inst.position = Vector3(pos_x, rail_height / 2.0 - 0.1, pos_z)
		wall_inst.rotation_degrees = Vector3(0, angle_deg, 0)
		
		frame_root.add_child(wall_inst)


## Configures materials and texture for 3-player board.
func setup_board_materials() -> void:
	super.setup_board_materials()
	var board_node = get_node_or_null("Board")
	if not board_node:
		return
		
	var tex = load("res://images/parchis3.png")
	if not tex:
		tex = load("res://images/parchis3.svg")
		
	var meshes = _find_all_mesh_instances(board_node)
	for mesh_inst in meshes:
		if "WoodenFrame" in str(mesh_inst.get_path()):
			continue
		if mesh_inst.mesh:
			for s_idx in range(mesh_inst.mesh.get_surface_count()):
				var orig_mat = mesh_inst.get_surface_override_material(s_idx)
				if not orig_mat:
					orig_mat = mesh_inst.get_active_material(s_idx)
				if not orig_mat and mesh_inst.mesh:
					orig_mat = mesh_inst.mesh.surface_get_material(s_idx)
					
				var mat_name = ""
				if orig_mat:
					mat_name = orig_mat.resource_name
					
				if s_idx == 0 or mat_name == "Parchis":
					var mat_dup: StandardMaterial3D
					if orig_mat is StandardMaterial3D or orig_mat is ORMMaterial3D:
						mat_dup = orig_mat.duplicate()
					else:
						mat_dup = StandardMaterial3D.new()
					mat_dup.albedo_texture = tex
					mesh_inst.set_surface_override_material(s_idx, mat_dup)


## Specialized 3D position calculator for 3-player board geometry.
func get_position3d(square_id: int, square_position: int, h: float = 0.2) -> Vector3:
	return Globals.position3(square_id, square_position, h)
