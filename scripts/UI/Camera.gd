extends Camera2D

@onready var player: Node = get_parent().get_node("Player")

@export var deadzone_size: Vector2 = Vector2(200, 900) # 枠の大きさ
var half = deadzone_size / 2.0 # デッドゾーン矩形（中心をカメラ位置とする）
@onready var camera_pos: Vector2
@onready var target_pos: Vector2
@onready var Offset: Vector2


func _ready():
	camera_pos = self.global_position

func _process(delta):

	target_pos = player.global_position
	Offset = target_pos - camera_pos
	
	# 枠外に出た分だけカメラを動かす
	if Offset.x > half.x:
		camera_pos.x = target_pos.x - half.x
	elif Offset.x < -half.x:
		camera_pos.x = target_pos.x + half.x

	if Offset.y > half.y:
		camera_pos.y = target_pos.y - half.y
	elif Offset.y < -half.y:
		camera_pos.y = target_pos.y + half.y

	self.global_position = camera_pos
