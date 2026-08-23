extends Node2D

@export var recoil_strength: float = 4000.0      #反動　2000弱、4000普通、7000強くらい 200で火炎放射/バブルランチャー
@export var fire_rate: float = 0.5               # 次の発射までの間隔　0.01で火炎放射/バブルランチャー
@export var recoil_length: float = 0.15            # 反動が持続する時間
@export var ammo_max: int = 100                     # 装填弾数
@export var reload_time: float = 2.0              # リロード時間

var ammo_current: int
var fire_timer: float = 0.0
var reloading: bool = false
var reload_timer: float = 0.0
var player: CharacterBody2D
var recoil_vector: Vector2 = Vector2.ZERO         # 反動の向きと強さ
@onready var aim: Node = get_parent().get_node("Aim")

func _ready():
	ammo_current = ammo_max
	player = get_parent()

func _process(delta: float):
	if fire_timer > 0:
		fire_timer -= delta
	
	if reloading:
		reload_timer -= delta
		if reload_timer <= 0.0:
			reloading = false
			ammo_current = ammo_max
			print("Reload complete!")

func try_shoot():
	if reloading:
		return
	
	if fire_timer >0:
		return
	
	if ammo_current <= 0:
		start_reload()
		return
	
	shoot()

func shoot():
	fire_timer = fire_rate
	ammo_current -= 1
	print("Shot! Ammo left: %d" % ammo_current)
	
	apply_recoil()


func start_reload():
	if not reloading:
		reloading = true
		reload_timer = reload_time
		print("Reloading...")

func apply_recoil():
	
	#接地してたらふんばって反動なしに
	if player.is_on_floor():
		return
	
	# マウス位置と逆方向に反動を加える
	player.velocity -= aim.get_aim_direction() * recoil_strength
