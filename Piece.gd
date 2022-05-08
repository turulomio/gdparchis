extends KinematicBody
class_name Piece

var gravity : int = 800
var vel : Vector3 = Vector3(0,0,0)

func _physics_process(delta): 
	move_and_slide(vel,Vector3.UP)
