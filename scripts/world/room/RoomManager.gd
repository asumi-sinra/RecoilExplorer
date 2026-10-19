
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
			+ " のルートにRoom.gdを"
			+ "アタッチしてください。"
		)

		instance.free()
		return false

	var new_room: RoomScene = (
		instance as RoomScene
	)


	## -------------------------
	## Chunk情報を渡す
	## add_child()より前に呼び出す
	## -------------------------

	new_room.setup_from_chunk(
		chunk
	)


	## -------------------------
	## 新しいRoomの出口を無効化
	## Player配置と物理判定が安定するまで
	## 出口イベントを発生させない
	## -------------------------

	new_room.set_exits_enabled(
		false
	)


	## -------------------------
	## 古いRoomの出口を先に無効化
	## queue_free()だけでは削除まで
	## ノードが残るため、先にセンサーを止める
	## -------------------------

	if is_instance_valid(current_room):

		current_room.set_exits_enabled(
			false
		)

		current_room.queue_free()


	## -------------------------
	## 新しいRoom追加
	## -------------------------

	new_room.position = Vector2.ZERO

	add_child(
		new_room
	)

	current_room = new_room
	current_chunk = chunk


	## -------------------------
	## Exit通知
	##
	## 発生元Roomをコールバックに束縛する。
	## 古いRoomから届いたイベントは無視する。
	## -------------------------

	current_room.exit_requested.connect(
		_on_room_exit_requested.bind(current_room)
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

			## SpawnPointへ移動
			player.global_position = (
				spawn_marker.global_position
			)

			## CharacterBody2Dの速度をリセット
			if player is CharacterBody2D:
				(player as CharacterBody2D).velocity = Vector2.ZERO

			## 移動入力が離されるまでロック
			if player.has_method("lock_movement_until_release"):
				player.call("lock_movement_until_release")


	## -------------------------
	## 出口センサーの遅延有効化
	## 物理フレームを2回待ってから有効化する
	## -------------------------

	call_deferred(
		"_enable_room_exits_after_physics",
		new_room
	)


	print(
		"RoomManager: loaded ",
		chunk.room.display_name,
		"  chunk=",
		chunk.coord,
		"  main=",
		get_biome_name(
			chunk.main_biome
		),
		"  sub=",
		get_biome_name(
			chunk.sub_biome
		),
		"  sub_direction=",
		get_direction_name(
			chunk.sub_biome_direction
		),
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
## 物理フレーム待機後に出口を有効化
## =========================

func _enable_room_exits_after_physics(
	room: RoomScene
) -> void:

	if not is_instance_valid(room):
		return

	## 1回目の物理フレームを待つ
	await get_tree().physics_frame

	## 待機中に別のRoomへ移動していないか確認
	if not is_instance_valid(room):
		return

	if room != current_room:
		return

	## 2回目の物理フレームを待つ
	await get_tree().physics_frame

	## 待機中に別のRoomへ移動していないか再確認
	if not is_instance_valid(room):
		return

	if room != current_room:
		return

	if room.is_queued_for_deletion():
		return

	## Player配置後、物理判定が更新された段階で有効化
	room.set_exits_enabled(
		true
	)


## =========================
## RoomExitから遷移要求
## =========================

func _on_room_exit_requested(
	direction: Enums.Direction,
	source_room: RoomScene
) -> void:

	## 古いRoomから届いたイベントは無視する
	if source_room != current_room:

		var current_room_name: String = "null"

		if is_instance_valid(current_room):
			current_room_name = str(
				current_room.name
			)

		var source_room_name: String = "null"

		if is_instance_valid(source_room):
			source_room_name = str(
				source_room.name
			)

		print(
			"RoomManager: 古いRoomの出口イベントを無視。 ",
			"source=",
			source_room_name,
			" current=",
			current_room_name,
			" direction=",
			get_direction_name(direction)
		)

		return

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
	## 隣Chunk
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
	## RoomData確認
	## -------------------------

	if next_chunk.room == null:

		print(
			"RoomManager: 遷移先に対応RoomDataがまだありません。 ",
			"chunk=",
			next_chunk.coord
		)

		return


	## -------------------------
	## 次Roomでは反対側から入る
	## -------------------------

	var entry_side: Enums.Direction = (
		get_opposite_direction(
			direction
		)
	)

	is_transitioning = true


	## -------------------------
	## Player停止
	## -------------------------

	var previous_process_mode: Node.ProcessMode = (
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
	## Player復帰
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
## Biome名
## =========================

func get_biome_name(
	biome: BiomeData
) -> String:

	if biome == null:
		return "null"

	return biome.display_name


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
