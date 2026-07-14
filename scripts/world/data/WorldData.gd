class_name WorldData

const WIDTH := 16
const HEIGHT := 4

var chunks: Array = []


func create_empty():

	chunks.clear()

	for y in range(HEIGHT):

		var row: Array = []

		for x in range(WIDTH):

			row.append(
				ChunkData.new(Vector2i(x, y))
			)

		chunks.append(row)


func get_chunk(pos: Vector2i) -> ChunkData:

	return chunks[pos.y][pos.x]
