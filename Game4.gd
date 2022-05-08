extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pieces_nodes=[]

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
	for i in range(20):
		print(i)
		var piece=Piece.new()
		add_child(piece)
		print(piece)
		piece.scale=Vector3(10,10,10)
		piece.translate(Vector3(5*i,5*i,5*i))
		pieces_nodes.append(piece)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("piece_click"):
		var object=get_object_under_mouse()
		if object.filename=="res://Piece.tscn":
			object.global_transform.origin.y=20
		if object.filename=="res://4_square_normal.tscn":
			object.global_transform.origin.y=20
		
	if Input.is_action_just_pressed("zoom_in"):
		camera.global_transform.origin.y=camera.global_transform.origin.y-20
	if Input.is_action_just_pressed("zoom_out"):
		camera.global_transform.origin.y=camera.global_transform.origin.y+20
