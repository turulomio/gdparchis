extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity : int = 800

var vel : Vector3 = Vector3()

onready var sprite: Sprite3D = get_node("Piece")

func _physics_process(delta): 
	vel.y=-100
	if Input.is_action_just_pressed("piece_click"):
		vel.y=4000
	move_and_slide(vel,Vector3.UP)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
