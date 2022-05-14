extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):


func _on_Exit_pressed():
	
		get_tree().quit()
#	pass


func _on_Load_pressed():
	$FileDialog.popup()
#	pass


func _on_Players4_pressed():
	get_tree().change_scene("res://scenes/Game4.tscn")


func _on_Players4All_pressed():
	get_tree().change_scene("res://scenes/Game4Objects.tscn")


func _on_FileDialog_file_selected(path):
	var data=Globals.load_game(path)
	if data["max_players"]==4:
		Globals.game_data=data
		get_tree().change_scene("res://scenes/Game4.tscn")
		
