extends Node

func _ready():

	var world = WorldData.new()

	world.create_empty()

	var biome_generator = BiomeGenerator.new()

	biome_generator.generate(world)

	for row in world.chunks:

		var line := ""

		for chunk in row:

			line += chunk.biome.display_name.left(1) + " "

		print(line)
