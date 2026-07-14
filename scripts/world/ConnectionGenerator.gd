extends RefCounted
class_name ConnectionGenerator


func create_connection(
	world: WorldData,
	chunk: ChunkData,
	dir: Enums.Direction
) -> void:

	var neighbor := world.get_neighbor(chunk, dir)

	if neighbor == null:
		return

	# 自分側
	chunk.get_connection(dir).connected = true

	# 相手側
	match dir:

		Enums.Direction.LEFT:
			neighbor.right.connected = true

		Enums.Direction.RIGHT:
			neighbor.left.connected = true

		Enums.Direction.UP:
			neighbor.down.connected = true

		Enums.Direction.DOWN:
			neighbor.up.connected = true


func generate(world: WorldData) -> void:

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH - 1):

			var chunk := world.get_chunk(Vector2i(x, y))

			create_connection(
				world,
				chunk,
				Enums.Direction.RIGHT
			)
