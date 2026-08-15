extends Node3D
class_name BoardCalibrationBase

## Base class for interactive 3D board piece calibration tools.
## Encapsulates common 3D piece dragging, fine keyboard adjustment,
## proportional scaling, selection handling, camera zoom & panning,
## 3D route line path & filled directional arrows visualizer, Undo stack (Ctrl+Z), and JSON persistence.

var board_inst: BoardBase = null
var piece_nodes: Dictionary = {} # Key: Vector2i(sq_id, slot) -> Piece Node3D
var positions_data: Dictionary = {} # Key: String(sq_id_slot) -> Dictionary / Vector3

# Undo Stack (Ctrl+Z)
var undo_stack: Array[Dictionary] = []

var selected_sq_id: int = 1
var selected_slot: int = 0
var selected_piece: Node3D = null

var is_dragging: bool = false
var drag_plane: Plane = Plane(Vector3.UP, 0.2)

# Camera Panning & Zoom Controls
var camera: Camera3D = null
var is_panning: bool = false
var pan_start_mouse: Vector2 = Vector2.ZERO
var pan_start_cam_pos: Vector3 = Vector3.ZERO
var min_cam_y: float = 12.0
var max_cam_y: float = 160.0

# Route Line & Directional Arrow State
var route_mode_active: bool = false
var current_route_player_id: int = 0
var current_route_sq_ids: Array = []
var current_route_slot: int = 0
var route_line_mesh_inst: MeshInstance3D = null

var info_label: Label = null
var selection_ring: MeshInstance3D = null
var scale_combo: OptionButton = null
var route_combo: OptionButton = null

var save_path: String = "res://scenes/board_calibrated_positions.json"


func _ready() -> void:
	print("INITIALIZING BOARD CALIBRATION TOOL BASE: ", get_class())
	
	load_board_instance()
	hide_all_dice()

	camera = find_child("Camera3D", true, false)
	if not camera:
		var cameras = find_children("*", "Camera3D", true, false)
		if not cameras.is_empty():
			camera = cameras[0]
		else:
			camera = Camera3D.new()
			camera.position = Vector3(0, 65, 0)
			camera.rotation_degrees = Vector3(-90, 0, 0)
			add_child(camera)
	if camera:
		camera.make_current()

	load_calibration_file()
	populate_pieces()
	setup_selection_ring()
	setup_ui_overlay()
	select_piece(1, 0)


## Hides all dice nodes on the board for clean calibration viewing.
func hide_all_dice() -> void:
	if not board_inst: return
	
	if board_inst.has_method("players"):
		for player in board_inst.players():
			if player.has_method("dice"):
				var d = player.dice()
				if d:
					d.visible = false

	var all_dice = board_inst.find_children("*", "Dice", true, false)
	for d_node in all_dice:
		d_node.visible = false


## Returns Player color associated with player ID.
func get_player_color(player_id: int) -> Color:
	match player_id:
		0: return Color(1.0, 0.9, 0.1)  # Yellow
		1: return Color(0.2, 0.6, 1.0)  # Blue
		2: return Color(1.0, 0.2, 0.2)  # Red
		3: return Color(0.2, 0.9, 0.3)  # Green
		_: return Color(1.0, 1.0, 1.0)


