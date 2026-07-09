class_name ChunkData

var coord : Vector2i

var biome : Enums.BiomeType

var connection : int

var room_scene : PackedScene

var difficulty : int


func _init(pos : Vector2i):

	coord = pos

	biome = Enums.BiomeType.NONE

	connection = Enums.Connection.NONE

	room_scene = null

	difficulty = 0
