class_name ChunkData

var coord : Vector2i

var biome : BiomeData

var room : RoomData

var difficulty : int


var left : ConnectionData
var right : ConnectionData
var up : ConnectionData
var down : ConnectionData


func _init(pos:Vector2i):

	coord = pos

	left = ConnectionData.new(Enums.Direction.LEFT)
	right = ConnectionData.new(Enums.Direction.RIGHT)
	up = ConnectionData.new(Enums.Direction.UP)
	down = ConnectionData.new(Enums.Direction.DOWN)

	biome = null
	room = null
	difficulty = 0


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


func link(
	world:WorldData,
	dir:Enums.Direction,
	type:Enums.ConnectionType = Enums.ConnectionType.NORMAL
)->void:

	var neighbor := world.get_neighbor(self, dir)

	if neighbor == null:
		return

	var my_connection := get_connection(dir)

	my_connection.connected = true
	my_connection.type = type

	match dir:

		Enums.Direction.LEFT:

			neighbor.right.connected = true
			neighbor.right.type = type

		Enums.Direction.RIGHT:

			neighbor.left.connected = true
			neighbor.left.type = type

		Enums.Direction.UP:

			neighbor.down.connected = true
			neighbor.down.type = type

		Enums.Direction.DOWN:

			neighbor.up.connected = true
			neighbor.up.type = type
