
extends Node2D
class_name RoomScene


signal exit_requested(
	direction: Enums.Direction
)


## =========================
## デバッグRoomの寸法
## 縦横ともに従来の2倍
## =========================

const DEBUG_WIDTH: float = 2560.0
const DEBUG_HEIGHT: float = 1440.0

const DEBUG_FLOOR_TOP: float = 1240.0
const DEBUG_FLOOR_HEIGHT: float = 200.0

const DEBUG_ISLAND_WIDTH: float = 640.0
const DEBUG_ISLAND_SURFACE_Y: float = 760.0
const DEBUG_ISLAND_COLLISION_HEIGHT: float = 48.0


## 床と出口センサーの物理設定
@export_flags_2d_physics var debug_floor_collision_layer: int = 1
@export_flags_2d_physics var debug_exit_collision_mask: int = 1


## =========================
## 現在のRoom情報
## =========================

var chunk_coord: Vector2i = Vector2i.ZERO
var room_data: RoomData = null

var main_biome: BiomeData = null
var sub_biome: BiomeData = null
var sub_biome_direction: int = -1

var debug_template_built: bool = false

## 出口センサーの有効化状態
## Room生成直後は無効にしておく
var exits_enabled: bool = false


func _ready() -> void:

	if room_data != null and room_data.configure_exits_at_runtime:
		ensure_debug_template()
		configure_dynamic_exits()
		update_debug_display()

	_connect_room_exits(self)
	print_biome_context()


## =========================
## Chunk情報を受け取る
## =========================

func setup_from_chunk(
	chunk: ChunkData
) -> void:

	if chunk == null:
		push_error("RoomScene: nullのChunkDataが渡されました。")
		return

	chunk_coord = chunk.coord
	room_data = chunk.room

	main_biome = chunk.main_biome
	sub_biome = chunk.sub_biome
	sub_biome_direction = chunk.sub_biome_direction

	if room_data != null and room_data.configure_exits_at_runtime:
		ensure_debug_template()
		configure_dynamic_exits()
		update_debug_display()


## =========================
## Validator用初期化
## =========================

func prepare_for_validation(
	data: RoomData
) -> void:

	room_data = data

	if room_data != null and room_data.configure_exits_at_runtime:
		ensure_debug_template()
		configure_dynamic_exits()
		update_debug_display()


## =========================
## デバッグRoomを一度だけ生成
## =========================

func ensure_debug_template() -> void:

	if debug_template_built:
		return

	debug_template_built = true

	create_debug_background()
	create_debug_floor()
	create_debug_island()
	create_debug_exits()
	create_debug_spawn_markers()
	create_debug_variant_marks()
	create_debug_labels()


## =========================
## 背景
## =========================

func create_debug_background() -> void:

	var background: Polygon2D = Polygon2D.new()
	background.name = "DebugBackground"

	background.polygon = PackedVector2Array([
		Vector2(0.0, 0.0),
		Vector2(DEBUG_WIDTH, 0.0),
		Vector2(DEBUG_WIDTH, DEBUG_HEIGHT),
		Vector2(0.0, DEBUG_HEIGHT)
	])

	background.color = Color(0.18, 0.24, 0.28)
	background.z_index = -100

	add_child(background)


## =========================
## 床と床コリジョン
## =========================

func create_debug_floor() -> void:

	var floor_visual: Polygon2D = Polygon2D.new()
	floor_visual.name = "DebugFloorVisual"

	floor_visual.polygon = PackedVector2Array([
		Vector2(0.0, DEBUG_FLOOR_TOP),
		Vector2(DEBUG_WIDTH, DEBUG_FLOOR_TOP),
		Vector2(DEBUG_WIDTH, DEBUG_HEIGHT),
		Vector2(0.0, DEBUG_HEIGHT)
	])

	floor_visual.color = Color(0.22, 0.25, 0.27)
	floor_visual.z_index = -10

	add_child(floor_visual)


	var floor_body: StaticBody2D = StaticBody2D.new()
	floor_body.name = "DebugFloorBody"
	floor_body.collision_layer = debug_floor_collision_layer
	floor_body.collision_mask = 0

	add_child(floor_body)


	var floor_shape: CollisionShape2D = CollisionShape2D.new()
	floor_shape.name = "CollisionShape2D"

	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = Vector2(
		DEBUG_WIDTH,
		DEBUG_FLOOR_HEIGHT
	)

	floor_shape.shape = rectangle
	floor_shape.position = Vector2(
		DEBUG_WIDTH / 2.0,
		DEBUG_FLOOR_TOP + DEBUG_FLOOR_HEIGHT / 2.0
	)

	floor_body.add_child(floor_shape)


