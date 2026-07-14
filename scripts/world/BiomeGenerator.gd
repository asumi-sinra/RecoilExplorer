extends RefCounted
class_name BiomeGenerator

var forest : BiomeData = preload("res://resources/biome/Forest.tres")
var volcano : BiomeData = preload("res://resources/biome/Volcano.tres")


func generate(world : WorldData):

	for row in world.chunks:

		for chunk in row:

			if chunk.coord.x < WorldData.WIDTH / 2:
				chunk.biome = forest
			else:
				chunk.biome = volcano
