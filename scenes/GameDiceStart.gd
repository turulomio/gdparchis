extends Spatial
class_name Game4Start


var floating_text=preload("res://scenes/FloatingText.tscn")
var players
var dice_higher=0
var winers=[]

# Called when the node enters the scene tree for the first time.
func _ready():	
	
	var text=floating_text.instance()
	text.text="Let's see who starts"
	self.add_child(text)
	
	## Creating players
	self.players=PlayerManager.new(Globals.game_data.max_players)
	for d_player in Globals.game_data["players"]:
		if d_player["plays"]==true:
			var player=Player.new(d_player["id"],d_player["plays"],d_player["ia"])
			self.players.append(player)
		
	for p in self.players.values():
		p.set_game(self)
		var dice=Globals.SCENE_DICE.instance()
		self.add_child(dice)
		dice.set_id(p.id)
		dice.set_player(p)
		p.set_dice(dice)

	var is_winer=null
	while is_winer==null:
		self.winers=[] #Player index
		self.dice_higher=0
		for p in self.players.values():
			if p.plays==false:
				continue
			p.can_move_pieces=false
			p.dice_throws=[]
			p.extra_moves=[]
			p.can_throw_dice=true
			p.dice.launch()
			yield(p.dice, "dice_got_value")
			if p.dice.value>self.dice_higher:
				self.dice_higher=p.dice.value	
			
		#Search winners
		for p in self.players.values():
			if p.dice.value==dice_higher:
				self.winers.append(p)
				
		is_winer=self.is_there_a_winer()
				

## Returns null if there is no winner or a winer player object
func is_there_a_winer():
	if len(self.winers)==1:
		Globals.game_data["current"]=self.winers[0].id
		
		var text=floating_text.instance()
		text.text="Player %s starts" % self.winers[0].name
		self.add_child(text)
		yield(text,"text_disappear")
		
		get_tree().change_scene("res://scenes/Game4.tscn")
		return true
	else:
		for p in self.players.values():
			if not p in self.winers: 
				p.plays=false
				self.remove_child(p.dice)
		return null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene("res://scenes/Main.tscn")
