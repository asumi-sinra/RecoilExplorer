extends CharacterBody2D

#変数宣言
#左右入力時の加速度
@export var player_x_accel:float = 5000

#終端速度(左右)
@export var horizontal_final_speed:float = 1300

#終端速度(上下)
@export var vertical_final_speed:float = 1300

#重力の強さ
@export var gravity:float = 3500

#ジャンプ力
@export var jump_force:float = 1500

#空気抵抗(終端速度を超えたときの抵抗力)の強さ
@export var air_resistance:float = 15000

#左右入力をxの正負に変換する用
var x_input:float = 0

#すり抜け床のcollision layerを指定
var oneway_layer:int = 3

#godotはcollision layerの判定を2の累乗で管理しているので2の累乗に変換
var oneway_bit = int(pow(2, oneway_layer-1))

#すり抜け中かどうか
var through_timer:float = 0

#すり抜けボタンを押してから何秒すり抜け状態にするか
#すり抜け床の厚さとプレイヤーの落下速度から勘で逆算して入れる
@export var throgh_timer_length:float = 0.1

@onready var gun :Node = self.find_child("Gun")

func _physics_process(delta):
	
	#すり抜け判定
	check_through(delta)
	
	#摩擦
	friction()
	
	#プレイヤー移動処理 左右
	move_player_horizontally(delta)
	
	#プレイヤー移動処理 上下
	move_player_vertically(delta)
	
	#空気抵抗
	air_resist(delta)
	
	#右銃トリガー
	#フルオートとか火炎放射のためにjustじゃないpressedにしておく
	if Input.is_action_pressed("shoot_right"):
		try_right_gun_shoot()
	
	#スティック銃トリガー
	check_stick_trigger()
	
	move_and_slide()

func try_right_gun_shoot():
	gun.try_shoot()

func check_through(delta):
	
	#すりぬけタイマーが0超なら減らし
	if through_timer > 0:
		through_timer -= delta
	
	#0以下ならcollision layer を有効にする
	else:
		collision_mask |= oneway_bit
	
	#すり抜け入力ありならすり抜けタイマーを1にしてcollision layer を無効にする
	#床に埋まらないように、床の上で押されたときだけ反応
	if Input.is_action_pressed("move_down") and is_on_floor() :
		through_timer = throgh_timer_length
		collision_mask &= ~oneway_bit

func move_player_horizontally(delta):
	
	#(左,右入力)をxinput =(-1,1)に変換
	x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	
	#左右入力をx方向の移動速度に反映
	velocity.x += x_input * player_x_accel * delta
	
func move_player_vertically(delta):
	
	#重力
	velocity.y += gravity * delta
	
	#ジャンプ
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force

func friction():
	
	#接地かつx_inputが移動方向と反対か0ならx速度を0に
	if is_on_floor() and x_input * velocity.x <= 0:
		velocity.x = 0
		
	#接地してるならx速度を終端速度でクランプ(空中で右入力しながら左上に撃って滑る挙動の防止)
	if is_on_floor():
		velocity.x = clamp(velocity.x, -horizontal_final_speed, horizontal_final_speed)

func air_resist(delta):
	if velocity.x < -horizontal_final_speed:
		velocity.x += air_resistance * delta
	
	if velocity.x > horizontal_final_speed:
		velocity.x -= air_resistance * delta
	
	if velocity.y < -vertical_final_speed:
		velocity.y += air_resistance * delta
	
	if velocity.y > vertical_final_speed:
		velocity.y -= air_resistance * delta
		

func check_stick_trigger():
	var dir = Vector2(
		Input.get_action_strength("shoot_stick_right") - Input.get_action_strength("shoot_stick_left"),
		Input.get_action_strength("shoot_stick_down") - Input.get_action_strength("shoot_stick_up")
		)
	
	if dir.length() > 0.8:
		try_right_gun_shoot()
