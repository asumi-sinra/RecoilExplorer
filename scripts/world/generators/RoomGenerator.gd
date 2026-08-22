extends RefCounted
class_name RoomGenerator


# =========================
# Room割り当て
# =========================

func generate(
	world: WorldData,
	rooms: Array[RoomData]
) -> void:

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			var candidates := get_candidates(
				chunk,
				rooms
			)

			if candidates.is_empty():

				push_error(
					"RoomGenerator: "
					+ "条件に一致するRoomDataがありません。"
					+ " chunk="
					+ str(chunk.coord)
				)

				continue


			chunk.room = candidates.pick_random()


# =========================
# Room候補取得
# =========================

func get_candidates(
	chunk: ChunkData,
	rooms: Array[RoomData]
) -> Array[RoomData]:

	var result: Array[RoomData] = []


	for room in rooms:

		# -------------------------
		# バイオーム
		# -------------------------

		if not room.can_use_in_biome(
			chunk.main_biome
		):

			continue


		# -------------------------
		# 道の接続条件
		# -------------------------

		if not matches_connections(
			chunk,
			room
		):

			continue


		# -------------------------
		# 候補に追加
		# -------------------------

		result.append(room)


	return result


# =========================
# 接続条件判定
# =========================

func matches_connections(
	chunk: ChunkData,
	room: RoomData
) -> bool:

	# Room側の接続情報と
	# Chunk側のroad_bitsが一致しているか確認する。

	if room.has_connection(
		Enums.Direction.DOWN
	) != chunk.has_road(
		Enums.Direction.DOWN
	):

		return false


	if room.has_connection(
		Enums.Direction.LEFT
	) != chunk.has_road(
		Enums.Direction.LEFT
	):

		return false


	if room.has_connection(
		Enums.Direction.UP
	) != chunk.has_road(
		Enums.Direction.UP
	):

		return false


	if room.has_connection(
		Enums.Direction.RIGHT
	) != chunk.has_road(
		Enums.Direction.RIGHT
	):

		return false


	return true
