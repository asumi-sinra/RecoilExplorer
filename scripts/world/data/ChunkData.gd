class_name ChunkData

var coord : Vector2i

var biome : BiomeData

var room : RoomData

var difficulty : int


var left : ConnectionData
var right : ConnectionData
var up : ConnectionData
var down : ConnectionData


func _init(pos : Vector2i):

	coord = pos

	biome = null

	room = null

	difficulty = 0

	left = ConnectionData.new(Enums.Direction.LEFT)
	right = ConnectionData.new(Enums.Direction.RIGHT)
	up = ConnectionData.new(Enums.Direction.UP)
	down = ConnectionData.new(Enums.Direction.DOWN)


func get_connection(dir:Enums.Direction)->ConnectionData:

	match dir:

		Enums.Direction.LEFT:
			return left

		Enums.Direction.RIGHT:
			return right

		Enums.Direction.UP:
			return up

		Enums.Direction.DOWN:
			return down

	return null
