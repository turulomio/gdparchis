extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var pieces_nodes=[]

func get_object_under_mouse():
	var mouse_pos=get_viewport().get_mouse_position()
	var ray_from=$Camera.project_ray_origin(mouse_pos)
	var ray_to= ray_from + $Camera.project_ray_normal(mouse_pos)*1000
	var space_state=get_world().direct_space_state
	var selection=space_state.intersect_ray(ray_from,ray_to)
	return selection.collider

# Called when the node enters the scene tree for the first time.
func _ready():
	pieces_nodes=get_tree().get_nodes_in_group("pieces")
	print(pieces_nodes)


func pick(instanceId):
	print(instanceId)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("piece_click"):
		var object=get_object_under_mouse()
		if object.filename=="res://Piece.tscn":
			object.global_transform.origin.y=20
		
