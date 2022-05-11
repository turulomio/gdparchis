extends RigidBody

var vel : Vector3 = Vector3(0,-30,0)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _physics_process(_delta): 
	return move_and_slide(vel,Vector3.UP)
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var x = rand_range(-10,10)
	var y = rand_range(-10,10)
	var z = rand_range(-10,10)
	set_angular_velocity(Vector3(x,y,z))
	
