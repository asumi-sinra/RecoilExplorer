extends Node2D


# =========================
# 使用するBiome
# =========================

@export var available_biomes: Array[BiomeData]


# =========================
# ワールドデータ
# =========================

var world: WorldData


# =========================
# Generator
# =========================

var biome_generator: BiomeGenerator
var boundary_generator: BoundaryGenerator
var wall_generator: WallGenerator
var road_generator: RoadGenerator


func _ready() -> void:

	print("========== World Generation Start ==========")


	# ---------------------------------
	# WorldData作成
	# ---------------------------------

	world = WorldData.new()
	world.create_empty()

	print("WorldData created.")

	print(
		"Chunk count: ",
		WorldData.WIDTH * WorldData.HEIGHT
	)


	# ---------------------------------
	# Generator作成
	# ---------------------------------

	biome_generator = BiomeGenerator.new()
	boundary_generator = BoundaryGenerator.new()
	wall_generator = WallGenerator.new()
	road_generator = RoadGenerator.new()


	# ---------------------------------
	# ① バイオーム抽選
	# ---------------------------------

	var selected_biomes := biome_generator.generate(
		world,
		available_biomes
	)

	if selected_biomes.size() != 3:

		push_error(
			"Biome generation failed."
		)

		return


	print("Selected biomes:")

	for biome in selected_biomes:

		print(
			"  ",
			biome.display_name
		)


	# ---------------------------------
	# ② バイオーム境界決定
	# ---------------------------------

	boundary_generator.generate(
		world,
		selected_biomes
	)

	print("Biome boundaries generated.")


	# ---------------------------------
	# ③ 壁決定
	# ---------------------------------

	wall_generator.generate(
		world
	)

	print("Walls generated.")


	# ---------------------------------
	# ④ バイオーム内部の道生成
	# ---------------------------------

	road_generator.generate(
		world
	)

	print("Roads generated.")


	# ---------------------------------
	# デバッグ表示
	# ---------------------------------

	print_biomes()

	print_walls()

	print_roads()

	print_road_counts()

	print("========== World Generation End ==========")


# =========================
# バイオーム表示
# =========================

func print_biomes() -> void:

	print("")
	print("----- Biome Map -----")

	for y in range(WorldData.HEIGHT):

		var line := ""

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			if chunk.main_biome == null:

				line += "?"

			else:

				var index := get_biome_index(
					chunk.main_biome
				)

				line += str(index)

			line += " "

		print(line)


# =========================
# バイオーム番号取得
# =========================

func get_biome_index(
	biome: BiomeData
) -> int:

	for i in range(available_biomes.size()):

		if available_biomes[i] == biome:

			return i

	return -1


# =========================
# 壁表示
# =========================

func print_walls() -> void:

	print("")
	print("----- Wall Map -----")

	for y in range(WorldData.HEIGHT):

		var line := ""

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			line += get_bit_string(
				chunk.wall_bits
			)

			line += " "

		print(line)


# =========================
# 道表示
# =========================

func print_roads() -> void:

	print("")
	print("----- Road Map -----")

	for y in range(WorldData.HEIGHT):

		var line := ""

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			line += get_bit_string(
				chunk.road_bits
			)

			line += " "

		print(line)


# =========================
# 道本数表示
# =========================

func print_road_counts() -> void:

	print("")
	print("----- Road Count Map -----")

	for y in range(WorldData.HEIGHT):

		var line := ""

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			line += str(
				chunk.road_count
			)

			line += " "

		print(line)


# =========================
# 4bit表示
# =========================

func get_bit_string(
	value: int
) -> String:

	var result := ""

	for i in range(3, -1, -1):

		if (value & (1 << i)) != 0:

			result += "1"

		else:

			result += "0"

	return result
