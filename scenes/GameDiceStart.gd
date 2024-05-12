extends Node3D
class_name GameDiceStart


@onready var Board4=$Board4
@onready var FloatingText=$FloatingText

var dice_higher=0
var winers=[]

# Called when the node enters the scene tree for the first time.
func _ready():
	print("LOADING GAMEDICESTART")
	$FloatingText.show_text(tr("Let's see who starts"), Color(255,255,255,1))

	## Creating players
	Globals.game_load_glogals_game_data(self)
	var is_winer=null
	while is_winer==null:
		self.winers=[] #Player index
		self.dice_higher=0
		for p in Board4.players_than_plays():
			p.can_move_pieces=false
			p.dice_throws=[]
			p.extra_moves=[]
			p.can_throw_dice=true
			p.dice().set_my_position(5)
			p.dice().launch()
			
			await p.dice().dice_got_value
			if p.dice().value>self.dice_higher:
				self.dice_higher=p.dice().value	
			
		#Search winners
		for p in Board4.players():
			if p.dice().value==dice_higher:
				self.winers.append(p)
				
		is_winer=await self.is_there_a_winer()


## Returns null if there is no winner or a winer player object
func is_there_a_winer():
	if len(self.winers)==1:
		Globals.game_data["current"]=self.winers[0].id
		$FloatingText.show_text(tr("Player {0} starts").format([self.winers[0].name]), self.winers[0].color)
		await $FloatingText.text_disappear
		get_tree().change_scene_to_file("res://scenes/Game4.tscn")
		return true
	else:
		for p in Board4.players():
			if not p in self.winers: 
				p.plays=false
		return null
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_RequestGameStart_request_completed(result, response_code, headers, body):
	if result==0:
		var r=JSON.parse_string(body.get_string_from_utf8())
		print ("  - ", r["success"],": ", r["detail"])
	else:
		print ("  -  Couldn't connect")