## Renders a 3D line overlay with filled directional arrows connecting all square centers along the active route.
func update_route_line_visualization() -> void:
	if not route_line_mesh_inst:
		route_line_mesh_inst = MeshInstance3D.new()
		route_line_mesh_inst.name = "RouteLine3D"
		add_child(route_line_mesh_inst)

	if not route_mode_active or current_route_sq_ids.is_empty():
		route_line_mesh_inst.visible = false
		return

	var color = get_player_color(current_route_player_id)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.emission_enabled = true
	mat.emission = color * 1.3
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	var points: Array[Vector3] = []
	for sq_id in current_route_sq_ids:
		var key_str = "%d_%d" % [sq_id, current_route_slot]
		var pos3d = Vector3.ZERO
		if positions_data.has(key_str):
			var d = positions_data[key_str]
			pos3d = Vector3(float(d.get("x", 0)), 0.6, float(d.get("z", 0)))
		elif board_inst:
			pos3d = board_inst.get_position3d(sq_id, current_route_slot, 0.6)
		points.append(pos3d)

	var imm_mesh = ImmediateMesh.new()
	
	# Surface 0: Route line segments
	imm_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, mat)
	for p in points:
		imm_mesh.surface_add_vertex(p)
	imm_mesh.surface_end()

	# Surface 1: Filled directional arrow heads along each segment
	imm_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, mat)
	for i in range(points.size() - 1):
		var p_a = points[i]
		var p_b = points[i + 1]
		var delta_vec = p_b - p_a
		var dist = delta_vec.length()
		if dist < 0.2:
			continue

		var dir = delta_vec / dist
		var perp = Vector3(-dir.z, 0, dir.x)

		# Position arrow head near midpoint of segment
		var mid = p_a + dir * (dist * 0.55)
		var p_tip = mid + dir * 0.7
		var p_left = mid - dir * 0.4 + perp * 0.45
		var p_right = mid - dir * 0.4 - perp * 0.45

		# Top face of filled arrow triangle (CCW)
		imm_mesh.surface_add_vertex(p_tip)
		imm_mesh.surface_add_vertex(p_left)
		imm_mesh.surface_add_vertex(p_right)

		# Bottom face of filled arrow triangle (CW for double-sided visibility)
		imm_mesh.surface_add_vertex(p_tip)
		imm_mesh.surface_add_vertex(p_right)
		imm_mesh.surface_add_vertex(p_left)

	imm_mesh.surface_end()

	route_line_mesh_inst.mesh = imm_mesh
	route_line_mesh_inst.visible = true


## Pushes current calibration dataset snapshot onto Undo stack before performing modifications.
func push_undo_snapshot() -> void:
	var snapshot = positions_data.duplicate(true)
	undo_stack.append(snapshot)
	if undo_stack.size() > 100:
		undo_stack.pop_front()


## Restores previous calibration snapshot from Undo stack (Ctrl+Z).
func perform_undo() -> void:
	if undo_stack.is_empty():
		print("UNDO STACK IS EMPTY")
		return

	var prev_data = undo_stack.pop_back()
	positions_data = prev_data

	for sq_id in get_square_ids():
		var max_slots = get_max_slots(sq_id)
		for slot in range(max_slots):
			var key = Vector2i(sq_id, slot)
			var key_str = "%d_%d" % [sq_id, slot]
			if piece_nodes.has(key) and positions_data.has(key_str):
				var p_node = piece_nodes[key]
				var d = positions_data[key_str]
				if d is Dictionary:
					var px = float(d.get("x", 0))
					var py = float(d.get("y", 0.2))
					var pz = float(d.get("z", 0))
					var sc = float(d.get("scale", 1.0))
					p_node.position = Vector3(px, py, pz)
					p_node.scale = Vector3(sc, sc, sc)

	select_piece(selected_sq_id, selected_slot)
	if route_mode_active:
		update_route_line_visualization()
	save_calibration_file()
	print("UNDO PERFORMED (Ctrl+Z): Restored previous calibration state.")


## Virtual method to load board instance. Must be overridden by subclasses.
func load_board_instance() -> void:
	pass


## Virtual method returning the array of valid square IDs for this board variant.
func get_square_ids() -> Array[int]:
	return []


## Returns maximum piece slots for a given square ID (delegates to board_inst if available).
func get_max_slots(sq_id: int) -> int:
	if board_inst and board_inst.has_method("get_max_slots"):
		return board_inst.get_max_slots(sq_id)
	return 2


## Virtual method returning array of square IDs for a specific player route.
func get_player_route_square_ids(_player_id: int) -> Array:
	return []


