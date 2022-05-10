class_name Player
var id : int = 0
var name_internal : String
var name : String
var color
var active : bool


func _init(node_id):
	self.id=node_id

	match(self.id):
		0:
			self.name_internal="yellow"
			self.name="Yellowy"
			self.color=ColorN("yellow",1)
			self.active=true
		1:
			self.name_internal="blue"
			self.name="Bluey"
			self.color=ColorN("blue",1)
			self.active=true
		2:
			self.name_internal="red"
			self.name="Redy"
			self.color=ColorN("red",1)
			self.active=true
		3:
			self.name_internal="green"
			self.name="Greeny"
			self.color=ColorN("green",1)
			self.active=true




