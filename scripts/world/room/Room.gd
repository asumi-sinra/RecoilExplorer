extends Node2D
class_name RoomScene


signal exit_requested(
	direction: Enums.Direction
)


## =========================
## このRoomが表しているChunk
## =========================

var chunk_coord: Vector2i = Vector2i.ZERO


## =========================
## Biome情報
## =========================

var main_biome: BiomeData = null

var sub_biome: BiomeData = null


## =========================
## 副Biomeが存在する方向
##
## -1 = 通常Room
## =========================

var sub_biome_direction: int = -1


func _ready() -> void:

	_connect_room_exits(
		self
	)


	print_biome_context()


## =========================
## Chunk情報をRoomへ渡す
##
## RoomManagerからadd_child()前に
## 呼び出される
## =========================

func setup_from_chunk(
	chunk: ChunkData
) -> void:

	if chunk == null:

		push_error(
			"RoomScene: setup_from_chunk() に"
			+ "nullのChunkが渡されました。"
		)

		return


	chunk_coord = chunk.coord

	main_biome = chunk.main_biome

	sub_biome = chunk.sub_biome

	sub_biome_direction = (
		chunk.sub_biome_direction
	)


## =========================
## Room内にあるRoomExitを探して接続
## =========================

func _connect_room_exits(
	node: Node
) -> void:

	for child in node.get_children():

		if child is RoomExit:

			var room_exit: RoomExit = (
				child as RoomExit
			)


			room_exit.exit_requested.connect(
				_on_exit_requested
			)


		_connect_room_exits(
			child
		)


## =========================
## Exitからの通知
## =========================

func _on_exit_requested(
	direction: Enums.Direction
) -> void:

	exit_requested.emit(
		direction
	)


## =========================
## 入室位置取得
## =========================

func get_spawn_marker(
	entry_side: int
) -> Marker2D:

	var marker_name: String = ""


	match entry_side:

		Enums.Direction.DOWN:

			marker_name = "SpawnFromDown"


		Enums.Direction.LEFT:

			marker_name = "SpawnFromLeft"


		Enums.Direction.UP:

			marker_name = "SpawnFromUp"


		Enums.Direction.RIGHT:

			marker_name = "SpawnFromRight"


		_:

			return null


	var node: Node = find_child(
		marker_name,
		true,
		false
	)


	if node == null:

		return null


	if not node is Marker2D:

		push_error(
			"RoomScene: "
			+ marker_name
			+ " はMarker2Dにしてください。"
		)

		return null


	return node as Marker2D


## =========================
## 境界Roomか
## =========================

func is_biome_transition_room() -> bool:

	return (
		sub_biome != null
		and sub_biome_direction >= 0
	)


## =========================
## Biome情報デバッグ表示
## =========================

func print_biome_context() -> void:

	var main_name: String = "null"
	var sub_name: String = "null"


	if main_biome != null:

		main_name = (
			main_biome.display_name
		)


	if sub_biome != null:

		sub_name = (
			sub_biome.display_name
		)


	print(
		"Room biome context: ",
		"chunk=",
		chunk_coord,
		" main=",
		main_name,
		" sub=",
		sub_name,
		" sub_direction=",
		get_direction_name(
			sub_biome_direction
		)
	)


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
