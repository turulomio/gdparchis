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
	var piece_scene=load("res://scenes/Piece.tscn")
	for i in range(16):
		var piece=piece_scene.instance()
		add_child(piece)
		piece.set_id(i)
		
	## Creating squares
	var SquareNormal4=load("res://scenes/SquareNormal4.tscn")
	for i in range(7)+range(68,76):
		var square=SquareNormal4.instance()
		add_child(square)
		square.set_id(i)
		
	var SquareEnd4=load("res://scenes/SquareEnd4.tscn")
	for i in [76,84,92,100]:
		var square=SquareEnd4.instance()
		add_child(square)
		square.set_id(i)


		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("piece_click"):
		var object=get_object_under_mouse()
		if object.filename=="res://scenes/Piece.tscn":
			object.global_transform.origin.y=20
			print(object.id)
		if object.filename=="res://scenes/SquareNormal4.tscn":
			object.global_transform.origin.y=20
			print(object.id)
		if object.filename=="res://scenes/SquareEnd4.tscn":
			object.global_transform.origin.y=20
			print(object.id)
		
	if Input.is_action_just_pressed("zoom_in"):
		camera.global_transform.origin.y=camera.global_transform.origin.y-20
	if Input.is_action_just_pressed("zoom_out"):
		camera.global_transform.origin.y=camera.global_transform.origin.y+20
