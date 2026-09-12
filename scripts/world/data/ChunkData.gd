class_name ChunkData


## =========================
## 論理マップ上の座標
## =========================

var coord: Vector2i


## =========================
## 道・壁
## =========================

var road_bits: int = 0
var wall_bits: int = 0
var road_count: int = 0


## =========================
## Biome
## =========================

var main_biome: BiomeData = null

var sub_biome: BiomeData = null


## =========================
## 副Biomeが存在する方向
##
## -1 = 副Biomeなし
## =========================

var sub_biome_direction: int = -1


## =========================
## Phase Gate
## =========================

var is_prev_phase_gate: bool = false
var is_next_phase_gate: bool = false


## =========================
## このChunkに割り当てられたRoom
## =========================

var room: RoomData = null


func _init(
	pos: Vector2i
) -> void:

	coord = pos


## =========================
## Wall
## =========================

func has_wall(
	dir: Enums.Direction
) -> bool:

	return (
		wall_bits
		& (1 << int(dir))
	) != 0


func add_wall(
	dir: Enums.Direction
) -> void:

	wall_bits |= (
		1 << int(dir)
	)


func remove_wall(
	dir: Enums.Direction
) -> void:

	wall_bits &= ~(
		1 << int(dir)
	)


## =========================
## Road
## =========================

func has_road(
	dir: Enums.Direction
) -> bool:

	return (
		road_bits
		& (1 << int(dir))
	) != 0


func add_road(
	dir: Enums.Direction
) -> void:

	if has_road(
		dir
	):

		return


	road_bits |= (
		1 << int(dir)
	)


	update_road_count()


func remove_road(
	dir: Enums.Direction
) -> void:

	if not has_road(
		dir
	):

		return


	road_bits &= ~(
		1 << int(dir)
	)


	update_road_count()


## =========================
## Road数更新
## =========================

func update_road_count() -> void:

	road_count = 0


	for i in range(4):

		if (
			road_bits
			& (1 << i)
		) != 0:

			road_count += 1
