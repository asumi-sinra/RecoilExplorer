extends Node


var forest : BiomeData = preload("res://resources/biome/Forest.tres")
var volcano : BiomeData = preload("res://resources/biome/Volcano.tres")


func generate(chunks:Array, world_seed:int):

	seed(world_seed)

	generate_biome(chunks)

	generate_connection(chunks)


func generate_biome(chunks):

	for row in chunks:

		for chunk in row:

			if chunk.coord.x < 8:

				chunk.biome = forest

			else:

				chunk.biome = volcano


func generate_connection(chunks):

	for row in chunks:

		for chunk in row:

			chunk.connection = Enums.Connection.LEFT | Enums.Connection.RIGHT
