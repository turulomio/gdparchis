extends KinematicBody

var gravity : int = 800
var vel : Vector3 = Vector3(0,-100,0)

func _physics_process(_delta): 
	return move_and_slide(vel,Vector3.UP)

