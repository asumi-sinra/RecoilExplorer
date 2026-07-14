extends Node

func _ready():

	var world = WorldData.new()

	world.create_empty()

	var biome_generator = BiomeGenerator.new()

	biome_generator.generate(world)

	print(
		world.get_neighbor(
			world.get_chunk(Vector2i(3,2)),
			Enums.Direction.RIGHT
		).coord
	)
