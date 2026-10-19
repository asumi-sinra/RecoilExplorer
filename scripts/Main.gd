extends Node2D


## =========================
## 使用するBiome
## =========================

@export var available_biomes: Array[BiomeData]


## =========================
## デバッグRoom設定
## =========================

@export var debug_room_mode: bool = true
@export var debug_room_scene: PackedScene


## =========================
## Player
## =========================

var player: CharacterBody2D = null


## =========================
## 実行用Biome
## =========================

var runtime_biomes: Array[BiomeData] = []


## =========================
## ワールド
## =========================

var world: WorldData


## =========================
## Room管理
## =========================

var room_manager: RoomManager
var transition_layer: TransitionLayer
var room_validator: RoomValidator
var debug_room_factory: DebugRoomFactory


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
	## Player取得
	## ---------------------------------

	var player_node: Node = get_node_or_null("Player")

	if player_node == null:
		push_error("Main: 子ノードPlayerが見つかりません。")
		return

	if not player_node is CharacterBody2D:
		push_error("Main: PlayerはCharacterBody2Dではありません。")
		return

	player = player_node as CharacterBody2D

	if not player.is_in_group("player"):
		player.add_to_group("player")

	print("Player found: ", player.get_path())


	## ---------------------------------
	## WorldData作成
	## ---------------------------------

	world = WorldData.new()
	world.create_empty()

	print("WorldData created.")
	print("Chunk count: ", WorldData.WIDTH * WorldData.HEIGHT)


	## ---------------------------------
	## Generator作成
	## ---------------------------------

	biome_generator = BiomeGenerator.new()
	boundary_generator = BoundaryGenerator.new()
	wall_generator = WallGenerator.new()
	road_generator = RoadGenerator.new()
	inter_biome_generator = InterBiomeGenerator.new()
	gate_generator = GateGenerator.new()

	room_validator = RoomValidator.new()
	debug_room_factory = DebugRoomFactory.new()

	var room_generator_script = preload(
		"res://scripts/world/generators/RoomGenerator.gd"
	)

	room_generator = room_generator_script.new()


	## ---------------------------------
	## ① 実行用Biome準備
	## ---------------------------------

	if not prepare_runtime_biomes():
		return


	## ---------------------------------
	## ② デバッグ用RoomData生成
	## ---------------------------------

	if debug_room_mode:

		if debug_room_scene == null:
			push_error(
				"Main: Debug Room ModeがONですが、"
				+ "Debug Room Sceneが設定されていません。"
			)
			return

		var generated: bool = (
			debug_room_factory.populate_biome_rooms(
				runtime_biomes,
				debug_room_scene
			)
		)

		if not generated:
			push_error("Main: デバッグRoomの生成に失敗しました。")
			return


	## ---------------------------------
	## ③ RoomData検査
	## ---------------------------------

	var rooms_valid: bool = (
		room_validator.validate_all(
			runtime_biomes
		)
	)

	if not rooms_valid:
		push_error(
			"Main: RoomDataまたはRoomシーンに不整合があります。"
		)
		push_error("Main: マップ生成を中止します。")
		return


	## ---------------------------------
	## ④ バイオーム抽選
	## ---------------------------------

	var selected_biomes: Array[BiomeData] = (
		biome_generator.generate(
			world,
			runtime_biomes
		)
	)

	if selected_biomes.size() != 3:
		push_error("Main: バイオーム抽選に失敗しました。")
		return

	print("Selected biomes:")

	for biome in selected_biomes:
		print("  ", biome.display_name)


	## ---------------------------------
	## ⑤ バイオーム境界決定
	## ---------------------------------

	boundary_generator.generate(
		world,
		selected_biomes
	)

	print("Biome boundaries generated.")


	## ---------------------------------
	## ⑥ 壁決定
	## ---------------------------------

	wall_generator.generate(world)

	print("Walls generated.")


	## ---------------------------------
	## ⑦ バイオーム内部の道生成
	## ---------------------------------

	road_generator.generate(world)

	print("Roads generated.")


	## ---------------------------------
	## ⑧ バイオーム間通路生成
	## ---------------------------------

	inter_biome_generator.generate(
		world,
		selected_biomes
	)

	print("Inter-biome passages generated.")


	## ---------------------------------
	## ⑨ 開始・ゴールゲート生成
	## ---------------------------------

	gate_generator.generate_start_gate(world)
	gate_generator.generate_goal_gates(world)

	print("Start and goal gates generated.")


	## ---------------------------------
	## ⑩ RoomData割り当て
	## ---------------------------------

	var assigned_room_count: int = (
		room_generator.generate(world)
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
	## ⑪ TransitionLayer作成
	## ---------------------------------

	transition_layer = TransitionLayer.new()
	transition_layer.name = "TransitionLayer"
	add_child(transition_layer)


	## ---------------------------------
	## ⑫ RoomManager作成
	## ---------------------------------

	room_manager = RoomManager.new()
	room_manager.name = "RoomManager"
	add_child(room_manager)

	room_manager.set_player(player)
	room_manager.set_transition_layer(transition_layer)

	room_manager.phase_exit_requested.connect(
		_on_phase_exit_requested
	)


	## ---------------------------------
	## ⑬ 初期Roomをロード
	## ---------------------------------

	var initial_chunk: ChunkData = get_initial_chunk()

	if initial_chunk == null:
		push_error("Main: ロード可能なRoomがありません。")
		return

	var initialized: bool = (
		room_manager.initialize(
			world,
			initial_chunk
		)
	)

	if not initialized:
		push_error("Main: RoomManagerの初期化に失敗しました。")
		return

	print("Initial playable chunk: ", initial_chunk.coord)
	print("Initial room: ", initial_chunk.room.display_name)
	print("Debug Room Mode: ", debug_room_mode)

	print("========== World Generation End ==========")


## =========================
## 実行用Biome準備
## =========================

func prepare_runtime_biomes() -> bool:

	runtime_biomes.clear()

	if available_biomes.size() < 3:
		push_error("Main: Available Biomesには3種類以上必要です。")
		return false

	for source_biome in available_biomes:

		if source_biome == null:
			push_error("Main: nullのBiomeDataがあります。")
			return false

		if debug_room_mode:

			## 元の.tresは変更しない
			var runtime_biome: BiomeData = BiomeData.new()

			runtime_biome.display_name = source_biome.display_name
			runtime_biome.background_color = source_biome.background_color

			runtime_biomes.append(runtime_biome)

		else:

			## 通常モードでは登録済みRoomDataを使用
			runtime_biomes.append(source_biome)

	return true


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

			if fallback_chunk == null and chunk.room != null:
				fallback_chunk = chunk

	if start_gate != null and start_gate.room != null:
		return start_gate

	if start_gate != null:
		print(
			"DEBUG: Start Gateに対応するRoomがありません。"
		)
		print(
			"DEBUG: 一時的に別の割り当て済みRoomから開始します。"
		)

	return fallback_chunk


## =========================
## デバッグ用Room切り替え
## 現在は無効
## =========================

## func _unhandled_input(event: InputEvent) -> void:
##
## 	if room_manager == null:
## 		return
##
## 	if event.is_action_pressed("ui_left"):
## 		room_manager.request_transition(Enums.Direction.LEFT)
## 		return
##
## 	if event.is_action_pressed("ui_right"):
## 		room_manager.request_transition(Enums.Direction.RIGHT)
## 		return
##
## 	if event.is_action_pressed("ui_up"):
## 		room_manager.request_transition(Enums.Direction.UP)
## 		return
##
## 	if event.is_action_pressed("ui_down"):
## 		room_manager.request_transition(Enums.Direction.DOWN)


## =========================
## Phase遷移
## =========================

func _on_phase_exit_requested(
	direction: int,
	from_chunk: Vector2i
) -> void:

	print(
		"Main: Phase transition requested. direction=",
		get_direction_name(direction),
		" from_chunk=",
		from_chunk
	)

	print("Main: Phase切り替え処理は未実装です。")


## =========================
## バイオーム番号取得
## =========================

func get_biome_index(
	biome: BiomeData
) -> int:

	for i in range(runtime_biomes.size()):
		if runtime_biomes[i] == biome:
			return i

	return -1


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
				line += str(get_biome_index(chunk.main_biome))

			line += " "

		print(line)


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

			line += get_bit_string(chunk.wall_bits)
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

			line += get_bit_string(chunk.road_bits)
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

			line += str(chunk.road_count)
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
## バイオーム境界チャンク表示
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
				chunk.sub_biome.display_name,
				"  direction=",
				get_direction_name(chunk.sub_biome_direction)
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
		room_generator.get_missing_patterns(world)
	)

	if missing_patterns.is_empty():
		print("None")
		print("All chunks have matching RoomData.")
		return

	for pattern in missing_patterns:
		print("  ", pattern)


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
