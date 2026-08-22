extends RefCounted
class_name GateGenerator


# =========================
# 開始チャンク生成
# =========================

func generate_start_gate(
	world: WorldData
) -> void:

	# 下端中央2マス
	#
	# WIDTH = 16 の場合、
	# x = 7 または x = 8
	var candidates: Array[ChunkData] = []

	var center_left: int = (
		WorldData.WIDTH / 2
	) - 1

	var center_right: int = (
		WorldData.WIDTH / 2
	)

	var left_chunk := world.get_chunk(
		Vector2i(
			center_left,
			WorldData.HEIGHT - 1
		)
	)

	var right_chunk := world.get_chunk(
		Vector2i(
			center_right,
			WorldData.HEIGHT - 1
		)
	)

	candidates.append(left_chunk)
	candidates.append(right_chunk)


	# どちらか一方をランダムに開始地点にする
	var start_chunk: ChunkData = (
		candidates.pick_random()
	)

	start_chunk.is_prev_phase_gate = true


	# 開始地点は下端から入るため、
	# DOWN方向をゲートとして扱う
	start_chunk.add_road(
		Enums.Direction.DOWN
	)


# =========================
# ゴールチャンク生成
# =========================

func generate_goal_gates(
	world: WorldData
) -> void:

	# 使用されているバイオームを取得
	var biomes: Array[BiomeData] = get_used_biomes(
		world
	)


	# 各バイオームにつき1つ
	for biome in biomes:

		var candidates: Array[ChunkData] = []

		# 上端に存在する、このバイオームのチャンクを探す
		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(
					x,
					0
				)
			)

			if chunk.main_biome == biome:

				candidates.append(chunk)


		# 上端にこのバイオームが存在しない場合
		if candidates.is_empty():

			push_error(
				"GateGenerator: 上端に存在するBiomeが見つかりません: "
				+ biome.display_name
			)

			continue


		# ランダムに1チャンク選択
		var goal_chunk: ChunkData = (
			candidates.pick_random()
		)

		goal_chunk.is_next_phase_gate = true


		# 上端から次フェーズへ出るため、
		# UP方向をゲートとして扱う
		goal_chunk.add_road(
			Enums.Direction.UP
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
