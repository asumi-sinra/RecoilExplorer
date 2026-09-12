extends RefCounted
class_name InterBiomeGenerator


## =========================
## バイオーム間通路生成
## =========================

func generate(
	world: WorldData,
	biomes: Array[BiomeData]
) -> void:

	if biomes.size() != 3:

		push_error(
			"InterBiomeGenerator: バイオームは3つ必要です。"
		)

		return


	create_passage(
		world,
		biomes[0],
		biomes[1]
	)


	create_passage(
		world,
		biomes[1],
		biomes[2]
	)


## =========================
## 指定Biome間に通路を1つ作る
## =========================

func create_passage(
	world: WorldData,
	biome_a: BiomeData,
	biome_b: BiomeData
) -> void:

	var candidates: Array[Vector4i] = []


	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var current: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)


			## -------------------------
			## 右隣
			## -------------------------

			if x < WorldData.WIDTH - 1:

				var right: ChunkData = world.get_chunk(
					Vector2i(x + 1, y)
				)


				if is_target_biome_pair(
					current,
					right,
					biome_a,
					biome_b
				):

					candidates.append(
						Vector4i(
							current.coord.x,
							current.coord.y,
							right.coord.x,
							right.coord.y
						)
					)


			## -------------------------
			## 下隣
			## -------------------------

			if y < WorldData.HEIGHT - 1:

				var down: ChunkData = world.get_chunk(
					Vector2i(x, y + 1)
				)


				if is_target_biome_pair(
					current,
					down,
					biome_a,
					biome_b
				):

					candidates.append(
						Vector4i(
							current.coord.x,
							current.coord.y,
							down.coord.x,
							down.coord.y
						)
					)


	if candidates.is_empty():

		push_error(
			"InterBiomeGenerator: "
			+ biome_a.display_name
			+ " と "
			+ biome_b.display_name
			+ " の境界が見つかりません。"
		)

		return


	var selected: Vector4i = (
		candidates.pick_random()
	)


	var first: ChunkData = world.get_chunk(
		Vector2i(
			selected.x,
			selected.y
		)
	)


	var second: ChunkData = world.get_chunk(
		Vector2i(
			selected.z,
			selected.w
		)
	)


	open_passage(
		first,
		second
	)


	print(
		"Inter-biome passage: ",
		biome_a.display_name,
		" <-> ",
		biome_b.display_name,
		"  ",
		first.coord,
		" <-> ",
		second.coord
	)


## =========================
## 対象Biomeの組み合わせか
## =========================

func is_target_biome_pair(
	chunk_a: ChunkData,
	chunk_b: ChunkData,
	biome_a: BiomeData,
	biome_b: BiomeData
) -> bool:

	if (
		chunk_a.main_biome == biome_a
		and chunk_b.main_biome == biome_b
	):

		return true


	if (
		chunk_a.main_biome == biome_b
		and chunk_b.main_biome == biome_a
	):

		return true


	return false


## =========================
## 2Chunk間の壁を開ける
## =========================

func open_passage(
	chunk_a: ChunkData,
	chunk_b: ChunkData
) -> void:

	var delta: Vector2i = (
		chunk_b.coord
		- chunk_a.coord
	)


	## -------------------------
	## BがAの右
	## -------------------------

	if delta == Vector2i.RIGHT:

		chunk_a.remove_wall(
			Enums.Direction.RIGHT
		)

		chunk_b.remove_wall(
			Enums.Direction.LEFT
		)


		chunk_a.add_road(
			Enums.Direction.RIGHT
		)

		chunk_b.add_road(
			Enums.Direction.LEFT
		)


		set_biome_transition(
			chunk_a,
			Enums.Direction.RIGHT,
			chunk_b,
			Enums.Direction.LEFT
		)


	## -------------------------
	## BがAの左
	## -------------------------

	elif delta == Vector2i.LEFT:

		chunk_a.remove_wall(
			Enums.Direction.LEFT
		)

		chunk_b.remove_wall(
			Enums.Direction.RIGHT
		)


		chunk_a.add_road(
			Enums.Direction.LEFT
		)

		chunk_b.add_road(
			Enums.Direction.RIGHT
		)


		set_biome_transition(
			chunk_a,
			Enums.Direction.LEFT,
			chunk_b,
			Enums.Direction.RIGHT
		)


	## -------------------------
	## BがAの下
	## -------------------------

	elif delta == Vector2i.DOWN:

		chunk_a.remove_wall(
			Enums.Direction.DOWN
		)

		chunk_b.remove_wall(
			Enums.Direction.UP
		)


		chunk_a.add_road(
			Enums.Direction.DOWN
		)

		chunk_b.add_road(
			Enums.Direction.UP
		)


		set_biome_transition(
			chunk_a,
			Enums.Direction.DOWN,
			chunk_b,
			Enums.Direction.UP
		)


	## -------------------------
	## BがAの上
	## -------------------------

	elif delta == Vector2i.UP:

		chunk_a.remove_wall(
			Enums.Direction.UP
		)

		chunk_b.remove_wall(
			Enums.Direction.DOWN
		)


		chunk_a.add_road(
			Enums.Direction.UP
		)

		chunk_b.add_road(
			Enums.Direction.DOWN
		)


		set_biome_transition(
			chunk_a,
			Enums.Direction.UP,
			chunk_b,
			Enums.Direction.DOWN
		)


	else:

		push_error(
			"InterBiomeGenerator: "
			+ "隣接していないChunkが指定されました。"
		)


## =========================
## 境界Biome情報を設定
## =========================

func set_biome_transition(
	chunk_a: ChunkData,
	direction_a: Enums.Direction,
	chunk_b: ChunkData,
	direction_b: Enums.Direction
) -> void:

	chunk_a.sub_biome = (
		chunk_b.main_biome
	)

	chunk_a.sub_biome_direction = (
		int(direction_a)
	)


	chunk_b.sub_biome = (
		chunk_a.main_biome
	)

	chunk_b.sub_biome_direction = (
		int(direction_b)
	)
