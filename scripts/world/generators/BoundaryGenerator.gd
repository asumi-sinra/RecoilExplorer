extends RefCounted
class_name BoundaryGenerator


# バイオーム境界の最大ズレ
#
# 資料：
# 「境界垂直壁パターンが-1<=x<=1の範囲で決まる」
const MAX_OFFSET: int = 1


# 3バイオームなので境界は2本
const BOUNDARY_COUNT: int = 2


func generate(
	world: WorldData,
	biomes: Array[BiomeData]
) -> void:

	if biomes.size() != 3:
		push_error(
			"BoundaryGenerator: バイオームは3つ必要です。"
		)
		return

	# 各境界について、各行の位置を決める
	var boundaries: Array = []

	for boundary_index in range(BOUNDARY_COUNT):

		var boundary: Array[int] = []

		for y in range(WorldData.HEIGHT):

			var offset: int = randi_range(
				-MAX_OFFSET,
				MAX_OFFSET
			)

			boundary.append(offset)

		boundaries.append(boundary)

	# 各チャンクに主バイオームを設定
	for y in range(WorldData.HEIGHT):

		# 16チャンク幅を3つに分けるため、
		# 中央付近に2本の境界を置く。
		var first_boundary: int = 5
		var second_boundary: int = 10

		var first_x: int = first_boundary + boundaries[0][y]
		var second_x: int = second_boundary + boundaries[1][y]

		# 境界が逆転しないようにする
		if second_x <= first_x:
			second_x = first_x + 1

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			if x < first_x:

				chunk.main_biome = biomes[0]

			elif x < second_x:

				chunk.main_biome = biomes[1]

			else:

				chunk.main_biome = biomes[2]
