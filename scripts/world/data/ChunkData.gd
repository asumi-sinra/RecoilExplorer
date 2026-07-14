class_name ChunkData

var coord: Vector2i

var biome: BiomeData

var connection: int

var room: RoomData

var difficulty: int


func _init(pos: Vector2i):

	coord = pos

	biome = null

	connection = Enums.Connection.NONE

	room = null

	difficulty = 0
