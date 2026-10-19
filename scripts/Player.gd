extends CharacterBody2D

## 変数宣言

## 左右入力時の加速度
@export var player_x_accel: float = 5000

## 終端速度（左右）
@export var horizontal_final_speed: float = 1300

## 終端速度（上下）
@export var vertical_final_speed: float = 1300

## 重力の強さ
@export var gravity: float = 3500

## ジャンプ力
@export var jump_force: float = 1500

## 空気抵抗（終端速度を超えたときの抵抗力）の強さ
@export var air_resistance: float = 15000

## 左右入力をxの正負に変換する用
var x_input: float = 0.0

## すり抜け床のcollision layerを指定
var oneway_layer: int = 3

## Godotのcollision layer用ビット値
var oneway_bit: int = int(pow(2, oneway_layer - 1))

## すり抜け中かどうか
var through_timer: float = 0.0

## すり抜けボタンを押してから何秒すり抜け状態にするか
@export var throgh_timer_length: float = 0.1

## 部屋遷移後、移動入力が離されるまで移動をロックする
var movement_input_locked_until_release: bool = false

@onready var gun: Node = self.find_child("Gun")


## =========================
## 部屋遷移時の移動ロック
## =========================

func lock_movement_until_release() -> void:

	## 遷移前の速度をリセット
	velocity = Vector2.ZERO
	x_input = 0.0

	## すり抜け状態もリセット
	through_timer = 0.0
	collision_mask |= oneway_bit

	## 移動入力が離されるまでロック
	movement_input_locked_until_release = true


## =========================
## 物理更新
## =========================

func _physics_process(delta: float) -> void:

	## 遷移後の移動ロック中
	if movement_input_locked_until_release:

		## 水平方向の移動を禁止
		velocity.x = 0.0

		## 重力と物理衝突は継続
		velocity.y += gravity * delta
		air_resist(delta)

		## 射撃は継続可能
		_process_shooting_input()

		move_and_slide()

		## 移動入力がすべて離されたらロック解除
		if not _is_movement_input_pressed():
			movement_input_locked_until_release = false

		return


	## すり抜け判定
	check_through(delta)

	## 摩擦
	friction()

	## プレイヤー移動処理 左右
	move_player_horizontally(delta)

	## プレイヤー移動処理 上下
	move_player_vertically(delta)

	## 空気抵抗
	air_resist(delta)

	## 射撃入力
	_process_shooting_input()

	move_and_slide()


## =========================
## 移動入力の確認
## =========================

func _is_movement_input_pressed() -> bool:

	return (
		Input.is_action_pressed("move_left")
		or Input.is_action_pressed("move_right")
		or Input.is_action_pressed("move_down")
		or Input.is_action_pressed("jump")
	)


## =========================
## 射撃入力
## =========================

func _process_shooting_input() -> void:

	## 右銃トリガー
	## フルオートや火炎放射のため、justではなくpressedを使用
	if Input.is_action_pressed("shoot_right"):
		try_right_gun_shoot()

	## スティック銃トリガー
	check_stick_trigger()


func try_right_gun_shoot() -> void:

	gun.try_shoot()


## =========================
## すり抜け判定
## =========================

func check_through(delta: float) -> void:

	## すり抜けタイマーが0超なら減らす
	if through_timer > 0.0:
		through_timer -= delta

	## 0以下ならcollision layerを有効にする
	else:
		collision_mask |= oneway_bit

	## 床の上で下入力されたときだけすり抜ける
	if Input.is_action_pressed("move_down") and is_on_floor():

		through_timer = throgh_timer_length
		collision_mask &= ~oneway_bit


## =========================
## 左右移動
## =========================

func move_player_horizontally(delta: float) -> void:

	## 左右入力を-1～1に変換
	x_input = (
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left")
	)

	## 左右入力をx方向の移動速度に反映
	velocity.x += x_input * player_x_accel * delta


## =========================
## 上下移動
## =========================

func move_player_vertically(delta: float) -> void:

	## 重力
	velocity.y += gravity * delta

	## ジャンプ
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force


## =========================
## 摩擦
## =========================

func friction() -> void:

	## 接地かつ移動方向と反対か、入力が0ならx速度を0にする
	if is_on_floor() and x_input * velocity.x <= 0.0:
		velocity.x = 0.0

	## 接地しているならx速度を終端速度でクランプ
	if is_on_floor():
		velocity.x = clamp(
			velocity.x,
			-horizontal_final_speed,
			horizontal_final_speed
		)


## =========================
## 空気抵抗
## =========================

func air_resist(delta: float) -> void:

	if velocity.x < -horizontal_final_speed:
		velocity.x += air_resistance * delta

	if velocity.x > horizontal_final_speed:
		velocity.x -= air_resistance * delta

	if velocity.y < -vertical_final_speed:
		velocity.y += air_resistance * delta

	if velocity.y > vertical_final_speed:
		velocity.y -= air_resistance * delta


## =========================
## スティック射撃
## =========================

func check_stick_trigger() -> void:

	var dir: Vector2 = Vector2(
		Input.get_action_strength("shoot_stick_right")
			- Input.get_action_strength("shoot_stick_left"),
		Input.get_action_strength("shoot_stick_down")
			- Input.get_action_strength("shoot_stick_up")
	)

	if dir.length() > 0.8:
		try_right_gun_shoot()
