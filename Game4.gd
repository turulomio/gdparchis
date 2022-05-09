extends Spatial

onready var camera =$Camera

func get_object_under_mouse():
	var mouse_pos=get_viewport().get_mouse_position()
	var ray_from=$Camera.project_ray_origin(mouse_pos)
	var ray_to= ray_from + $Camera.project_ray_normal(mouse_pos)*1000
	var space_state=get_world().direct_space_state
	var selection=space_state.intersect_ray(ray_from,ray_to)
	return selection.collider

# Called when the node enters the scene tree for the first time.
func _ready():
	## Creating pieces
	for i in range(16):
		var piece_scene=load("res://Piece.tscn")
		var piece=piece_scene.instance()
		add_child(piece)
		piece.set_id(i)


		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("piece_click"):
		var object=get_object_under_mouse()
		if object.filename=="res://Piece.tscn":
			object.global_transform.origin.y=20
			print(object.id)
		if object.filename=="res://4_square_normal.tscn":
			object.global_transform.origin.y=20
		
	if Input.is_action_just_pressed("zoom_in"):
		camera.global_transform.origin.y=camera.global_transform.origin.y-20
	if Input.is_action_just_pressed("zoom_out"):
		camera.global_transform.origin.y=camera.global_transform.origin.y+20
