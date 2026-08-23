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
## Player
## =========================

@onready var player: CharacterBody2D = $Player


## =========================
## ワールドデータ
## =========================

var world: WorldData


## =========================
## Room管理
## =========================

var room_manager: RoomManager
var transition_layer: TransitionLayer


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
	## Player設定
	## ---------------------------------

	if not player.is_in_group(
		"player"
	):

		player.add_to_group(
			"player"
		)


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
	## ⑧ RoomData割り当て
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


	## ---------------------------------
	## ⑨ TransitionLayer作成
	## ---------------------------------

	transition_layer = TransitionLayer.new()
	transition_layer.name = "TransitionLayer"

	add_child(
		transition_layer
	)


	## ---------------------------------
	## ⑩ RoomManager作成
	## ---------------------------------

	room_manager = RoomManager.new()
	room_manager.name = "RoomManager"

	add_child(
		room_manager
	)


	room_manager.set_player(
		player
	)


	room_manager.set_transition_layer(
		transition_layer
	)


	room_manager.phase_exit_requested.connect(
		_on_phase_exit_requested
	)


	## ---------------------------------
	## 最初に表示するRoom取得
	## ---------------------------------

	var initial_chunk: ChunkData = (
		get_initial_chunk()
	)


	if initial_chunk == null:

		push_error(
			"Main: ロード可能なRoomが1つもありません。"
		)

		return


	var initialized: bool = (
		room_manager.initialize(
			world,
			initial_chunk
		)
	)


	if not initialized:

		push_error(
			"Main: RoomManagerの初期化に失敗しました。"
		)

		return


	print("")
	print(
		"Initial playable chunk: ",
		initial_chunk.coord
	)

	print(
		"Initial room: ",
		initial_chunk.room.display_name
	)

	print("")
	print(
		"PlayerはRoomExitに触れると隣Roomへ移動します。"
	)

	print(
		"矢印キーによるデバッグ遷移も引き続き使用できます。"
	)


	print("========== World Generation End ==========")


## =========================
## デバッグ用
## 矢印キー = RoomExitと同じ処理
## =========================

#func _unhandled_input(
#	event: InputEvent
#) -> void:
#
#	if room_manager == null:
#		return


#	if event.is_action_pressed(
#		"ui_left"
#	):
#
#		room_manager.request_transition(
#			Enums.Direction.LEFT
#		)
#
#		return
#
#
#	if event.is_action_pressed(
#		"ui_right"
#	):
#
#		room_manager.request_transition(
#			Enums.Direction.RIGHT
#		)
#
#		return
#
#
#	if event.is_action_pressed(
#		"ui_up"
#	):
#
#		room_manager.request_transition(
#			Enums.Direction.UP
#		)
#
#		return
#
#
#	if event.is_action_pressed(
#		"ui_down"
#	):
#
#		room_manager.request_transition(
#			Enums.Direction.DOWN
#		)


## =========================
## 最初に表示するChunk取得
## =========================

func get_initial_chunk() -> ChunkData:

	var start_gate: ChunkData = null
	var fallback_chunk: ChunkData = null


	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)


			if chunk.is_prev_phase_gate:

				start_gate = chunk


			if (
				fallback_chunk == null
				and chunk.room != null
			):

				fallback_chunk = chunk


	## -------------------------
	## 本来の開始Chunk
	## -------------------------

	if (
		start_gate != null
		and start_gate.room != null
	):

		return start_gate


	## -------------------------
	## 開発中用Fallback
	## -------------------------

	if start_gate != null:

		print(
			"DEBUG: Start Gateに対応するRoomDataがまだありません。"
		)

		print(
			"DEBUG: 一時的に別の割り当て済みRoomから開始します。"
		)


	return fallback_chunk


## =========================
## Phase遷移
## =========================

func _on_phase_exit_requested(
	direction: int,
	from_chunk: Vector2i
) -> void:

	print(
		"Main: Phase transition requested. ",
		"direction=",
		get_direction_name(
			direction
		),
		" from_chunk=",
		from_chunk
	)

	print(
		"Main: Phase切り替え処理は今後ここに実装します。"
	)


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

		print(
			"All chunks have matching RoomData."
		)

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


## =========================
## Direction名
## =========================

func get_direction_name(
	direction: int
) -> String:

	match direction:

		Enums.Direction.DOWN:

			return "DOWN"


		Enums.Direction.LEFT:

			return "LEFT"


		Enums.Direction.UP:

			return "UP"


		Enums.Direction.RIGHT:

			return "RIGHT"


	return "NONE"
