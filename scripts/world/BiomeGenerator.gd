extends RefCounted
class_name BiomeGenerator

var forest : BiomeData = preload("res://resources/biome/Forest.tres")
var volcano : BiomeData = preload("res://resources/biome/Volcano.tres")


func generate(world : WorldData):

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk = world.get_chunk(
				Vector2i(x,y)
			)
			
			if x < WorldData.WIDTH / 2:
				chunk.biome = forest
				
			else:
				chunk.biome = volcano
