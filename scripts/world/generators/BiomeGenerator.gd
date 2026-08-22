extends RefCounted
class_name BiomeGenerator


# 1フェーズで使用するバイオーム数
const BIOME_COUNT := 3


func generate(
	world: WorldData,
	available_biomes: Array[BiomeData]
) -> Array[BiomeData]:

	if available_biomes.size() < BIOME_COUNT:
		push_error(
			"BiomeGenerator: 3種類以上のBiomeDataが必要です。"
		)
		return []

	var selected_biomes := available_biomes.duplicate()

	selected_biomes.shuffle()

	selected_biomes = selected_biomes.slice(
		0,
		BIOME_COUNT
	)

	# 各チャンクの主バイオームを決定する
	#
	# 今回は3バイオームを左→中央→右に配置する。
	# 境界の位置はBoundaryGeneratorが決定する。
	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			chunk.main_biome = null
			chunk.sub_biome = null

	return selected_biomes
