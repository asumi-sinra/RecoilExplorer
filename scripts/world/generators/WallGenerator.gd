extends RefCounted
class_name WallGenerator


func generate(world: WorldData) -> void:

	# 最初にすべての壁を0にする
	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			chunk.wall_bits = 0

	# マップ外周
	add_outer_walls(world)

	# バイオーム境界
	add_biome_boundary_walls(world)


func add_outer_walls(world: WorldData) -> void:

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH):

			var chunk := world.get_chunk(
				Vector2i(x, y)
			)

			# 上端
			if y == 0:

				chunk.add_wall(
					Enums.Direction.UP
				)

			# 下端
			if y == WorldData.HEIGHT - 1:

				chunk.add_wall(
					Enums.Direction.DOWN
				)

			# 左端
			if x == 0:

				chunk.add_wall(
					Enums.Direction.LEFT
				)

			# 右端
			if x == WorldData.WIDTH - 1:

				chunk.add_wall(
					Enums.Direction.RIGHT
				)


func add_biome_boundary_walls(world: WorldData) -> void:

	for y in range(WorldData.HEIGHT):

		for x in range(WorldData.WIDTH - 1):

			var left_chunk := world.get_chunk(
				Vector2i(x, y)
			)

			var right_chunk := world.get_chunk(
				Vector2i(x + 1, y)
			)

			if left_chunk.main_biome == null:
				continue

			if right_chunk.main_biome == null:
				continue

			# 左右のチャンクでバイオームが違う場合、
			# その境界を壁にする。
			if left_chunk.main_biome != right_chunk.main_biome:

				left_chunk.add_wall(
					Enums.Direction.RIGHT
				)

				right_chunk.add_wall(
					Enums.Direction.LEFT
				)

	# 上下のチャンクでバイオームが違う場合、
	# 水平壁を作る。
	for y in range(WorldData.HEIGHT - 1):

		for x in range(WorldData.WIDTH):

			var upper_chunk := world.get_chunk(
				Vector2i(x, y)
			)

			var lower_chunk := world.get_chunk(
				Vector2i(x, y + 1)
			)

			if upper_chunk.main_biome == null:
				continue

			if lower_chunk.main_biome == null:
				continue

			if upper_chunk.main_biome != lower_chunk.main_biome:

				upper_chunk.add_wall(
					Enums.Direction.DOWN
				)

				lower_chunk.add_wall(
					Enums.Direction.UP
				)
