# Note: The code is written in a way that maximizes performance.
extends Node

const MODULO_8_BIT = 256


## Returns a random 8-bit integer (0 to 255).
## @return Integer in range [0, 255].
static func getRandomInt():
	randomize()
	return randi() % MODULO_8_BIT


## Generates a 16-byte array formatted for UUID v4 specification.
## @return Array of 16 integers.
static func uuidbin():
	return [
		getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
		getRandomInt(), getRandomInt(), ((getRandomInt()) & 0x0f) | 0x40, getRandomInt(),
		((getRandomInt()) & 0x3f) | 0x80, getRandomInt(), getRandomInt(), getRandomInt(),
		getRandomInt(), getRandomInt(), getRandomInt(), getRandomInt(),
	]


## Generates a UUID v4 string in canonical 8-4-4-4-12 hex format.
## @return UUID v4 string.
static func v4():
	var b = uuidbin()
	return '%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x' % [
		b[0], b[1], b[2], b[3],
		b[4], b[5],
		b[6], b[7],
		b[8], b[9],
		b[10], b[11], b[12], b[13], b[14], b[15]
	]
