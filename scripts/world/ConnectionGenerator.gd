extends RefCounted
class_name ConnectionGenerator


func generate(world:WorldData)->void:

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH - 1):

			var chunk := world.get_chunk(Vector2i(x,y))

			chunk.link(
				world,
				Enums.Direction.RIGHT
			)
