extends Node3D
class_name GameDiceStartBase

@onready var FloatingText = $FloatingText if has_node("FloatingText") else null

var dice_higher = 0
var winers = []


## Returns the BoardBase child node instance. Virtual method.
## @return BoardBase node.
func board() -> BoardBase:
	for child in get_children():
		if child is BoardBase:
			return child
	return null


## Virtual method returning the target gameplay scene path after starting player selection.
## @return String file path to target scene.
func get_target_game_scene_path() -> String:
	return "res://scenes/Game4.tscn"


## Node initialization loop. Rolls dice for all active players to decide starting player.
func _ready():
	print("LOADING GAMEDICESTART")
	if FloatingText:
		FloatingText.show_text(tr("Let's see who starts"), Color.WHITE)

	# Load global player configuration and await all pieces moving to their starting home positions
	await Globals.game_load_glogals_game_data(self, true, true)
	var is_winer = null
	
	# Active candidates pool for current roll round (starts with all participating players)
	var active_candidates = self.board().players_than_plays()
	
	# Loop until a single winner is determined
	while is_winer == null:
		self.winers = []
		self.dice_higher = 0
		
		# Hide dice for any non-candidate players while keeping candidates' dice visible
		for p in self.board().players():
			if not p in active_candidates:
				p.dice().visible = false
			
		# Roll dice sequentially for each active candidate in this round
		for p in active_candidates:
			p.dice().visible = true
			p.can_move_pieces = false
			p.dice_throws = []
			p.extra_moves = []
			p.can_throw_dice = true
			p.dice().launch()
			
			await p.dice().dice_got_value
			if p.dice().value > self.dice_higher:
				self.dice_higher = p.dice().value
			# All rolled dice remain visible on the board for visual comparison
			
		# Evaluate highest throw winners among active candidates
		for p in active_candidates:
			if p.dice().value == dice_higher:
				self.winers.append(p)
				
		if self.winers.size() == 1:
			is_winer = await self.is_there_a_winer()
		else:
			# Tie detected! Wait briefly so players can see and compare the tied dice values
			await get_tree().create_timer(1.5).timeout
			# Next round tie-breaker: candidate pool becomes only the tied repeating players
			active_candidates = self.winers.duplicate()


## Evaluates winner determination and transitions to target game scene.
## @return True if a winner is confirmed, null if a tie-breaker roll is required.
func is_there_a_winer():
	if len(self.winers) == 1:
		Globals.game_data["current"] = self.winers[0].id
		# Flag that scene transition to gameplay scene comes directly from GameDiceStart
		Globals.from_dice_start = true
		if FloatingText:
			FloatingText.show_text(tr("Player {0} starts").format([self.winers[0].playername]), self.winers[0].color)
			await FloatingText.text_disappear
		await Globals.fade_to_scene(get_tree(), self.get_target_game_scene_path())
		return true
	return null


## Frame process loop checking exit key shortcut.
## @param _delta Delta frame time.
func _process(_delta):	
	if Input.is_action_just_pressed("exit"):
		await Globals.fade_to_scene(get_tree(), "res://scenes/Main.tscn")
