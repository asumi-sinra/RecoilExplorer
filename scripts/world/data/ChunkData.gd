class_name ChunkData


# =========================
# 基本情報
# =========================

# マップ全体における絶対座標
var coord: Vector2i


# =========================
# 道・壁情報
# =========================

# 道の伸び方
#
# bit 0 = DOWN
# bit 1 = LEFT
# bit 2 = UP
# bit 3 = RIGHT
var road_bits: int = 0


# 壁判定
#
# bit 0 = DOWN
# bit 1 = LEFT
# bit 2 = UP
# bit 3 = RIGHT
var wall_bits: int = 0


# 道本数
#
# road_bitsの1の数。
# 0～4
var road_count: int = 0


# =========================
# バイオーム情報
# =========================

# 主バイオーム
var main_biome: BiomeData = null


# 副バイオーム
#
# バイオーム境界付近のグラデーションなどに使用する。
var sub_biome: BiomeData = null


# =========================
# フェーズ間通路
# =========================

# 前フェーズからこのチャンクに入る通路か
var is_prev_phase_gate: bool = false


# 次フェーズへ進むための通路か
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
