extends RefCounted
class_name RoadGenerator


# =========================
# 道生成
# =========================

func generate(world: WorldData) -> void:

	# 3つのバイオームそれぞれについて道を生成する
	var biomes: Array[BiomeData] = get_used_biomes(world)

	for biome in biomes:

		generate_biome_roads(
			world,
			biome
		)


# =========================
# 使用されているBiome取得
# =========================

func get_used_biomes(
	world: WorldData
) -> Array[BiomeData]:

	var result: Array[BiomeData] = []

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			if chunk.main_biome == null:
				continue

			if not result.has(chunk.main_biome):

				result.append(
					chunk.main_biome
				)

	return result


# =========================
# 1バイオーム分の道生成
# =========================

func generate_biome_roads(
	world: WorldData,
	biome: BiomeData
) -> void:

	var biome_chunks: Array[ChunkData] = []

	# このバイオームに属するチャンクを取得
	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			if chunk.main_biome == biome:

				biome_chunks.append(chunk)


	if biome_chunks.is_empty():

		return


	# -------------------------
	# 始点を1つ決定
	# -------------------------

	var start_chunk: ChunkData = biome_chunks.pick_random()


	# -------------------------
	# 始点から最初の道を伸ばす
	# -------------------------

	var first_directions: Array[Enums.Direction] = []

	for dir in get_directions():

		if can_extend(
			world,
			start_chunk,
			dir,
			biome
		):

			first_directions.append(dir)


	if first_directions.is_empty():

		push_error(
			"RoadGenerator: 始点から道を伸ばせませんでした。"
		)

		return


	var first_direction: Enums.Direction = (
		first_directions.pick_random()
	)

	extend_road(
		world,
		start_chunk,
		first_direction
	)


	# -------------------------
	# 道を伸ばし続ける
	# -------------------------

	while has_unconnected_chunk(biome_chunks):

		var candidates: Array[ChunkData] = []

		var candidate_directions: Dictionary = {}


		# 道があり、さらに道を伸ばせるチャンクを探す
		for chunk in biome_chunks:

			if chunk.road_count <= 0:
				continue


			var directions: Array[Enums.Direction] = []

			for dir in get_directions():

				if can_extend(
					world,
					chunk,
					dir,
					biome
				):

					directions.append(dir)


			if not directions.is_empty():

				candidates.append(chunk)

				candidate_directions[chunk] = directions


		# 伸ばせるチャンクがない場合
		if candidates.is_empty():

			push_error(
				"RoadGenerator: 道を全チャンクに通せませんでした。"
			)

			return


		# -------------------------
		# 最小の道本数を求める
		# -------------------------

		var minimum_road_count: int = 4

		for chunk in candidates:

			if chunk.road_count < minimum_road_count:

				minimum_road_count = chunk.road_count


		# -------------------------
		# 最小の道本数を持つ
		# チャンクだけに絞る
		# -------------------------

		var minimum_candidates: Array[ChunkData] = []

		for chunk in candidates:

			if chunk.road_count == minimum_road_count:

				minimum_candidates.append(chunk)


		# -------------------------
		# 対象チャンクをランダム選択
		# -------------------------

		var target_chunk: ChunkData = (
			minimum_candidates.pick_random()
		)


		# -------------------------
		# 伸ばせる方向をランダム選択
		# -------------------------

		var directions: Array[Enums.Direction] = (
			candidate_directions[target_chunk]
		)

		var direction: Enums.Direction = (
			directions.pick_random()
		)


		# -------------------------
		# 道を伸ばす
		# -------------------------

		extend_road(
			world,
			target_chunk,
			direction
		)


# =========================
# 道を伸ばせるか
# =========================

func can_extend(
	world: WorldData,
	chunk: ChunkData,
	dir: Enums.Direction,
	biome: BiomeData
) -> bool:

	# 現在のチャンクに壁があるなら不可
	if chunk.has_wall(dir):

		return false


	# 隣のチャンクを取得
	var neighbor := world.get_neighbor(
		chunk,
		dir
	)

	if neighbor == null:

		return false


	# 別バイオームには伸ばさない
	if neighbor.main_biome != biome:

		return false


	# 隣のチャンクにすでに道があるなら不可
	if neighbor.road_count > 0:

		return false


	# ここまで来れば伸ばせる
	return true


# =========================
# 道を実際に伸ばす
# =========================

func extend_road(
	world: WorldData,
	chunk: ChunkData,
	dir: Enums.Direction
) -> void:

	var neighbor := world.get_neighbor(
		chunk,
		dir
	)

	if neighbor == null:

		return


	# 現在のチャンクに道を追加
	chunk.add_road(dir)


	# 隣のチャンクには反対方向の道を追加
	var opposite := get_opposite_direction(
		dir
	)

	neighbor.add_road(opposite)


# =========================
# 反対方向
# =========================

func get_opposite_direction(
	dir: Enums.Direction
) -> Enums.Direction:

	match dir:

		Enums.Direction.DOWN:
			return Enums.Direction.UP

		Enums.Direction.LEFT:
			return Enums.Direction.RIGHT

		Enums.Direction.UP:
			return Enums.Direction.DOWN

		Enums.Direction.RIGHT:
			return Enums.Direction.LEFT

	return Enums.Direction.DOWN


# =========================
# 未接続チャンクがあるか
# =========================

func has_unconnected_chunk(
	chunks: Array[ChunkData]
) -> bool:

	for chunk in chunks:

		if chunk.road_count == 0:

			return true

	return false


# =========================
# 4方向
# =========================

func get_directions() -> Array[Enums.Direction]:

	return [
		Enums.Direction.DOWN,
		Enums.Direction.LEFT,
		Enums.Direction.UP,
		Enums.Direction.RIGHT
	]
