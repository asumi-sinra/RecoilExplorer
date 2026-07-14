extends Node


func _ready():

	var world := WorldData.new()

	world.create_empty()

	var biome_generator := BiomeGenerator.new()
	biome_generator.generate(world)

	var connection_generator := ConnectionGenerator.new()
	connection_generator.generate(world)

	print_connections(world)



func print_connections(world: WorldData):

	for y in range(WorldData.HEIGHT):

		var line := ""

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(Vector2i(x, y))

			line += "□"

			if chunk.right.connected:
				line += "──"

			else:
				line += "  "

		print(line)
