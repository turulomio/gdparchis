extends BoardBase
class_name Board3

@onready var BoardNode = $Board if has_node("Board") else null
@onready var Player0 = $Player0 if has_node("Player0") else null
@onready var Player1 = $Player1 if has_node("Player1") else null
@onready var Player2 = $Player2 if has_node("Player2") else null


func _init():
	self.max_players = 3


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