## =========================
## 中央の浮島とコリジョン
## =========================

func create_debug_island() -> void:

	var island_visual: Polygon2D = Polygon2D.new()
	island_visual.name = "DebugIslandVisual"

	## 上面が水平で、下側がすぼまった浮島の形
	island_visual.polygon = PackedVector2Array([
		Vector2(960.0, 760.0),
		Vector2(1600.0, 760.0),
		Vector2(1540.0, 816.0),
		Vector2(1480.0, 840.0),
		Vector2(1080.0, 840.0),
		Vector2(1020.0, 816.0)
	])

	island_visual.color = Color(0.38, 0.42, 0.45)
	island_visual.z_index = -2

	add_child(island_visual)


	var island_body: StaticBody2D = StaticBody2D.new()
	island_body.name = "DebugIslandBody"
	island_body.collision_layer = debug_floor_collision_layer
	island_body.collision_mask = 0

	add_child(island_body)


	var island_shape: CollisionShape2D = CollisionShape2D.new()
	island_shape.name = "CollisionShape2D"

	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = Vector2(
		DEBUG_ISLAND_WIDTH,
		DEBUG_ISLAND_COLLISION_HEIGHT
	)

	island_shape.shape = rectangle

	## コリジョンの上端を浮島の表面 y=760 に合わせる
	island_shape.position = Vector2(
		DEBUG_WIDTH / 2.0,
		DEBUG_ISLAND_SURFACE_Y
			+ DEBUG_ISLAND_COLLISION_HEIGHT / 2.0
	)

	island_body.add_child(island_shape)


## =========================
## 4方向の出口センサー
## 位置と大きさは固定
## =========================

func create_debug_exits() -> void:

	create_debug_exit(
		"ExitDown",
		Enums.Direction.DOWN,
		Vector2(DEBUG_WIDTH / 2.0, 1196.0),
		Vector2(320.0, 112.0)
	)

	create_debug_exit(
		"ExitLeft",
		Enums.Direction.LEFT,
		Vector2(72.0, 1060.0),
		Vector2(112.0, 312.0)
	)

	create_debug_exit(
		"ExitUp",
		Enums.Direction.UP,
		Vector2(DEBUG_WIDTH / 2.0, 72.0),
		Vector2(320.0, 112.0)
	)

	create_debug_exit(
		"ExitRight",
		Enums.Direction.RIGHT,
		Vector2(DEBUG_WIDTH - 72.0, 1060.0),
		Vector2(112.0, 312.0)
	)


func create_debug_exit(
	exit_name: String,
	direction: Enums.Direction,
	exit_position: Vector2,
	shape_size: Vector2
) -> void:

	var exit_node: RoomExit = RoomExit.new()
	exit_node.name = exit_name
	exit_node.direction = direction
	exit_node.position = exit_position

	exit_node.collision_layer = 0
	exit_node.collision_mask = debug_exit_collision_mask

	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "CollisionShape2D"

	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = shape_size
	collision.shape = rectangle

	exit_node.add_child(collision)


	var portal_visual: Polygon2D = Polygon2D.new()
	portal_visual.name = "PortalVisual"
	portal_visual.polygon = get_centered_rectangle(shape_size)
	portal_visual.color = Color(0.25, 0.85, 0.9, 0.65)
	portal_visual.z_index = 1

	exit_node.add_child(portal_visual)

	add_child(exit_node)


## =========================
## 4つのSpawnPoint
## =========================

