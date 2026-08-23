extends Node2D


## =========================
## 使用するBiome
## =========================

@export var available_biomes: Array[BiomeData]


## =========================
## 使用するRoom
## =========================

@export var available_rooms: Array[RoomData]


## =========================
## ワールドデータ
## =========================

var world: WorldData


## =========================
## Generator
## =========================

var biome_generator: BiomeGenerator
var boundary_generator: BoundaryGenerator
var wall_generator: WallGenerator
var road_generator: RoadGenerator
var inter_biome_generator: InterBiomeGenerator
var gate_generator: GateGenerator

var room_generator


func _ready() -> void:

	print("========== World Generation Start ==========")


	## ---------------------------------
	## WorldData作成
	## ---------------------------------

	world = WorldData.new()
	world.create_empty()

	print("WorldData created.")

	print(
		"Chunk count: ",
		WorldData.WIDTH * WorldData.HEIGHT
	)


	## ---------------------------------
	## Generator作成
	## ---------------------------------

	biome_generator = BiomeGenerator.new()
	boundary_generator = BoundaryGenerator.new()
	wall_generator = WallGenerator.new()
	road_generator = RoadGenerator.new()
	inter_biome_generator = InterBiomeGenerator.new()
	gate_generator = GateGenerator.new()


	var room_generator_script = preload(
		"res://scripts/world/generators/RoomGenerator.gd"
	)

	room_generator = room_generator_script.new()


	## ---------------------------------
	## ① バイオーム抽選
	## ---------------------------------

	var selected_biomes: Array[BiomeData] = (
		biome_generator.generate(
			world,
			available_biomes
		)
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


	## ---------------------------------
	## ② バイオーム境界決定
	## ---------------------------------

	boundary_generator.generate(
		world,
		selected_biomes
	)

	print("Biome boundaries generated.")


	## ---------------------------------
	## ③ 壁決定
	## ---------------------------------

	wall_generator.generate(
		world
	)

	print("Walls generated.")


	## ---------------------------------
	## ④ バイオーム内部の道生成
	## ---------------------------------

	road_generator.generate(
		world
	)

	print("Roads generated.")


	## ---------------------------------
	## ⑤ バイオーム間通路生成
	## ---------------------------------

	inter_biome_generator.generate(
		world,
		selected_biomes
	)

	print("Inter-biome passages generated.")


	## ---------------------------------
	## ⑥ 開始チャンク生成
	## ---------------------------------

	gate_generator.generate_start_gate(
		world
	)

	print("Start gate generated.")


	## ---------------------------------
	## ⑦ ゴールチャンク生成
	## ---------------------------------

	gate_generator.generate_goal_gates(
		world
	)

	print("Goal gates generated.")


	## ---------------------------------
	## ⑧ Room割り当て
	## ---------------------------------

	var assigned_room_count: int = (
		room_generator.generate(
			world,
			available_rooms
		)
	)

	print(
		"Rooms assigned: ",
		assigned_room_count,
		" / ",
		WorldData.WIDTH * WorldData.HEIGHT
	)


	## ---------------------------------
	## デバッグ表示
	## ---------------------------------

	print_biomes()
	print_walls()
	print_roads()
	print_road_counts()
	print_gates()
	print_transition_chunks()
	print_rooms()
	print_missing_room_patterns()

	print("========== World Generation End ==========")


## =========================
## バイオーム表示
## =========================

func print_biomes() -> void:

	print("")
	print("----- Biome Map -----")

	for y in range(WorldData.HEIGHT):

		var line: String = ""

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)

			if chunk.main_biome == null:

				line += "?"

			else:

				var index: int = get_biome_index(
					chunk.main_biome
				)

				line += str(index)

			line += " "

		print(line)


## =========================
## バイオーム番号取得
## =========================

func get_biome_index(
	biome: BiomeData
) -> int:

	for i in range(available_biomes.size()):

		if available_biomes[i] == biome:
			return i

	return -1


## =========================
## 壁表示
## =========================

func print_walls() -> void:

	print("")
	print("----- Wall Map -----")

	for y in range(WorldData.HEIGHT):

		var line: String = ""

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)

			line += get_bit_string(
				chunk.wall_bits
			)

			line += " "

		print(line)


## =========================
## 道表示
## =========================

func print_roads() -> void:

	print("")
	print("----- Road Map -----")

	for y in range(WorldData.HEIGHT):

		var line: String = ""

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)

			line += get_bit_string(
				chunk.road_bits
			)

			line += " "

		print(line)


## =========================
## 道本数表示
## =========================

func print_road_counts() -> void:

	print("")
	print("----- Road Count Map -----")

	for y in range(WorldData.HEIGHT):

		var line: String = ""

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)

			line += str(
				chunk.road_count
			)

			line += " "

		print(line)


## =========================
## ゲート表示
## =========================

func print_gates() -> void:

	print("")
	print("----- Gate Map -----")

	for y in range(WorldData.HEIGHT):

		var line: String = ""

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)

			var symbol: String = "."

			if chunk.is_prev_phase_gate:
				symbol = "S"

			if chunk.is_next_phase_gate:
				symbol = "G"

			line += symbol
			line += " "

		print(line)


## =========================
## バイオーム境界Room表示
## =========================

func print_transition_chunks() -> void:

	print("")
	print("----- Inter-Biome Transition Chunks -----")

	var found: bool = false

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)

			if chunk.sub_biome == null:
				continue

			found = true

			print(
				"  ",
				chunk.coord,
				"  ",
				chunk.main_biome.display_name,
				" -> ",
				chunk.sub_biome.display_name
			)


	if not found:
		print("None")


## =========================
## Room表示
## =========================

func print_rooms() -> void:

	print("")
	print("----- Room Map -----")

	for y in range(WorldData.HEIGHT):

		var line: String = ""

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)

			if chunk.room == null:

				line += "----"

			else:

				line += chunk.room.display_name

			line += " | "

		print(line)


## =========================
## 不足Room表示
## =========================

func print_missing_room_patterns() -> void:

	print("")
	print("----- Missing Room Patterns -----")

	var missing_patterns: Array[String] = (
		room_generator.get_missing_patterns(
			world,
			available_rooms
		)
	)

	if missing_patterns.is_empty():

		print("None")
		print("All chunks have matching RoomData.")

		return


	for pattern in missing_patterns:

		print(
			"  ",
			pattern
		)


## =========================
## 4bit表示
## =========================

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
