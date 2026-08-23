extends Node2D
class_name RoomScene


signal exit_requested(direction: Enums.Direction)


func _ready() -> void:

	_connect_room_exits(
		self
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


	var node: Node = get_node_or_null(
		marker_name
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
