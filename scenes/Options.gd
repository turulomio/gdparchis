extends Control



func _on_Return_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")



func _on_CheckBox_toggled(button_pressed):
		OS.window_fullscreen = button_pressed
