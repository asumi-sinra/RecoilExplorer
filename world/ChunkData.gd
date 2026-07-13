class_name ChunkData

var coord : Vector2i

# BiomeTypeではなくBiomeDataを保持する
var biome : BiomeData

var connection : int

var room_scene : PackedScene

var difficulty : int


func _init(pos : Vector2i):

	coord = pos

	biome = null

	connection = Enums.Connection.NONE

	room_scene = null

	difficulty = 0
