
extends Area2D
class_name RoomExit

signal exit_requested(direction: Enums.Direction)

## この出口が論理マップ上のどの方向へ移動する出口か
@export var direction: Enums.Direction = Enums.Direction.RIGHT


func _ready() -> void:
	body_entered.connect(_on_body_entered)


## Playerが出口に触れたときの処理
func _on_body_entered(body: Node2D) -> void:
	## Player以外では反応しない
	if not body.is_in_group("player"):
		return

	## 物理判定が更新されるまで待ってから重なりを再確認する
	_validate_body_entered.call_deferred(body)


## body_entered直後の古い重なり情報による誤遷移を防ぐ
func _validate_body_entered(body: Node2D) -> void:
	## 次の物理フレームまで待つ
	await get_tree().physics_frame

	## 待機中に出口やPlayerが削除された場合は処理しない
	if not is_instance_valid(self):
		return

	if not is_instance_valid(body):
		return

	## 部屋の切り替えなどで出口が無効化されていたら処理しない
	if not monitoring:
		return

	## 物理判定の更新後に、現在も本当に重なっているか確認
	if not overlaps_body(body):
		print(
			"[EXIT REJECTED]",
			" exit=", get_path(),
			" direction=", direction,
			" player_position=", body.global_position,
			" exit_global_position=", global_position,
			" reason=not_overlapping_after_physics_update"
		)
		return

	## 現在の重なり状態をログに出す
	print(
		"[EXIT ACCEPTED]",
		" exit=", get_path(),
		" direction=", direction,
		" player_position=", body.global_position,
		" exit_global_position=", global_position,
		" room=", get_parent().get_path()
	)

	## 実際に重なっている場合だけ遷移を要求する
	exit_requested.emit(direction)
