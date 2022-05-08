extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var ViewSize: Vector2 = get_viewport().get_visible_rect().size
# Called when the node enters the scene tree for the first time.
func _ready():
	print(ViewSize)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
