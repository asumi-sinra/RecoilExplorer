extends Node2D
class_name RoomManager


signal room_loaded(
	chunk_coord: Vector2i,
	room_name: String
)


signal phase_exit_requested(
	direction: int,
	from_chunk: Vector2i
)


## =========================
## World
## =========================

var world: WorldData = null


## =========================
## 現在位置
## =========================

var current_chunk: ChunkData = null

var current_room: RoomScene = null


## =========================
## Player
## =========================

var player: Node2D = null


## =========================
## Transition
## =========================

var transition_layer: TransitionLayer = null


## =========================
## 遷移中フラグ
## =========================

var is_transitioning: bool = false


## =========================
## 初期化
## =========================

func initialize(
	world_data: WorldData,
	initial_chunk: ChunkData
) -> bool:

	world = world_data


	if initial_chunk == null:

		push_error(
			"RoomManager: initial_chunkがnullです。"
		)

		return false


	return load_chunk(
		initial_chunk,
		-1
	)


## =========================
## Player登録
## =========================

func set_player(
	player_node: Node2D
) -> void:

	player = player_node


## =========================
## TransitionLayer登録
## =========================

func set_transition_layer(
	layer_node: TransitionLayer
) -> void:

	transition_layer = layer_node


## =========================
## 指定Chunkをロード
## =========================

func load_chunk(
	chunk: ChunkData,
	entry_side: int = -1
) -> bool:

	if chunk == null:

		push_error(
			"RoomManager: 読み込むChunkがnullです。"
		)

		return false


	if chunk.room == null:

		push_error(
			"RoomManager: ChunkにRoomDataがありません。 "
			+ "chunk="
			+ str(chunk.coord)
		)

		return false


	if chunk.room.scene == null:

		push_error(
			"RoomManager: RoomDataにSceneがありません。 "
			+ "room="
			+ chunk.room.display_name
		)

		return false


	## -------------------------
	## 新しいRoom生成
	## -------------------------

	var instance: Node = (
		chunk.room.scene.instantiate()
	)


	if not instance is RoomScene:

		push_error(
			"RoomManager: "
			+ chunk.room.display_name
			+ " のルートにRoom.gdをアタッチしてください。"
		)

		instance.free()

		return false


	var new_room: RoomScene = (
		instance as RoomScene
	)


	## -------------------------
	## 古いRoom削除
	## -------------------------

	if current_room != null:

		current_room.queue_free()


	## -------------------------
	## 新しいRoom追加
	##
	## 全Roomを原点に置く
	## -------------------------

	new_room.position = Vector2.ZERO

	add_child(
		new_room
	)


	current_room = new_room
	current_chunk = chunk


	## -------------------------
	## Exit通知
	## -------------------------

	current_room.exit_requested.connect(
		_on_room_exit_requested
	)


	## -------------------------
	## Player入室位置
	## -------------------------

	if (
		player != null
		and entry_side >= 0
	):

		var spawn_marker: Marker2D = (
			current_room.get_spawn_marker(
				entry_side
			)
		)


		if spawn_marker == null:

			push_error(
				"RoomManager: 入室用SpawnPointがありません。 "
				+ "room="
				+ chunk.room.display_name
				+ " entry_side="
				+ get_direction_name(
					entry_side
				)
			)


		else:

			player.global_position = (
				spawn_marker.global_position
			)


	print(
		"RoomManager: loaded ",
		chunk.room.display_name,
		"  chunk=",
		chunk.coord,
		"  entry=",
		get_direction_name(
			entry_side
		)
	)


	room_loaded.emit(
		chunk.coord,
		chunk.room.display_name
	)


	return true


## =========================
## RoomExitから遷移要求
## =========================

func _on_room_exit_requested(
	direction: Enums.Direction
) -> void:

	request_transition(
		direction
	)


## =========================
## 隣Roomへ遷移
## =========================

func request_transition(
	direction: Enums.Direction
) -> void:

	if is_transitioning:
		return


	if world == null:
		return


	if current_chunk == null:
		return


	## -------------------------
	## その方向に道があるか
	## -------------------------

	if not current_chunk.has_road(
		direction
	):

		print(
			"RoomManager: この方向には道がありません。 ",
			get_direction_name(
				direction
			)
		)

		return


	## -------------------------
	## 隣Chunk取得
	## -------------------------

	var next_chunk: ChunkData = (
		world.get_neighbor(
			current_chunk,
			direction
		)
	)


	## -------------------------
	## マップ外
	## -------------------------

	if next_chunk == null:

		if is_phase_exit(
			direction
		):

			print(
				"RoomManager: Phase exit requested. ",
				get_direction_name(
					direction
				),
				" from ",
				current_chunk.coord
			)


			phase_exit_requested.emit(
				int(direction),
				current_chunk.coord
			)


		else:

			push_warning(
				"RoomManager: 道がありますが隣Chunkがありません。 "
				+ "chunk="
				+ str(current_chunk.coord)
			)


		return


	## -------------------------
	## 遷移先RoomData確認
	## -------------------------

	if next_chunk.room == null:

		print(
			"RoomManager: 遷移先に対応RoomDataがまだありません。 ",
			"chunk=",
			next_chunk.coord
		)

		return


	## -------------------------
	## 次Roomの入口方向
	## -------------------------

	var entry_side: Enums.Direction = (
		get_opposite_direction(
			direction
		)
	)


	## -------------------------
	## 遷移開始
	## -------------------------

	is_transitioning = true


	var previous_process_mode: int = (
		Node.PROCESS_MODE_INHERIT
	)


	if player != null:

		previous_process_mode = (
			player.process_mode
		)

		player.process_mode = (
			Node.PROCESS_MODE_DISABLED
		)


	## -------------------------
	## 暗転
	## -------------------------

	if transition_layer != null:

		await transition_layer.fade_out()


	## -------------------------
	## Room切り替え
	## -------------------------

	var success: bool = load_chunk(
		next_chunk,
		int(entry_side)
	)


	## -------------------------
	## 明転
	## -------------------------

	if transition_layer != null:

		await transition_layer.fade_in()


	## -------------------------
	## Player操作復帰
	## -------------------------

	if player != null:

		player.process_mode = (
			previous_process_mode
		)


	if success:

		print(
			"RoomManager: transition ",
			get_direction_name(
				direction
			),
			" -> chunk ",
			next_chunk.coord
		)


	is_transitioning = false


## =========================
## Phase出口判定
## =========================

func is_phase_exit(
	direction: Enums.Direction
) -> bool:

	if current_chunk == null:
		return false


	if (
		direction == Enums.Direction.DOWN
		and current_chunk.is_prev_phase_gate
	):

		return true


	if (
		direction == Enums.Direction.UP
		and current_chunk.is_next_phase_gate
	):

		return true


	return false


## =========================
## 反対方向
## =========================

func get_opposite_direction(
	direction: Enums.Direction
) -> Enums.Direction:

	match direction:

		Enums.Direction.DOWN:

			return Enums.Direction.UP


		Enums.Direction.LEFT:

			return Enums.Direction.RIGHT


		Enums.Direction.UP:

			return Enums.Direction.DOWN


		Enums.Direction.RIGHT:

			return Enums.Direction.LEFT


	return Enums.Direction.DOWN


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
