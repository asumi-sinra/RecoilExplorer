extends Node

const WIDTH := 16
const HEIGHT := 4

var chunks : Array = []

@onready var biome_generator = $"../BiomeGenerator"
@onready var connection_generator = $"../ConnectionGenerator"
@onready var debug_map = $"../DebugMap"


func generate():

	chunks.clear()

	for y in range(HEIGHT):

		var row := []

		for x in range(WIDTH):

			row.append(
				ChunkData.new(Vector2i(x,y))
			)

		chunks.append(row)

	biome_generator.generate(chunks)

	connection_generator.generate(chunks)

	debug_map.draw_chunks(chunks)
