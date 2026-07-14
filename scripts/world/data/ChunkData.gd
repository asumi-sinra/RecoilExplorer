class_name ChunkData

var coord : Vector2i

# 4bit
var road_bits : int = 0

# 4bit
var wall_bits : int = 0

# 4bit
var road_exist_bits : int = 0

# 4bit
var expandable_bits : int = 0

var road_count : int = 0

var main_biome : BiomeData

var sub_biome : BiomeData

var is_prev_phase_gate := false

var is_next_phase_gate := false


func _init(pos:Vector2i):

	coord = pos
