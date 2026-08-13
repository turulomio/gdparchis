extends Node3D
class_name GameDiceStart

@onready var Board4 = $Board4
@onready var FloatingText = $FloatingText

var dice_higher = 0
var winers = []


## Returns the Board4 child node instance.
## @return Board4 node.
func board():
	return $Board4


## Node initialization loop. Rolls dice for all active players to decide starting player.
func _ready():
	print("LOADING GAMEDICESTART")
	$FloatingText.show_text(tr("Let's see who starts"), Color(255, 255, 255, 1))

	# Load global player configuration
	Globals.game_load_glogals_game_data(self, false)
	var is_winer = null
	
	# Loop until a single winner is determined
	while is_winer == null:
		self.winers = []
		self.dice_higher = 0
		for p in self.board().players_than_plays():
			p.can_move_pieces = false
			p.dice_throws = []
			p.extra_moves = []
			p.can_throw_dice = true
			p.dice().launch()
			
			await p.dice().dice_got_value
			if p.dice().value > self.dice_higher:
				self.dice_higher = p.dice().value	
			
		# Evaluate highest throw winners
		for p in self.board().players():
			if p.dice().value == dice_higher:
				self.winers.append(p)
				
		is_winer = await self.is_there_a_winer()


## Evaluates winner determination and transitions to Game4.tscn if a single winner exists.
## @return True if a winner is confirmed, null if a tie-breaker roll is required.
func is_there_a_winer():
	if len(self.winers) == 1:
		Globals.game_data["current"] = self.winers[0].id
		$FloatingText.show_text(tr("Player {0} starts").format([self.winers[0].playername]), self.winers[0].color)
		await $FloatingText.text_disappear
		get_tree().change_scene_to_file("res://scenes/Game4.tscn")
		return true
	else:
		# Filter participating players to tied winners for tie-breaker
		for p in self.board().players():
			if not p in self.winers: 
				p.plays = false
		return null


## Frame process loop checking exit key shortcut.
## @param _delta Delta frame time.
func _process(_delta):	
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://scenes/Main.tscn")


## Completion handler for backend game start HTTP request.
func _on_RequestGameStart_request_completed(result, response_code, headers, body):
	if result == 0:
		var r = JSON.parse_string(body.get_string_from_utf8())
		print("  - ", r["success"], ": ", r["detail"])
	else:
		print("  -  Couldn't connect")
