extends DictionaryManager
class_name Circle

var squares
var max_players
var number #Number of squares in circle

# Called when the node enters the scene tree for the first time.
func _init(_max_players:int, _squares:SquareManager):
	self.squares=_squares
	self.max_players=_max_players
	if self.max_players==4:
		self.number=68
	
	for i in range(1, self.number+1):
		self.append(self.squares.get(i))
		
	
func is_square_in_circle(square):
	if self.has(square.id):
		return true
	return false
	
func square(square_origin,  displacement):
		# Calcula la casilla del circulo que tiene un desplazamiento positivo (hacia adelante) o negativo (hacia atras) 
		# de la casilla cuya posicion (id de la casilla) se ha dado como parametro
		if square_origin.id>self.number:   #Si no esta en el circulo
			return null
			
		var destiny=square_origin.id-1+displacement
		if destiny<0:
			destiny=self.number+destiny
		if destiny>self.number-1:
			destiny=destiny-self.number
		return self.get(destiny)
		
## square_from must be before sqaure_to although has 68 as number
func distance(square_from, square_to):
	if not is_square_in_circle(square_from):
		print("DISTANCE SQUARE FROM NOT IN CIRCLE")
		return null
	if not is_square_in_circle(square_to):
		print("DISTANCE SQUARE TO NOT IN CIRCLE")
		return null
	if square_to.id>=square_from.id:
		return square_to.id-square_from.id
	else:
		return square_to.id+self.number-square_from.id