## Virtual method returning player color name string.
func get_player_name(_player_id: int) -> String:
	match _player_id:
		0: return "Amarillo"
		1: return "Azul"
		2: return "Rojo"
		3: return "Verde"
		4: return "Gris"
		5: return "Rosa"
		6: return "Naranja"
		7: return "Cyan"
		_: return "Jugador %d" % _player_id


## Populates piece instances on all board squares.
func populate_pieces() -> void:
	var piece_scene = load("res://scenes/Piece.tscn")
	var square_ids = get_square_ids()

	for sq_id in square_ids:
		var max_slots = get_max_slots(sq_id)
		for slot in range(max_slots):
			var key_str = "%d_%d" % [sq_id, slot]
			var pos3d: Vector3 = Vector3.ZERO
			var p_scale: float = 1.0

			if positions_data.has(key_str):
				var data = positions_data[key_str]
				if data is Dictionary:
					pos3d = Vector3(float(data.get("x", 0)), float(data.get("y", 0.2)), float(data.get("z", 0)))
					p_scale = float(data.get("scale", 1.0))
				elif data is Vector3:
					pos3d = data
			else:
				if board_inst:
					pos3d = board_inst.get_position3d(sq_id, slot, 0.2)
				positions_data[key_str] = {"x": pos3d.x, "y": pos3d.y, "z": pos3d.z, "scale": 1.0}

			if piece_scene:
				var p_inst = piece_scene.instantiate()
				p_inst.position = pos3d
				p_inst.scale = Vector3(p_scale, p_scale, p_scale)
				p_inst.set_meta("sq_id", sq_id)
				p_inst.set_meta("slot", slot)
				add_child(p_inst)
				piece_nodes[Vector2i(sq_id, slot)] = p_inst


## Creates visual selection ring mesh instance.
func setup_selection_ring() -> void:
	var ring_mesh = TorusMesh.new()
	ring_mesh.inner_radius = 1.3
	ring_mesh.outer_radius = 1.6
	var ring_mat = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(1.0, 0.85, 0.0, 0.9)
	ring_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	selection_ring = MeshInstance3D.new()
	selection_ring.mesh = ring_mesh
	selection_ring.material_override = ring_mat
	add_child(selection_ring)


