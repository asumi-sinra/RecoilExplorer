extends RefCounted
class_name RoomValidator


func validate_all(
	biomes: Array[BiomeData]
) -> bool:

	print("")
	print("----- Room Validation -----")

	var all_valid: bool = true
	var valid_count: int = 0
	var total_count: int = 0

	var registered_rooms: Dictionary = {}

	for biome in biomes:

		if biome == null:
			print("INVALID BIOME: null")
			all_valid = false
			continue

		print("")
		print("Biome: ", biome.display_name)
		print("Registered rooms: ", biome.rooms.size())

		for room_data in biome.rooms:

			total_count += 1

			if room_data == null:
				print("INVALID: <NULL>")
				print("  ERROR: nullのRoomDataです。")
				all_valid = false
				continue

			var room_key: String = get_room_key(room_data)

			if registered_rooms.has(room_key):
				print("INVALID: ", room_data.display_name)
				print("  ERROR: 同じRoomDataが重複登録されています。")
				all_valid = false
				continue

			registered_rooms[room_key] = biome.display_name

			var errors: Array[String] = validate_room(room_data)

			if errors.is_empty():
				valid_count += 1
				print("VALID: ", room_data.display_name)
			else:
				all_valid = false
				print("INVALID: ", room_data.display_name)

				for error_message in errors:
					print("  ERROR: ", error_message)

	print("")
	print(
		"Room validation: ",
		valid_count,
		" / ",
		total_count,
		" valid"
	)

	if all_valid:
		print("All registered RoomData are valid.")

	return all_valid


## =========================
## 1つのRoomDataを検査
## =========================

func validate_room(
	room_data: RoomData
) -> Array[String]:

	var errors: Array[String] = []

	if room_data.display_name.strip_edges().is_empty():
		errors.append("Display Nameが空です。")

	if room_data.scene == null:
		errors.append("Sceneが設定されていません。")
		return errors

	for direction in get_all_directions():
		if room_data.exits.count(direction) > 1:
			errors.append(
				"Exitsに "
				+ get_direction_name(direction)
				+ " が重複しています。"
			)

	var instance: Node = room_data.scene.instantiate()

	if not instance is RoomScene:
		errors.append(
			"RoomシーンのルートにRoom.gdがアタッチされていません。"
		)
		instance.free()
		return errors

	var room_scene: RoomScene = instance as RoomScene

	## 動的テンプレートの場合、検査用インスタンス上で必要なノードを生成
	room_scene.prepare_for_validation(room_data)

	var room_exits: Array[RoomExit] = []
	collect_room_exits(room_scene, room_exits)

	if room_data.configure_exits_at_runtime:

		## デバッグRoomは4方向すべてのExitとSpawnPointを持つ
		for direction in get_all_directions():

			var exit_count: int = count_exits_for_direction(
				room_exits,
				direction
			)

			if exit_count != 1:
				errors.append(
					get_direction_name(direction)
					+ " のRoomExitが1個ではありません。"
				)

			var marker_name: String = get_spawn_marker_name(direction)
			var marker: Node = room_scene.find_child(
				marker_name,
				true,
				false
			)

			if not marker is Marker2D:
				errors.append(marker_name + " がないか、Marker2Dではありません。")

		## デバッグ表示に必要なノード
		check_node_type(
			room_scene,
			"DebugBackground",
			"Polygon2D",
			errors
		)

		check_node_type(
			room_scene,
			"DebugFloorBody",
			"StaticBody2D",
			errors
		)

		check_node_type(
			room_scene,
			"RoomNameLabel",
			"Label",
			errors
		)

		check_node_type(
			room_scene,
			"BiomeContextLabel",
			"Label",
			errors
		)

		check_node_type(
			room_scene,
			"VariantLabel",
			"Label",
			errors
		)

		check_node_type(
			room_scene,
			"VariantMarkA",
			"Polygon2D",
			errors
		)

		check_node_type(
			room_scene,
			"VariantMarkB",
			"Polygon2D",
			errors
		)

	else:

		## 通常Roomは、RoomData.exitsとシーンを厳密に照合する
		for direction in get_all_directions():

			var declared: bool = room_data.exits.has(direction)
			var exit_count: int = count_exits_for_direction(
				room_exits,
				direction
			)

			var marker_name: String = get_spawn_marker_name(direction)
			var marker: Node = room_scene.find_child(
				marker_name,
				true,
				false
			)

			if declared:
				if exit_count != 1:
					errors.append(
						get_direction_name(direction)
						+ " のRoomExitが1個ではありません。"
					)

				if not marker is Marker2D:
					errors.append(marker_name + " がないか、Marker2Dではありません。")

			else:
				if exit_count > 0:
					errors.append(
						"Exitsにない方向のRoomExitがあります: "
						+ get_direction_name(direction)
					)

				if marker != null:
					errors.append(
						"Exitsにない方向のSpawnPointがあります: "
						+ marker_name
					)

	## すべての出口に有効なCollisionShape2Dがあるか確認
	for room_exit in room_exits:
		if not has_active_collision_shape(room_exit):
			errors.append(
				get_direction_name(room_exit.direction)
				+ " のRoomExitに有効なCollisionShape2Dがありません。"
			)

	instance.free()
	return errors


