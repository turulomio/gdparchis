extends Node3D

@export var id: int=0: set=set_id #With id I should have everything to calculate data

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_id(value):
	id=value
