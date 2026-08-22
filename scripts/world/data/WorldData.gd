class_name WorldData


# =========================
# マップサイズ
# =========================

const WIDTH: int = 16
const HEIGHT: int = 4


# =========================
# チャンク
# =========================

var chunks: Array = []


# =========================
# 初期化
# =========================

func create_empty() -> void:

	chunks.clear()

	for y in range(HEIGHT):

		var row: Array = []

		for x in range(WIDTH):

			var chunk := ChunkData.new(
				Vector2i(x, y)
			)

			row.append(chunk)

		chunks.append(row)


# =========================
# 範囲判定
# =========================

func is_inside(pos: Vector2i) -> bool:

	return (
		pos.x >= 0
		and pos.x < WIDTH
		and pos.y >= 0
		and pos.y < HEIGHT
	)


# =========================
# チャンク取得
# =========================

func get_chunk(pos: Vector2i) -> ChunkData:

	if not is_inside(pos):
		return null

	return chunks[pos.y][pos.x]


# =========================
# 方向 → 座標差
# =========================

func get_direction_offset(
	dir: Enums.Direction
) -> Vector2i:

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


# =========================
# 隣接チャンク取得
# =========================

func get_neighbor(
	chunk: ChunkData,
	dir: Enums.Direction
) -> ChunkData:

	var offset := get_direction_offset(dir)

	return get_chunk(
		chunk.coord + offset
	)