## =========================
## 必要なノードがあるか確認
## =========================

func check_node_type(
	root: Node,
	node_name: String,
	expected_type: String,
	errors: Array[String]
) -> void:

	var node: Node = root.find_child(
		node_name,
		true,
		false
	)

	if node == null:
		errors.append(node_name + " がありません。")
		return

	var matches_type: bool = false

	match expected_type:
		"Polygon2D":
			matches_type = node is Polygon2D
		"StaticBody2D":
			matches_type = node is StaticBody2D
		"Label":
			matches_type = node is Label

	if not matches_type:
		errors.append(
			node_name
			+ " の型が "
			+ expected_type
			+ " ではありません。"
		)


## =========================
## RoomExitを再帰的に取得
## =========================

func collect_room_exits(
	node: Node,
	result: Array[RoomExit]
) -> void:

	for child in node.get_children():
		if child is RoomExit:
			result.append(child as RoomExit)

		collect_room_exits(child, result)


## =========================
## 指定方向のExit数
## =========================

func count_exits_for_direction(
	room_exits: Array[RoomExit],
	direction: Enums.Direction
) -> int:

	var count: int = 0

	for room_exit in room_exits:
		if room_exit.direction == direction:
			count += 1

	return count


## =========================
## CollisionShape確認
## =========================

func has_active_collision_shape(
	room_exit: RoomExit
) -> bool:

	for child in room_exit.get_children():

		if child is CollisionShape2D:
			var shape: CollisionShape2D = child as CollisionShape2D

			if not shape.disabled and shape.shape != null:
				return true

	return false


## =========================
## 全方向
## =========================

func get_all_directions() -> Array[Enums.Direction]:

	return [
		Enums.Direction.DOWN,
		Enums.Direction.LEFT,
		Enums.Direction.UP,
		Enums.Direction.RIGHT
	]


## =========================
## SpawnPoint名
## =========================

func get_spawn_marker_name(
	direction: Enums.Direction
) -> String:

	match direction:
		Enums.Direction.DOWN:
			return "SpawnFromDown"

		Enums.Direction.LEFT:
			return "SpawnFromLeft"

		Enums.Direction.UP:
			return "SpawnFromUp"

		Enums.Direction.RIGHT:
			return "SpawnFromRight"

	return ""


## =========================
## Resource識別キー
## =========================

func get_room_key(
	room_data: RoomData
) -> String:

	if not room_data.resource_path.is_empty():
		return room_data.resource_path

	return str(room_data.get_instance_id())


## =========================
## Direction名
## =========================

func get_direction_name(
	direction: Enums.Direction
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

	return "UNKNOWN"
