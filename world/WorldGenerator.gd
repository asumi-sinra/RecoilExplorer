extends Node

const WIDTH := 16
const HEIGHT := 4

var chunks : Array = []

@onready var phase_generator = $"../PhaseGenerator"


func generate(world_seed : int = 0):

	chunks.clear()

	for y in range(HEIGHT):

		var row = []

		for x in range(WIDTH):

			row.append(
				ChunkData.new(Vector2i(x, y))
			)

		chunks.append(row)

	phase_generator.generate(chunks, world_seed)

	debug_print_chunks()


func debug_print_chunks():

	print("============================")

	for row in chunks:

		for chunk in row:

			print(
				chunk.coord,
				"  ",
				chunk.biome.display_name,
				"  connection = ",
				chunk.connection
			)

	print("============================")
