extends RefCounted
class_name RoomValidator


## =========================
## 全BiomeのRoomData検査
## =========================

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

			print(
				"INVALID BIOME:"
			)

			print(
				"  ERROR: nullのBiomeDataが登録されています。"
			)

			all_valid = false

			continue


		print("")
		print(
			"Biome: ",
			get_biome_name(
				biome
			)
		)

		print(
			"Registered rooms: ",
			biome.rooms.size()
		)


		for room_data in biome.rooms:

			total_count += 1


			if room_data == null:

				print(
					"INVALID: <NULL>"
				)

				print(
					"  ERROR: nullのRoomDataが登録されています。"
				)

				all_valid = false

				continue


			var room_key: String = (
				get_room_key(
					room_data
				)
			)


			## -------------------------
			## 他Biomeとの重複登録
			## -------------------------

			if registered_rooms.has(
				room_key
			):

				var previous_biome_name: String = (
					registered_rooms[
						room_key
					]
				)


				print(
					"INVALID: ",
					get_room_name(
						room_data
					)
				)

				print(
					"  ERROR: 同じRoomDataが複数のBiomeに登録されています。"
				)

				print(
					"  ERROR: 既存Biome=",
					previous_biome_name,
					" 今回Biome=",
					get_biome_name(
						biome
					)
				)

				all_valid = false

				continue


			registered_rooms[
				room_key
			] = get_biome_name(
				biome
			)


			var errors: Array[String] = (
				validate_room(
					room_data
				)
			)


			if errors.is_empty():

				valid_count += 1


				print(
					"VALID: ",
					get_room_name(
						room_data
					)
				)


			else:

				all_valid = false


				print(
					"INVALID: ",
					get_room_name(
						room_data
					)
				)


				for error_message in errors:

					print(
						"  ERROR: ",
						error_message
					)


	print("")
	print(
		"Room validation: ",
		valid_count,
		" / ",
		total_count,
		" valid"
	)


	if all_valid:

		print(
			"All registered RoomData are valid."
		)


	return all_valid


## =========================
## 1つのRoomDataを検査
## =========================

func validate_room(
	room_data: RoomData
) -> Array[String]:

	var errors: Array[String] = []


	if room_data == null:

		errors.append(
			"nullのRoomDataです。"
		)

		return errors


	## -------------------------
	## Display Name
	## -------------------------

	if room_data.display_name.strip_edges().is_empty():

		errors.append(
			"Display Nameが空です。"
		)


	## -------------------------
	## Scene
	## -------------------------

	if room_data.scene == null:

		errors.append(
			"Sceneが設定されていません。"
		)

		return errors


	## -------------------------
	## Exits重複
	## -------------------------

	for direction in get_all_directions():

		var declared_count: int = (
			room_data.exits.count(
				direction
			)
		)


		if declared_count > 1:

			errors.append(
				"RoomDataのExitsに "
				+ get_direction_name(
					direction
				)
				+ " が重複しています。"
			)


	## -------------------------
	## Scene一時生成
	## -------------------------

	var instance: Node = (
		room_data.scene.instantiate()
	)


	## -------------------------
	## Room.gd確認
	## -------------------------

	if not instance is RoomScene:

		errors.append(
			"RoomシーンのルートにRoom.gdが"
			+ "アタッチされていません。"
		)

		instance.free()

		return errors


	var room_scene: RoomScene = (
		instance as RoomScene
	)


	## -------------------------
	## RoomExit取得
	## -------------------------

	var room_exits: Array[RoomExit] = []


	collect_room_exits(
		room_scene,
		room_exits
	)


	## -------------------------
	## 4方向を検査
	## -------------------------

	for direction in get_all_directions():

		var declared: bool = (
			room_data.exits.has(
				direction
			)
		)


		var exit_count: int = (
			count_exits_for_direction(
				room_exits,
				direction
			)
		)


		var marker_name: String = (
			get_spawn_marker_name(
				direction
			)
		)


		var marker_node: Node = (
			find_spawn_marker(
				room_scene,
				marker_name
			)
		)


		## -------------------------
		## RoomDataに接続あり
		## -------------------------

		if declared:

			if exit_count == 0:

				errors.append(
					get_direction_name(
						direction
					)
					+ " がExitsにありますが、"
					+ "対応するRoomExitがありません。"
				)


			elif exit_count > 1:

				errors.append(
					get_direction_name(
						direction
					)
					+ " のRoomExitが "
					+ str(exit_count)
					+ " 個あります。"
					+ "1個だけにしてください。"
				)


			if marker_node == null:

				errors.append(
					marker_name
					+ " がありません。"
				)


			elif not marker_node is Marker2D:

				errors.append(
					marker_name
					+ " は存在しますが、"
					+ "Marker2Dではありません。"
				)


		## -------------------------
		## RoomDataに接続なし
		## -------------------------

		else:

			if exit_count > 0:

				errors.append(
					get_direction_name(
						direction
					)
					+ " はRoomDataのExitsにないのに、"
					+ "RoomExitが存在します。"
				)


			if marker_node != null:

				errors.append(
					marker_name
					+ " はRoomDataのExitsに"
					+ "対応する方向がないのに存在します。"
				)


	## -------------------------
	## CollisionShape確認
	## -------------------------

	for room_exit in room_exits:

		if not has_active_collision_shape(
			room_exit
		):

			errors.append(
				get_direction_name(
					room_exit.direction
				)
				+ " のRoomExitに"
				+ "有効なCollisionShape2Dがありません。"
			)


	instance.free()


	return errors


## =========================
## Room名
## =========================

func get_room_name(
	room_data: RoomData
) -> String:

	if room_data == null:

		return "<NULL>"


	if room_data.display_name.strip_edges().is_empty():

		return "<NO NAME>"


	return room_data.display_name


## =========================
## Biome名
## =========================

func get_biome_name(
	biome: BiomeData
) -> String:

	if biome == null:

		return "<NULL>"


	if biome.display_name.strip_edges().is_empty():

		return "<NO NAME>"


	return biome.display_name


## =========================
## Room識別キー
## =========================

func get_room_key(
	room_data: RoomData
) -> String:

	if not room_data.resource_path.is_empty():

		return room_data.resource_path


	return str(
		room_data.get_instance_id()
	)


## =========================
## RoomExit再帰取得
## =========================

func collect_room_exits(
	node: Node,
	result: Array[RoomExit]
) -> void:

	for child in node.get_children():

		if child is RoomExit:

			result.append(
				child as RoomExit
			)


		collect_room_exits(
			child,
			result
		)


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
## SpawnMarker検索
## =========================

func find_spawn_marker(
	room_scene: RoomScene,
	marker_name: String
) -> Node:

	return room_scene.find_child(
		marker_name,
		true,
		false
	)


## =========================
## CollisionShape確認
## =========================

func has_active_collision_shape(
	room_exit: RoomExit
) -> bool:

	for child in room_exit.get_children():

		if child is CollisionShape2D:

			var collision_shape: CollisionShape2D = (
				child as CollisionShape2D
			)


			if (
				not collision_shape.disabled
				and collision_shape.shape != null
			):

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
## SpawnMarker名
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
