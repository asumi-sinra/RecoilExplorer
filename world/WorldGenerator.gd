extends Node

const WIDTH := 16
const HEIGHT := 4

var chunks : Array = []


func generate():

	chunks.clear()

	for y in range(HEIGHT):

		var row = []

		for x in range(WIDTH):

			row.append(
				ChunkData.new(Vector2i(x, y))
			)

		chunks.append(row)

	print("Chunk Count :", WIDTH * HEIGHT)
