class_name WorldData

const WIDTH := 16
const HEIGHT := 4

var chunks : Array = []


func create_empty():

	chunks.clear()

	for y in range(HEIGHT):

		var row : Array = []

		for x in range(WIDTH):

			row.append(
				ChunkData.new(Vector2i(x,y))
			)

		chunks.append(row)


func is_inside(pos:Vector2i)->bool:

	return pos.x >= 0 \
		and pos.x < WIDTH \
		and pos.y >= 0 \
		and pos.y < HEIGHT


func get_chunk(pos:Vector2i)->ChunkData:

	if !is_inside(pos):
		return null

	return chunks[pos.y][pos.x]


func get_neighbor(
	chunk:ChunkData,
	dir:Enums.Direction
)->ChunkData:

	var offset := Vector2i.ZERO

	match dir:

		Enums.Direction.LEFT:
			offset = Vector2i.LEFT

		Enums.Direction.RIGHT:
			offset = Vector2i.RIGHT

		Enums.Direction.UP:
			offset = Vector2i.UP

		Enums.Direction.DOWN:
			offset = Vector2i.DOWN

	return get_chunk(
		chunk.coord + offset
	)

func get_direction_offset(dir:Enums.Direction)->Vector2i:

	match dir:

		Enums.Direction.DOWN:
			return Vector2i.DOWN

		Enums.Direction.LEFT:
			return Vector2i.LEFT

		Enums.Direction.UP:
			return Vector2i.UP

		Enums.Direction.RIGHT:
			return Vector2i.RIGHT

	return Vector2i.ZERO
