extends Node

var forest : BiomeData = preload("res://resources/biome/Forest.tres")
var volcano : BiomeData = preload("res://resources/biome/Volcano.tres")


func generate(chunks:Array):

	for row in chunks:

		for chunk in row:

			if chunk.coord.x < 8:
				chunk.biome = forest
			else:
				chunk.biome = volcano