func create_debug_spawn_markers() -> void:

	## 下側から入った場合のSpawnPoint
	## 浮島の上面より60px上に配置
	create_debug_spawn_marker(
		"SpawnFromDown",
		Vector2(1160.0, 700.0)
	)

	## 上側から入った場合のSpawnPoint
	## 同じ浮島の上面より60px上に配置
	create_debug_spawn_marker(
		"SpawnFromUp",
		Vector2(1400.0, 700.0)
	)

	## 左側から入った場合
	create_debug_spawn_marker(
		"SpawnFromLeft",
		Vector2(480.0, 1060.0)
	)

	## 右側から入った場合
	create_debug_spawn_marker(
		"SpawnFromRight",
		Vector2(DEBUG_WIDTH - 480.0, 1060.0)
	)


func create_debug_spawn_marker(
	marker_name: String,
	marker_position: Vector2
) -> void:

	var marker: Marker2D = Marker2D.new()
	marker.name = marker_name
	marker.position = marker_position

	add_child(marker)


	var visual: Polygon2D = Polygon2D.new()
	visual.name = "SpawnMarkerVisual"

	visual.polygon = PackedVector2Array([
		Vector2(0.0, -20.0),
		Vector2(20.0, 0.0),
		Vector2(0.0, 20.0),
		Vector2(-20.0, 0.0)
	])

	visual.color = Color(1.0, 0.9, 0.3)
	marker.add_child(visual)


	var marker_label: Label = Label.new()
	marker_label.name = "MarkerLabel"
	marker_label.position = Vector2(24.0, -32.0)
	marker_label.text = marker_name
	marker_label.add_theme_font_size_override("font_size", 28)
	marker_label.add_theme_color_override("font_color", Color.WHITE)
	marker_label.add_theme_color_override("font_outline_color", Color.BLACK)
	marker_label.add_theme_constant_override("outline_size", 5)

	marker.add_child(marker_label)


## =========================
## A/Bの見分け用装飾
## =========================

func create_debug_variant_marks() -> void:

	var mark_a: Polygon2D = Polygon2D.new()
	mark_a.name = "VariantMarkA"

	mark_a.polygon = PackedVector2Array([
		Vector2(1280.0, 516.0),
		Vector2(1322.0, 558.0),
		Vector2(1280.0, 600.0),
		Vector2(1238.0, 558.0)
	])

	mark_a.color = Color(0.25, 0.8, 1.0)
	mark_a.z_index = 2

	add_child(mark_a)


	var mark_b: Polygon2D = Polygon2D.new()
	mark_b.name = "VariantMarkB"

	mark_b.polygon = PackedVector2Array([
		Vector2(1220.0, 520.0),
		Vector2(1340.0, 520.0),
		Vector2(1340.0, 600.0),
		Vector2(1220.0, 600.0)
	])

	mark_b.color = Color(1.0, 0.55, 0.2)
	mark_b.z_index = 2

	add_child(mark_b)


## =========================
## 画面表示用ラベル
## =========================

func create_debug_labels() -> void:

	create_debug_label(
		"RoomNameLabel",
		"Room",
		Vector2(48.0, 36.0),
		Vector2(2200.0, 88.0),
		64
	)

	create_debug_label(
		"BiomeContextLabel",
		"main: null",
		Vector2(48.0, 128.0),
		Vector2(2200.0, 176.0),
		40
	)

	create_debug_label(
		"VariantLabel",
		"Variant",
		Vector2(48.0, 300.0),
		Vector2(1000.0, 72.0),
		40
	)


func create_debug_label(
	label_name: String,
	initial_text: String,
	label_position: Vector2,
	label_size: Vector2,
	font_size: int
) -> void:

	var label: Label = Label.new()
	label.name = label_name
	label.position = label_position
	label.size = label_size
	label.text = initial_text

	label.add_theme_font_size_override(
		"font_size",
		font_size
	)

	label.add_theme_color_override(
		"font_color",
		Color.WHITE
	)

	label.add_theme_color_override(
		"font_outline_color",
		Color.BLACK
	)

	label.add_theme_constant_override(
		"outline_size",
		8
	)

	label.z_index = 20

	add_child(label)


## =========================
## 出口センサーの有効化設定
## =========================

