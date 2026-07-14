extends Node


func _ready():

	var world = WorldData.new()

	world.create_empty()

	print(world.chunks.size())

	print(world.chunks[0].size())

	print(world.get_chunk(Vector2i(5,2)).coord)
