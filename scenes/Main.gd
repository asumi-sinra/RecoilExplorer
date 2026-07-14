extends Node

func _ready():

	var world = WorldData.new()

	world.create_empty()

	var chunk = world.get_chunk(Vector2i(5,2))

	chunk.get_connection(
		Enums.Direction.RIGHT
	).connected = true

	print(

		chunk.get_connection(
			Enums.Direction.RIGHT
		).connected

	)

	print(

		chunk.get_connection(
			Enums.Direction.LEFT
		).connected

	)
