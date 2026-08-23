extends RefCounted
class_name RoomSpawner


## =========================
## Roomシーン配置
## =========================

func spawn(
	world: WorldData,
	parent: Node2D,
	room_size: Vector2
) -> int:

	clear_rooms(parent)

	var spawned_count: int = 0


	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk: ChunkData = world.get_chunk(
				Vector2i(x, y)
			)


			## -------------------------
			## RoomDataがないChunkは無視
			## -------------------------

			if chunk.room == null:
				continue


			## -------------------------
			## Sceneが設定されていない場合
			## -------------------------

			if chunk.room.scene == null:

				push_error(
					"RoomSpawner: Sceneが設定されていません。 "
					+ "Room="
					+ chunk.room.display_name
				)

				continue


			## -------------------------
			## Scene生成
			## -------------------------

			var instance: Node = (
				chunk.room.scene.instantiate()
			)


			## -------------------------
			## RootがNode2Dか確認
			## -------------------------

			if not instance is Node2D:

				push_error(
					"RoomSpawner: "
					+ chunk.room.display_name
					+ " のルートノードはNode2Dにしてください。"
				)

				instance.free()

				continue


			var room_node: Node2D = instance as Node2D


			## -------------------------
			## ノード名
			## -------------------------

			room_node.name = (
				"Room_"
				+ str(chunk.coord.x)
				+ "_"
				+ str(chunk.coord.y)
				+ "_"
				+ chunk.room.display_name
			)


			## -------------------------
			## Chunk座標 → 実座標
			## -------------------------

			room_node.position = Vector2(
				float(chunk.coord.x) * room_size.x,
				float(chunk.coord.y) * room_size.y
			)


			## -------------------------
			## 親へ追加
			## -------------------------

			parent.add_child(
				room_node
			)


			## -------------------------
			## 後からChunk座標を取得できるよう保存
			## -------------------------

			room_node.set_meta(
				"chunk_coord",
				chunk.coord
			)


			spawned_count += 1


			print(
				"Spawned room: ",
				chunk.room.display_name,
				"  chunk=",
				chunk.coord,
				"  position=",
				room_node.position
			)


	return spawned_count


## =========================
## 既存Room削除
## =========================

func clear_rooms(
	parent: Node2D
) -> void:

	for child in parent.get_children():

		child.free()
