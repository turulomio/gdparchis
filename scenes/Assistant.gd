extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

	
# https://raw.githubusercontent.com/godotengine/godot-docs/master/img/color_constants.png
func set_color(s):	
	var new_material = SpatialMaterial.new()
	new_material.albedo_color = s
	$MeshInstance.material_override=new_material
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
