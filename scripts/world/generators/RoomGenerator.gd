extends RefCounted


# =========================
# Room割り当て
# =========================

func generate(
	world: WorldData,
	rooms: Array[RoomData]
) -> int:

	var assigned_count: int = 0

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)

			var candidates: Array[RoomData] = get_candidates(
				chunk,
				rooms
			)

			if candidates.is_empty():

				chunk.room = null
				continue

			chunk.room = candidates.pick_random()
			assigned_count += 1

	return assigned_count


# =========================
# Room候補取得
# =========================

func get_candidates(
	chunk: ChunkData,
	rooms: Array[RoomData]
) -> Array[RoomData]:

	var result: Array[RoomData] = []

	for room in rooms:

		if room == null:
			continue

		# -------------------------
		# Biome一致
		# -------------------------

		if room.biome != chunk.main_biome:
			continue


		# -------------------------
		# 通路一致
		# -------------------------

		if not matches_connections(
			chunk,
			room
		):
			continue


		result.append(room)

	return result


# =========================
# 通路条件判定
# =========================

func matches_connections(
	chunk: ChunkData,
	room: RoomData
) -> bool:

	if room.exits.has(
		Enums.Direction.DOWN
	) != chunk.has_road(
		Enums.Direction.DOWN
	):
		return false


	if room.exits.has(
		Enums.Direction.LEFT
	) != chunk.has_road(
		Enums.Direction.LEFT
	):
		return false


	if room.exits.has(
		Enums.Direction.UP
	) != chunk.has_road(
		Enums.Direction.UP
	):
		return false


	if room.exits.has(
		Enums.Direction.RIGHT
	) != chunk.has_road(
		Enums.Direction.RIGHT
	):
		return false


	return true


# =========================
# 不足Roomパターン取得
# =========================

func get_missing_patterns(
	world: WorldData,
	rooms: Array[RoomData]
) -> Array[String]:

	var result: Array[String] = []

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)

			var candidates: Array[RoomData] = get_candidates(
				chunk,
				rooms
			)

			if not candidates.is_empty():
				continue


			var biome_name: String = "null"

			if chunk.main_biome != null:
				biome_name = chunk.main_biome.display_name


			var pattern: String = (
				biome_name
				+ "_"
				+ get_bit_string(chunk.road_bits)
			)


			if not result.has(pattern):
				result.append(pattern)

	return result


# =========================
# 4bit表示
# =========================

func get_bit_string(
	value: int
) -> String:

	var result: String = ""

	for i in range(3, -1, -1):

		if (value & (1 << i)) != 0:
			result += "1"
		else:
			result += "0"

	return result
