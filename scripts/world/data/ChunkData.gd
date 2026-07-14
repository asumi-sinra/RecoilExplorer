class_name ChunkData

var coord : Vector2i

var biome : BiomeData

var room : RoomData

var difficulty : int

var connections : Dictionary


func _init(pos : Vector2i):

	coord = pos

	biome = null

	room = null

	difficulty = 0

	connections = {

		Enums.Direction.LEFT:
			ConnectionData.new(Enums.Direction.LEFT),

		Enums.Direction.RIGHT:
			ConnectionData.new(Enums.Direction.RIGHT),

		Enums.Direction.UP:
			ConnectionData.new(Enums.Direction.UP),

		Enums.Direction.DOWN:
			ConnectionData.new(Enums.Direction.DOWN)
	}


func get_connection(dir : Enums.Direction) -> ConnectionData:

	return connections[dir]
