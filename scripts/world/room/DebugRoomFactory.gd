extends RefCounted
class_name DebugRoomFactory


const PATTERN_COUNT: int = 16
const VARIANT_COUNT: int = 2


## =========================
## 全BiomeのデバッグRoomを生成
## =========================

func populate_biome_rooms(
	biomes: Array[BiomeData],
	debug_scene: PackedScene
) -> bool:

	if debug_scene == null:
		push_error("DebugRoomFactory: DebugRoom.tscnが設定されていません。")
		return false

	if biomes.size() < 3:
		push_error("DebugRoomFactory: 3種類以上のBiomeDataが必要です。")
		return false

	for biome in biomes:
		if biome == null:
			push_error("DebugRoomFactory: nullのBiomeDataがあります。")
			return false

		## この実行中のBiome専用にRoom一覧を作り直す
		biome.rooms.clear()

		for pattern_bits in range(PATTERN_COUNT):
			var exits: Array[Enums.Direction] = get_exits_from_bits(
				pattern_bits
			)

			var pattern_name: String = get_pattern_name(
				pattern_bits
			)

			for variant_index in range(VARIANT_COUNT):
				var variant_suffix: String = (
					"A" if variant_index == 0 else "B"
				)

				var room_data: RoomData = RoomData.new()

				room_data.display_name = (
					biome.display_name
					+ "_"
					+ pattern_name
					+ "_"
					+ variant_suffix
				)

				room_data.scene = debug_scene
				room_data.exits = exits.duplicate()
				room_data.configure_exits_at_runtime = true
				room_data.debug_variant = variant_index

				biome.rooms.append(room_data)

		print(
			"DebugRoomFactory: ",
			biome.display_name,
			" -> ",
			biome.rooms.size(),
			" rooms"
		)

	return true


## =========================
## ビット列から出口を取得
##
## bit 0 = DOWN
## bit 1 = LEFT
## bit 2 = UP
## bit 3 = RIGHT
## =========================

func get_exits_from_bits(
	bits: int
) -> Array[Enums.Direction]:

	var result: Array[Enums.Direction] = []

	var directions: Array[Enums.Direction] = [
		Enums.Direction.DOWN,
		Enums.Direction.LEFT,
		Enums.Direction.UP,
		Enums.Direction.RIGHT
	]

	for direction in directions:
		if (bits & (1 << int(direction))) != 0:
			result.append(direction)

	return result


## =========================
## Room名用のパターン文字列
##
## 例:
## 1010 -> LR
## 1001 -> RD
## 0000 -> Empty
## =========================

func get_pattern_name(
	bits: int
) -> String:

	if bits == 0:
		return "Empty"

	var result: String = ""

	## 名前は L, R, U, D の順で統一
	if (bits & (1 << int(Enums.Direction.LEFT))) != 0:
		result += "L"

	if (bits & (1 << int(Enums.Direction.RIGHT))) != 0:
		result += "R"

	if (bits & (1 << int(Enums.Direction.UP))) != 0:
		result += "U"

	if (bits & (1 << int(Enums.Direction.DOWN))) != 0:
		result += "D"

	return result
