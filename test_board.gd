extends SceneTree
func _init():
    var board = preload("res://scenes/Board8.tscn").instantiate()
    var r = []
    for c in board.get_children():
        if c.name.begins_with("Player"): r.append(c.name)
    print("PLAYERS: ", r)
    quit()
