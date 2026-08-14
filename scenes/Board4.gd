extends Node3D
class_name Board4

@onready var Board = $Board
@onready var Player0 = $Player0
@onready var Player1 = $Player1
@onready var Player2 = $Player2
@onready var Player3 = $Player3

var squares
var max_players: int = 4
var show_pieces


## Node ready lifecycle callback.
func _ready():
	self.setup_board_materials()


## Recursively finds all MeshInstance3D nodes under a parent node.
## @param parent Node to search.
## @return Array of MeshInstance3D nodes.
func _find_all_mesh_instances(parent: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	if parent is MeshInstance3D:
		result.append(parent)
	for child in parent.get_children():
		result.append_array(_find_all_mesh_instances(child))
	return result


## Configures all mesh instances and materials of Board.blend and WoodenFrame so they receive lighting and shadows properly.
func setup_board_materials() -> void:
	if not $Board.has_node("BoardBlend"):
		return
		
	self.setup_wooden_frame()
	
	var meshes = _find_all_mesh_instances($Board)
	for mesh_inst in meshes:
		# Step 1: Force layer 1 and enable shadow casting/receiving
		mesh_inst.layers = 1
		mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		
		var surface_count = 1
		if mesh_inst.mesh:
			surface_count = mesh_inst.mesh.get_surface_count()
			
		# Step 2: Ensure all surface materials are shaded (PER_PIXEL) and respond to light and shadow
		for s_idx in range(surface_count):
			var orig_mat = mesh_inst.get_active_material(s_idx)
			if orig_mat:
				var mat = orig_mat.duplicate()
				if mat is StandardMaterial3D or mat is ORMMaterial3D:
					mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
					mat.emission_enabled = false
					mat.roughness = clamp(mat.roughness, 0.35, 0.7)
					mat.metallic_specular = 0.5
					mesh_inst.set_surface_override_material(s_idx, mat)


## Constructs a wooden frame surrounding the board on its sides and underneath with wood texture.
func setup_wooden_frame() -> void:
	if not $Board.has_node("WoodenFrame"):
		var wf = Node3D.new()
		wf.name = "WoodenFrame"
		$Board.add_child(wf)
		
	var frame_root = $Board/WoodenFrame
	# Clear existing children to avoid duplicates
	for child in frame_root.get_children():
		child.queue_free()
		
	var wood_tex = load("res://images/wood.png")
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.8, 0.8, 1.0)
	mat.albedo_texture = wood_tex
	mat.roughness = 0.45
	mat.uv1_scale = Vector3(4, 4, 4)
	
	# Height = 0.625 (1/4 of original 2.5 height)
	var rail_height: float = 0.625
	var base_thickness: float = 0.625
	
	# Bottom frame base under board
	var bottom_mesh = BoxMesh.new()
	bottom_mesh.material = mat
	bottom_mesh.size = Vector3(72.0, base_thickness, 72.0)
	
	var frame_bottom = MeshInstance3D.new()
	frame_bottom.name = "FrameBottom"
	frame_bottom.mesh = bottom_mesh
	frame_bottom.position = Vector3(0.0, -base_thickness / 2.0 - 0.1, 0.0)
	frame_root.add_child(frame_bottom)
	
	# 4 Clean rectangular side rails around borders
	var mesh_long = BoxMesh.new()
	mesh_long.material = mat
	mesh_long.size = Vector3(72.0, rail_height, 3.5)
	
	var mesh_short = BoxMesh.new()
	mesh_short.material = mat
	mesh_short.size = Vector3(3.5, rail_height, 65.0)
	
	var rail_y_pos = rail_height / 2.0 - 0.1
	
	# North Rail
	var fn = MeshInstance3D.new()
	fn.name = "FrameWallNorth"
	fn.mesh = mesh_long
	fn.position = Vector3(0.0, rail_y_pos, -34.25)
	frame_root.add_child(fn)
	
	# South Rail
	var fs = MeshInstance3D.new()
	fs.name = "FrameWallSouth"
	fs.mesh = mesh_long
	fs.position = Vector3(0.0, rail_y_pos, 34.25)
	frame_root.add_child(fs)
	
	# West Rail
	var fw = MeshInstance3D.new()
	fw.name = "FrameWallWest"
	fw.mesh = mesh_short
	fw.position = Vector3(-34.25, rail_y_pos, 0.0)
	frame_root.add_child(fw)
	
	# East Rail
	var fe = MeshInstance3D.new()
	fe.name = "FrameWallEast"
	fe.mesh = mesh_short
	fe.position = Vector3(34.25, rail_y_pos, 0.0)
	frame_root.add_child(fe)


## Initializes the 4-player board, squares dictionary, routes, and initial piece positions.
## @param _show_pieces Boolean indicating whether piece visual meshes should be visible.
func initialize(_show_pieces):
	self.show_pieces = _show_pieces
	self.setup_board_materials()
	
	# Instantiate all 104 board squares into dictionary indexed by ID
	self.squares = {}
	for i in range(1, 105):
		self.squares[i] = Square.new(i)

	# Initialize players, assign routes, and place pieces on final home squares
	for player in self.players():
		player.initialize(self.show_pieces)
		player.set_route(Route.new(self.max_players, player.id, self.squares))
		
		# Set piece starting positions on home route end
		var square_position = 0
		for piece in player.pieces():
			piece.set_final_position(player.route().end_position(), square_position, player.route().square_at(player.route().end_position()).id)
			square_position += 1


## Sets piece visibility state.
## @param value Boolean visibility flag.
func set_show_pieces(value):
	show_pieces = value


## Returns an array of all Player child nodes.
## @return Array of Player objects.
func players() -> Array[Player]:
	var r: Array[Player] = []
	for children in self.get_children():
		if children is Player:
			r.append(children)
	return r


## Returns an array of active players participating in the current game.
## @return Array of participating Player objects.
func players_than_plays() -> Array[Player]:
	var r: Array[Player] = []
	for player in self.players():
		if player.plays:
			r.append(player)
	return r


## Finds and returns a Player object by numeric ID.
## @param id Player ID integer (0-3).
## @return Player object or null.
func get_player_by_id(id):
	for player in self.players():
		if player.id == id:
			return player
	print("NO SE HA ENCONTRADO PLAYER", id)
	return null


## Finds and returns a Piece object matching player ID and piece sub-ID.
## @param player_id Owner player ID.
## @param piece_id Sub-index piece ID (0-3).
## @return Piece object or null.
func get_piece_by_player_id_and_id(player_id, piece_id):
	for player in self.players():
		if player.id == player_id:
			for piece in player.pieces():
				if piece.id == piece_id:
					return piece
	print("NO SE HA ENCONTRADO PIEZA", player_id, piece_id)
	return null