func configure_dynamic_exits() -> void:

	var room_exits: Array[RoomExit] = []
	collect_room_exits(self, room_exits)

	for room_exit in room_exits:

		## RoomDataによる実行時設定がある場合は
		## 登録された方向だけを出口として表示する
		var active: bool = room_exit.visible

		if (
			room_data != null
			and room_data.configure_exits_at_runtime
		):
			active = room_data.exits.has(
				room_exit.direction
			)

			room_exit.visible = active

		## Playerの配置が終わるまではセンサーを無効化
		room_exit.monitoring = (
			active and exits_enabled
		)

		room_exit.monitorable = (
			active and exits_enabled
		)


## =========================
## 出口センサーの有効化状態を変更
## =========================

func set_exits_enabled(
	enabled: bool
) -> void:

	exits_enabled = enabled
	configure_dynamic_exits()


## =========================
## RoomExitの再帰取得
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
## デバッグ表示の更新
## =========================

func update_debug_display() -> void:

	if room_data == null:
		return

	if not room_data.configure_exits_at_runtime:
		return


	var room_label: Node = find_child(
		"RoomNameLabel",
		true,
		false
	)

	if room_label is Label:
		(room_label as Label).text = room_data.display_name


	var main_name: String = "null"
	var sub_name: String = "null"

	if main_biome != null:
		main_name = main_biome.display_name

	if sub_biome != null:
		sub_name = sub_biome.display_name


	var context_text: String = (
		"main: " + main_name
		+ "\nsub: " + sub_name
		+ "\nsub direction: "
		+ get_direction_name(sub_biome_direction)
	)

	var context_label: Node = find_child(
		"BiomeContextLabel",
		true,
		false
	)

	if context_label is Label:
		(context_label as Label).text = context_text


	var variant_label: Node = find_child(
		"VariantLabel",
		true,
		false
	)

	if variant_label is Label:

		var suffix: String = (
			"A" if room_data.debug_variant == 0 else "B"
		)

		(variant_label as Label).text = "Variant " + suffix


	var background: Node = find_child(
		"DebugBackground",
		true,
		false
	)

	if background is Polygon2D and main_biome != null:
		(background as Polygon2D).color = main_biome.background_color


	var mark_a: Node = find_child(
		"VariantMarkA",
		true,
		false
	)

	var mark_b: Node = find_child(
		"VariantMarkB",
		true,
		false
	)

	if mark_a is CanvasItem:
		(mark_a as CanvasItem).visible = room_data.debug_variant == 0

	if mark_b is CanvasItem:
		(mark_b as CanvasItem).visible = room_data.debug_variant == 1


## =========================
## Room内のRoomExitを接続
## =========================

func _connect_room_exits(
	node: Node
) -> void:

	for child in node.get_children():

		if child is RoomExit:

			var room_exit: RoomExit = child as RoomExit

			if not room_exit.exit_requested.is_connected(
				_on_exit_requested
			):
				room_exit.exit_requested.connect(
					_on_exit_requested
				)

		_connect_room_exits(child)


## =========================
## Exitからの通知
## =========================

func _on_exit_requested(
	direction: Enums.Direction
) -> void:

	exit_requested.emit(direction)


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

	var node: Node = find_child(
		marker_name,
		true,
		false
	)

	if not node is Marker2D:
		return null

	return node as Marker2D


## =========================
## 境界Roomか
## =========================

func is_biome_transition_room() -> bool:

	return (
		sub_biome != null
		and sub_biome_direction >= 0
	)


## =========================
## Biome情報をログに表示
## =========================

func print_biome_context() -> void:

	var main_name: String = "null"
	var sub_name: String = "null"

	if main_biome != null:
		main_name = main_biome.display_name

	if sub_biome != null:
		sub_name = sub_biome.display_name

	print(
		"Room biome context: ",
		"chunk=", chunk_coord,
		" main=", main_name,
		" sub=", sub_name,
		" sub_direction=", get_direction_name(sub_biome_direction)
	)


## =========================
## RectangleShapeと同寸のPolygon
## 中心は(0,0)
## =========================

func get_centered_rectangle(
	size: Vector2
) -> PackedVector2Array:

	var half: Vector2 = size / 2.0

	return PackedVector2Array([
		Vector2(-half.x, -half.y),
		Vector2(half.x, -half.y),
		Vector2(half.x, half.y),
		Vector2(-half.x, half.y)
	])


## =========================
## Direction名
## =========================

func get_direction_name(
	direction: int
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

	return "NONE"