## Constructs the HUD user interface overlay.
func setup_ui_overlay() -> void:
	var canvas = CanvasLayer.new()
	add_child(canvas)

	var panel = PanelContainer.new()
	panel.position = Vector2(20, 20)
	panel.custom_minimum_size = Vector2(400, 310)
	canvas.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	info_label = Label.new()
	info_label.text = "Selecciona una ficha..."
	vbox.add_child(info_label)

	# Route Selector ComboBox
	var route_row = HBoxContainer.new()
	vbox.add_child(route_row)

	var route_lbl = Label.new()
	route_lbl.text = "Inspección Ruta: "
	route_row.add_child(route_lbl)

	route_combo = OptionButton.new()
	route_combo.add_item("--- Todas las Casillas ---", 0)

	var max_p = board_inst.max_players if (board_inst and "max_players" in board_inst) else 4
	var idx_counter = 1
	for p in range(max_p):
		var p_name = get_player_name(p)
		for s in range(2):
			route_combo.add_item("Ruta %s (P%d) - Slot %d" % [p_name, p, s], idx_counter)
			route_combo.set_item_metadata(idx_counter, {"player": p, "slot": s})
			idx_counter += 1

	if route_combo.get_popup():
		route_combo.get_popup().max_size = Vector2i(0, 400)
	route_combo.item_selected.connect(_on_route_selected)
	route_row.add_child(route_combo)

	# Scale Selection ComboBox (5% to 100%)
	var scale_row = HBoxContainer.new()
	vbox.add_child(scale_row)

	var scale_lbl = Label.new()
	scale_lbl.text = "Tamaño Proporcional: "
	scale_row.add_child(scale_lbl)

	scale_combo = OptionButton.new()
	for p in range(100, 4, -5): # 100%, 95%, 90%, 85%, ..., 5%
		scale_combo.add_item("%d%%" % p, p)
	scale_combo.item_selected.connect(_on_scale_selected)
	scale_row.add_child(scale_combo)

	var btn_row1 = HBoxContainer.new()
	vbox.add_child(btn_row1)

	var prev_btn = Button.new()
	prev_btn.text = "< Anterior (P)"
	prev_btn.pressed.connect(select_previous_piece)
	btn_row1.add_child(prev_btn)

	var next_btn = Button.new()
	next_btn.text = "Siguiente (N) >"
	next_btn.pressed.connect(select_next_piece)
	btn_row1.add_child(next_btn)

	var btn_row2 = HBoxContainer.new()
	vbox.add_child(btn_row2)

	var undo_btn = Button.new()
	undo_btn.text = "Deshacer (Ctrl+Z)"
	undo_btn.pressed.connect(perform_undo)
	btn_row2.add_child(undo_btn)

	var reset_cam_btn = Button.new()
	reset_cam_btn.text = "Resetear Cámara (R)"
	reset_cam_btn.pressed.connect(reset_camera_view)
	btn_row2.add_child(reset_cam_btn)

	var back_btn = Button.new()
	back_btn.text = "Volver al Menú Principal"
	back_btn.pressed.connect(func(): get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn"))
	vbox.add_child(back_btn)

	var help_lbl = Label.new()
	help_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	help_lbl.position = Vector2(20, 350)
	help_lbl.text = "CONTROLES:\n• Ctrl+Z (o Botón Deshacer): Revertir último cambio de posición/escala\n• Inspección Ruta: Traza línea 3D con flechas orientadas del recorrido\n• Clic Izquierdo + Arrastrar: Mover Ficha (Autoguardado al soltar)\n• Rueda Ratón / Teclas [+] [-]: Zoom Cerca / Lejos\n• Clic Derecho + Arrastrar: Desplazar Pantalla (Pan Horizontal/Vertical)\n• ComboBox Tamaño: Ajusta escala proporcional de 5% a 100% (de 5 en 5)\n• Flechas Teclado (o WASD): Ajuste Fino (+Shift = Mayor distancia)\n• N / P o TAB: Navegar entre fichas | Tecla R: Resetear Cámara"
	canvas.add_child(help_lbl)


## OptionButton route selection callback.
func _on_route_selected(index: int) -> void:
	if index == 0:
		route_mode_active = false
		current_route_sq_ids = []
		update_route_line_visualization()
		update_info_display()
		return

	var meta = route_combo.get_item_metadata(index)
	if meta is Dictionary:
		var p_id = int(meta.get("player", 0))
		current_route_player_id = p_id
		current_route_slot = int(meta.get("slot", 0))
		current_route_sq_ids = get_player_route_square_ids(p_id)
		route_mode_active = true
		update_route_line_visualization()
		if current_route_sq_ids.size() > 0:
			var sq_id = current_route_sq_ids[0]
			select_piece(sq_id, current_route_slot)


## Resets camera height and horizontal pan position back to center.
func reset_camera_view() -> void:
	if camera:
		camera.position = Vector3(0, 65, 0)
		camera.rotation_degrees = Vector3(-90, 0, 0)


## OptionButton dropdown item selection callback.
func _on_scale_selected(index: int) -> void:
	if not scale_combo or not selected_piece: return
	push_undo_snapshot()
	
	var percent = scale_combo.get_item_id(index)
	var factor = percent / 100.0

	selected_piece.scale = Vector3(factor, factor, factor)
	selection_ring.scale = Vector3(factor, factor, factor)

	var key_str = "%d_%d" % [selected_sq_id, selected_slot]
	var pos = selected_piece.position
	positions_data[key_str] = {
		"x": pos.x,
		"y": pos.y,
		"z": pos.z,
		"scale": factor
	}
	save_calibration_file()
	update_info_display()


## Selects target piece by square ID and slot index.
func select_piece(sq_id: int, slot: int) -> void:
	if selected_piece:
		var prev_k = "%d_%d" % [selected_sq_id, selected_slot]
		if positions_data.has(prev_k):
			var d = positions_data[prev_k]
			selected_piece.position.y = float(d.get("y", 0.2)) if d is Dictionary else 0.2

	selected_sq_id = sq_id
	selected_slot = slot
	var key = Vector2i(sq_id, slot)

	if piece_nodes.has(key):
		selected_piece = piece_nodes[key]
		selection_ring.visible = true
		selection_ring.position = selected_piece.position
		selection_ring.scale = selected_piece.scale

		if scale_combo:
			var factor = selected_piece.scale.x
			var percent = int(round(factor * 100.0))
			for i in range(scale_combo.item_count):
				if scale_combo.get_item_id(i) == percent:
					scale_combo.selected = i
					break
	else:
		selected_piece = null
		selection_ring.visible = false

	update_info_display()


func select_next_piece() -> void:
	var keys = piece_nodes.keys()
	var idx = keys.find(Vector2i(selected_sq_id, selected_slot))
	if idx != -1 and idx + 1 < keys.size():
		var next_k = keys[idx + 1]
		select_piece(next_k.x, next_k.y)
	elif keys.size() > 0:
		var first_k = keys[0]
		select_piece(first_k.x, first_k.y)


func select_previous_piece() -> void:
	var keys = piece_nodes.keys()
	var idx = keys.find(Vector2i(selected_sq_id, selected_slot))
	if idx > 0:
		var prev_k = keys[idx - 1]
		select_piece(prev_k.x, prev_k.y)
	elif keys.size() > 0:
		var last_k = keys[keys.size() - 1]
		select_piece(last_k.x, last_k.y)


func update_info_display() -> void:
	if not info_label: return
	if selected_piece:
		var pos = selected_piece.position
		var sc_pct = int(round(selected_piece.scale.x * 100.0))
		if route_mode_active and current_route_sq_ids.size() > 0:
			var step_idx = current_route_sq_ids.find(selected_sq_id)
			var display_step = step_idx + 1 if step_idx != -1 else 1
			info_label.text = "INSPECCIÓN RUTA: Paso %d/%d\n• Casilla ID: %d | Slot: %d\n• Posición X: %.2f | Z: %.2f | Escala: %d%%" % [display_step, current_route_sq_ids.size(), selected_sq_id, selected_slot, pos.x, pos.z, sc_pct]
		else:
			info_label.text = "FICHA SELECCIONADA:\n• Casilla ID: %d | Slot: %d\n• Posición X: %.2f | Z: %.2f | Escala: %d%%" % [selected_sq_id, selected_slot, pos.x, pos.z, sc_pct]
	else:
		info_label.text = "Sin selección"


func _input(event: InputEvent) -> void:
	# Mouse Wheel Zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if camera:
				camera.position.y = max(min_cam_y, camera.position.y - 4.0)
				get_viewport().set_input_as_handled()
				return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if camera:
				camera.position.y = min(max_cam_y, camera.position.y + 4.0)
				get_viewport().set_input_as_handled()
				return
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_panning = true
				pan_start_mouse = event.position
				if camera:
					pan_start_cam_pos = camera.position
			else:
				is_panning = false
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				var mouse_pos = event.position
				var from = camera.project_ray_origin(mouse_pos)
				var dir = camera.project_ray_normal(mouse_pos)
				var min_dist = 3.5
				var picked_key = Vector2i(-1, -1)

				for k in piece_nodes.keys():
					var p_node = piece_nodes[k]
					var p_pos = p_node.position
					var hit = drag_plane.intersects_ray(from, dir)
					if hit != null and hit.distance_to(p_pos) < min_dist:
						min_dist = hit.distance_to(p_pos)
						picked_key = k

				if picked_key != Vector2i(-1, -1):
					push_undo_snapshot()
					select_piece(picked_key.x, picked_key.y)
					is_dragging = true
			else:
				if is_dragging:
					is_dragging = false
					if route_mode_active:
						update_route_line_visualization()
					save_calibration_file()

	elif event is InputEventMouseMotion:
		if is_panning and camera:
			var mouse_delta = event.position - pan_start_mouse
			var factor = camera.position.y * 0.0018
			camera.position.x = pan_start_cam_pos.x - mouse_delta.x * factor
			camera.position.z = pan_start_cam_pos.z - mouse_delta.y * factor
			get_viewport().set_input_as_handled()
			return

		elif is_dragging and selected_piece and camera:
			var mouse_pos = event.position
			var from = camera.project_ray_origin(mouse_pos)
			var dir = camera.project_ray_normal(mouse_pos)
			var hit = drag_plane.intersects_ray(from, dir)
			if hit != null:
				selected_piece.position = Vector3(hit.x, 0.2, hit.z)
				selection_ring.position = selected_piece.position
				var key_str = "%d_%d" % [selected_sq_id, selected_slot]
				var sc = selected_piece.scale.x
				positions_data[key_str] = {"x": selected_piece.position.x, "y": 0.2, "z": selected_piece.position.z, "scale": sc}
				if route_mode_active:
					update_route_line_visualization()
				update_info_display()

	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_Z and event.is_command_or_control_pressed():
			perform_undo()
			get_viewport().set_input_as_handled()
			return

		var step = 0.5 if event.shift_pressed else 0.1
		var moved = false

		if selected_piece:
			if event.keycode in [KEY_LEFT, KEY_A]:
				selected_piece.position.x -= step; moved = true
			elif event.keycode in [KEY_RIGHT, KEY_D]:
				selected_piece.position.x += step; moved = true
			elif event.keycode in [KEY_UP, KEY_W]:
				selected_piece.position.z -= step; moved = true
			elif event.keycode in [KEY_DOWN, KEY_S] and not event.is_command_or_control_pressed():
				selected_piece.position.z += step; moved = true

		if moved:
			push_undo_snapshot()
			selection_ring.position = selected_piece.position
			var key_str = "%d_%d" % [selected_sq_id, selected_slot]
			var sc = selected_piece.scale.x
			positions_data[key_str] = {"x": selected_piece.position.x, "y": 0.2, "z": selected_piece.position.z, "scale": sc}
			if route_mode_active:
				update_route_line_visualization()
			save_calibration_file()
			update_info_display()

		if event.keycode in [KEY_EQUAL, KEY_KP_ADD]:
			if camera: camera.position.y = max(min_cam_y, camera.position.y - 4.0)
		elif event.keycode in [KEY_MINUS, KEY_KP_SUBTRACT]:
			if camera: camera.position.y = min(max_cam_y, camera.position.y + 4.0)
		elif event.keycode == KEY_R:
			reset_camera_view()
		elif event.keycode in [KEY_N, KEY_TAB]:
			select_next_piece()
		elif event.keycode == KEY_P:
			select_previous_piece()
		elif event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")


func save_calibration_file() -> void:
	var dict_to_save = {}
	var valid_square_ids = get_square_ids()

	for sq_id in valid_square_ids:
		var max_slots = get_max_slots(sq_id)
		for slot in range(max_slots):
			var key_str = "%d_%d" % [sq_id, slot]
			if positions_data.has(key_str):
				var val = positions_data[key_str]
				if val is Dictionary:
					dict_to_save[key_str] = val
				elif val is Vector3:
					dict_to_save[key_str] = {"x": val.x, "y": val.y, "z": val.z, "scale": 1.0}

	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(dict_to_save, "\t"))
		file.close()
		print("CALIBRATION & SCALES SAVED TO: ", save_path)


func load_calibration_file() -> void:
	if not FileAccess.file_exists(save_path):
		return

	var file = FileAccess.open(save_path, FileAccess.READ)
	if file:
		var json_str = file.get_as_text()
		file.close()
		var json_data = JSON.parse_string(json_str)
		if json_data is Dictionary:
			positions_data = json_data
			print("CALIBRATION & SCALES LOADED FROM: ", save_path)
