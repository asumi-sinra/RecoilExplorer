class_name ChunkData


# =========================
# 基本情報
# =========================

var coord: Vector2i


# =========================
# 道・壁情報
# =========================

var road_bits: int = 0

var wall_bits: int = 0

var road_count: int = 0


# =========================
# バイオーム情報
# =========================

var main_biome: BiomeData = null

var sub_biome: BiomeData = null


# =========================
# Room情報
# =========================

var room: RoomData = null


# =========================
# フェーズ間通路
# =========================

var is_prev_phase_gate: bool = false

var is_next_phase_gate: bool = false


func _init(pos: Vector2i):

	coord = pos


# =========================
# 壁
# =========================

func has_wall(dir: Enums.Direction) -> bool:

	return (wall_bits & (1 << int(dir))) != 0


func add_wall(dir: Enums.Direction) -> void:

	wall_bits |= 1 << int(dir)


func remove_wall(dir: Enums.Direction) -> void:

	wall_bits &= ~(1 << int(dir))


# =========================
# 道
# =========================

func has_road(dir: Enums.Direction) -> bool:

	return (road_bits & (1 << int(dir))) != 0


func add_road(dir: Enums.Direction) -> void:

	if has_road(dir):
		return

	road_bits |= 1 << int(dir)

	update_road_count()


func remove_road(dir: Enums.Direction) -> void:

	if not has_road(dir):
		return

	road_bits &= ~(1 << int(dir))

	update_road_count()


func update_road_count() -> void:

	road_count = 0

	for i in range(4):

		if (road_bits & (1 << i)) != 0:

			road_count += 1
